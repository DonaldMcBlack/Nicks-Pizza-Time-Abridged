-- Command Variables and Commands

CV_PTV3['time'] = CV_RegisterVar({
	name = "PTV3_time",
	defaultvalue = 300,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_laps'] = CV_RegisterVar({
	name = "PTV3_laps",
	defaultvalue = 4,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['ai_pizzaface'] = CV_RegisterVar({
	name = "PTV3_ai_pizzaface",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})
CV_PTV3['time_for_pizzaface_ai'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_ai",
	defaultvalue = 120+30,
	flags = CV_NETVAR,
})
CV_PTV3['time_for_pizzaface_player'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_player",
	defaultvalue = 10,
	flags = CV_NETVAR,
})

local function findPlayer(name)
	local player
	local namenum = tonumber(name)
	for p in players.iterate do
		if p.name:lower() == tostring(name):lower() 
		or (namenum ~= nil
		and namenum >= 0
		and namenum < 31
		and #p == namenum) then
			player = p
			break
		end
	end

	return player
end

COM_AddCommand('PTV3_pizzatimenow', function(p)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end
	
	PTV3:startPizzaTime(p)
end)
COM_AddCommand('PTV3_endgame', function(p)
	if not PTV3:isPTV3() then return end

	PTV3:endGame()
end, COM_ADMIN)

-- vars
local synced_variables = {
	['pizzatime'] = false,
	['total_laps'] = 1,
	['spawn'] = {x=0,y=0,z=0},
	['endpos'] = {x=0,y=0,z=0,a=0},
	['endsec'] = false,
	['lapPortal'] = false,
	['pillarJohn'] = false,
	['spawnsector'] = false,
	['game_ended'] = false,
	['extreme'] = false,
	['skybox'] = false,
	['pizzaface'] = false,
	['snick'] = false,
	['overtime'] = false,
	['overtimeStart'] = 0,
	['pizzafacetps'] = {},
	['time'] = 600*TICRATE,
	['maxtime'] = 600*TICRATE,
	['pftime'] = 30*TICRATE,
	['spawnGate'] = false,
	['__fadedmus'] = false,
	['overtime_time'] = (120+29)*TICRATE,
	['maxotTime'] = (120+29)*TICRATE,
	['secrets'] = {},
 	['game_over'] = -1,
	['hud_pt'] = -1,
	['matchLog'] = {},

	-- not net
	['hud_lap'] = -1,
	['hud_secret'] = -1
}

-- functions

local function spawnSector(t)
	if t.type ~= 1 then return end

	local sec = R_PointInSubsector(t.x*FU, t.y*FU).sector

	PTV3.spawn = {
		x = t.x*FU,
		y = t.y*FU,
		z = sec.floorheight + (t.z*FU),
		a = t.angle*ANG1
	}

	local a = PTV3.spawn.a

	if PTV3.titlecards[gamemap] then
		PTV3.spawnGate = P_SpawnMobj(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a)), PTV3.spawn.z, MT_PTV3_SPAWNGATE)
		PTV3.spawnGate.angle = a
	end

	PTV3.spawnsector = sec
end
local function endSector(t)
	if t.type ~= 501 then return end

	local sec = R_PointInSubsector(t.x*FU, t.y*FU).sector

	PTV3.endpos = {
		x = t.x*FU,
		y = t.y*FU,
		z = sec.floorheight + (t.z*FU),
		a = t.angle*ANG1
	}
	PTV3.endsec = sec

	local john = P_SpawnMobj(PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z, MT_PTV3_PILLARJOHN)

	john.angle = PTV3.endpos.a
end

local function cloneTable(table)
	if type(table) ~= "table" then
		return table
	end

	local clone = {}

	for k,v in pairs(table) do
		if type(table) == "table" then
			clone[k] = cloneTable(v)
			continue
		end

		clone[k] = v
	end

	return clone
end

function PTV3:player(player)
	local isSwap = player.ptv3 and player.ptv3.isSwap
	local swapModeFollower = player.ptv3 and player.ptv3.swapModeFollower

	player.ptv3 = {
		["buttons"] = player.cmd.buttons,
		['laps'] = 1,

		['chaser'] = false,
		['chasertype'] = "pizzaface",

		['chasermovetime'] = 0,
		['chaservertmovetime'] = 0,

		['pizzaface_chasedown'] = 0,
		['pizzaface_chasedowncool'] = 0,

		['pizzaface_teleporting'] = false,
		
		['pizzaface_tpsidemove'] = 0,
		['pizzaface_tpselection'] = 1,
		
		['pizzaface_teleportingcool'] = 0,

		['snick_sonicmode'] = 0,
		['snick_sonicmodecool'] = 0,

		['specforce'] = false,
		['extreme'] = false,
		['fake_exit'] = false,
		['insecret'] = 0,
		['secretsfound'] = 0,
		['secret_tptoend'] = false,
		['combo'] = 0,
		['combo_pos'] = 0,
		['combo_display'] = 0,
		['combo_start_time'] = 0,
		['started_combo'] = false,
		['combo_offtime'] = false,
		['combo_rank'] = false,
		['lap_time'] = -1,
		['canLap'] = 0,

		['toppins'] = {},

		['banana'] = 0,
		['banana_angle'] = 0,
		['banana_speed'] = 0,
		['exitShield'] = SH_NONE,
		['pvpCooldown'] = 0,
		
		['savedData'] = {},
		
		['rank'] = 1,
		['rank_changetime'] = -1,
		['extremeNotif'] = 0,

		['scoreReduce'] = false,

		['pizzaMobj'] = false,
		
		['pfBoost'] = 0,
		['maxPfBoost'] = 2*TICRATE,
		
		['isTaunting'] = false,
		['tauntTime'] = 0,
		['tauntmomx'] = 0,
		['tauntmomy'] = 0,
		['tauntmomz'] = 0,
		['tauntlaststate'] = S_PLAY_STND,
		['tauntsprite'] = SPR2_STND,
		['tauntframe'] = A,

		['stun'] = 0,
		['camper'] = false,

		['camper_area'] = {x=0, y=0},
		['camper_radius'] = (40*24)*FU,
		['camper_time'] = 0
	}
	
	if self.pizzatime then
		player.ptv3.specforce = true
	end
	player.score = 0
	player.ptv3.swapModeFollower = swapModeFollower
	player.ptv3.isSwap = isSwap
	P_ResetPlayer(player)

	PTV3.callbacks('PlayerInit', player)
end

local has_inited = false
function PTV3:init()
	if has_inited then return end
	for _,i in pairs(synced_variables) do
		self[_] = cloneTable(i)
	end

	for _,i in pairs(CV_PTV3) do
		self[_] = i.value
	end

	for player in players.iterate do
		player.ptv3 = nil
	end
	
	if PTV3.callbacks then --ahaaaa got cha now error
		PTV3.callbacks('VariableInit')
	end
	has_inited = true
end

PTV3:init()

-- hooks

addHook('NetVars', function(n)
	local net = {
		"pizzatime",
		"total_laps",
		"spawn",
		"endpos",
		"endsec",
		"spawnsector",
		"game_ended",
		"extreme",
		"skybox",
		"pizzaface",
		"lapPortal",
		"pillarJohn",
		"snick",
		"overtime",
		"overtimeStart",
		"time",
		"maxtime",
		"pftime",
		"maxpftime",
		"spawnGate",
		"__fadedmus",
		"overtime_time",
		"maxotTime",
		"secrets",
		"pizzafacetps",
		"game_over",
		"hud_pt",
		"matchLog",
		"max_laps",
		"max_elaps",
		"max_erings",
		"ai_pizzaface"
	}

	for _,i in pairs(net) do
		PTV3[i] = n($)
	end
end)

addHook('MapChange', function()
	has_inited = false
	PTV3:init()
end)

addHook('MapLoad', function()
	PTV3:init()
	-- one more for safety
	for p in players.iterate do
		p.ptv3 = nil
	end

	if not PTV3:isPTV3() then 
		hud.enable('lives')
		return
	end
	hud.disable('lives')

	for thing in mapthings.iterate do
		spawnSector(thing)
		endSector(thing)
	end

	local alive, pizzafaces, total = PTV3.playerCount and PTV3:playerCount()
	PTV3.time = CV_PTV3['time'].value*TICRATE
	PTV3.maxtime = PTV3.time
	PTV3.pftime = 30*TICRATE
	PTV3.maxpftime = PTV3.pftime
	
	if gametype == GT_PTV3DM
	and not PTV3.titlecards[gamemap] then
		PTV3:pizzafaceSpawn()
		PTV3:snickSpawn()
	end
end)