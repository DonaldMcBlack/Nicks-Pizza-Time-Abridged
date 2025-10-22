-- Command Variables and Commands

CV_PTV3['time'] = CV_RegisterVar({
	name = "PTV3_time",
	defaultvalue = 5,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_laps'] = CV_RegisterVar({
	name = "PTV3_laps",
	defaultvalue = 5,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_elaps'] = CV_RegisterVar({
	name = "PTV3_extreme_laps",
	defaultvalue = 7,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_erings'] = CV_RegisterVar({
	name = "PTV3_max_erings",
	defaultvalue = 60,
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

COM_AddCommand('PTV3_openmenu', function(p, menuname)
	if not PTV3:isPTV3() then return end

	p.ptv3.menumode.inmenu = true
	p.ptv3.menumode.menutype = string.lower(menuname)

	CONS_Printf(p, "Entering: "..p.ptv3.menumode.menutype)
end)

COM_AddCommand('PTV3_pizzatimenow', function(p, lap)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	local numlap = tonumber(lap)

	if not PTV3.pizzatime then
		if numlap then
			if numlap > 0 then
				PTV3:startPizzaTime(p, 1)
				numlap = $-1
			else
				PTV3:startPizzaTime(p, -1)
				numlap = $+1
			end
			PTV3:newLap(p, numlap)
		else
			PTV3:startPizzaTime(p, 1)
		end

		if PTV3.pillarJohn then P_RemoveMobj(PTV3.pillarJohn) end
	end
end, COM_ADMIN)

COM_AddCommand('PTV3_becomechaser', function(p, chaser)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	local chasertype = chaser or "pizzaface"
	
	p.ptv3.chaser = true
	p.ptv3.chasertype = string.lower(chasertype)


	if chasertype == "pizzaface" then
		PTV3.pizzaface = p
		PTV3:pizzafaceSpawn(p.ptv3.pizzaface_skin)
	end

	if chasertype == "snick" then
		PTV3.snick = p
		PTV3:snickSpawn(p.ptv3.snick_skin)
	end

	if chasertype == "johnghost" then
		PTV3.johnGhost = p
		PTV3:johnGhostSpawn(p.ptv3.johnghost_skin)
	end
end, COM_ADMIN)

COM_AddCommand('PTV3_setchaserskin', function(p, skin)
	if not PTV3:isPTV3() then return end

	local skin_name = skin ~= nil and string.lower(skin) or nil

	for _,v in pairs(PTV3_SKINS.pizzaface) do
		if skin_name == string.lower(PTV3_SKINS.pizzaface[_].name) then
			p.ptv3.pizzaface_skin = string.lower(PTV3_SKINS.pizzaface[_].name)
			CONS_Printf(p, "Your Pizzaface skin has been set to: "..PTV3_SKINS.pizzaface[_].name)
			return
		end
	end

	for _,v in pairs(PTV3_SKINS.snick) do
		if skin_name == string.lower(PTV3_SKINS.snick[_].name) then
			p.ptv3.snick_skin = string.lower(PTV3_SKINS.snick[_].name)
			CONS_Printf(p, "Your Snick skin has been set to: "..PTV3_SKINS.snick[_].name)
			return
		end
	end

	for _,v in pairs(PTV3_SKINS.johnGhost) do
		if skin_name == string.lower(PTV3_SKINS.johnGhost[_].name) then
			p.ptv3.johnghost_skin = string.lower(PTV3_SKINS.johnGhost[_].name)
			CONS_Printf(p, "Your John Ghost skin has been set to: "..PTV3_SKINS.johnGhost[_].name)
			return
		end
	end
end, COM_LOCAL)

COM_AddCommand('PTV3_giveitem', function(p, item)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end
	
	PTV3:GiveItem(p, string.lower(item))
end, COM_ADMIN)

COM_AddCommand('PTV3_forceovertime', function(p)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	PTV3:overtimeToggle()
end, COM_ADMIN)

COM_AddCommand('PTV3_setWARtimer', function(p, time)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	PTV3.overtime_time = time*TICRATE

	local text = ("%02d %02d"):format(
	G_TicsToMinutes(PTV3.overtime_time),
	G_TicsToSeconds(PTV3.overtime_time)
	)

	CONS_Printf(consoleplayer, "Set War Timer to "..text)
end, COM_ADMIN)

COM_AddCommand('PTV3_spawnpizzaface', function(p, skin)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	local skin_name = skin ~= nil and string.lower(skin) or nil
	PTV3:pizzafaceSpawn(skin_name)
	P_SetOrigin(PTV3.pizzaface, p.mo.x, p.mo.y, p.mo.z)
end, COM_ADMIN)

COM_AddCommand('PTV3_spawnsnick', function(p, skin)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	local skin_name = skin ~= nil and string.lower(skin) or nil
	PTV3:snickSpawn(skin_name)
end, COM_ADMIN)

COM_AddCommand('PTV3_spawnjohnghost', function(p, skin)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end

	local skin_name = skin ~= nil and string.lower(skin) or nil
	PTV3:johnGhostSpawn(skin_name)
end, COM_ADMIN)
COM_AddCommand('PTV3_endgame', function(p)
	if not PTV3:isPTV3() then return end

	PTV3:endGame()
end, COM_ADMIN)

-- vars
local synced_variables = {
	['pizzatime'] = 0,
	['total_laps'] = 1,
	['spawn'] = {x=0,y=0,z=0},
	['endpos'] = {x=0,y=0,z=0,a=0},
	['tplist'] = {mobjteleport = {mo=nil, coords=nil,relative=false}},
	['endsec'] = false,
	['lapPortal'] = false,
	['pillarJohn'] = false,
	['spawnsector'] = false,
	['game_ended'] = false,
	['extreme'] = false,
	['skybox'] = false,
	['shakeintensity'] = 0,
	['currentchasers'] = {},
	['pizzaface'] = false,
	['snick'] = false,
	['johnGhost'] = false,
	['skinIndex'] = { pizzaface = 0, snick = 0, johnGhost = 0 },
	['wartimer'] = false,
	['wartimerStart'] = 0,
	['overtime'] = false,
	['overtimeStart'] = 0,
	['pizzafacetps'] = {},
	['time'] = 600*TICRATE,
	['maxtime'] = 600*TICRATE,
	['pftime'] = 30*TICRATE,
	['spawnGate'] = false,
	['__fadedmus'] = false,
	['wartime'] = 1,
	['overtime_time'] = TICRATE,
	['maxotTime'] = (120+29)*TICRATE,
	['secrets'] = {},
	['secret_count'] = 0,
 	['game_over'] = -1,
	['maxrankrequirement'] = 1500,
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

	PTV3.spawnGate = R_PointInSubsectorOrNil(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a))) and P_SpawnMobj(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a)), PTV3.spawn.z, MT_PTV3_SPAWNGATE) or
												P_SpawnMobj(PTV3.spawn.x, PTV3.spawn.y, PTV3.spawn.z, MT_PTV3_SPAWNGATE)
	PTV3.spawnGate.angle = a

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
		['laps'] = 0,

		['ragdoll'] = 0,
		['ragdoll_bounces'] = 0,

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
		['insecret'] = false,
		['secretsfound'] = 0,
		['secret_tptoend'] = false,
		['combo'] = 0,
		['combo_pos'] = 0,
		['combo_display'] = 0,
		['combo_start_time'] = 0,
		['started_combo'] = false,
		['combo_offtime'] = false,
		['combo_rank'] = { rank = nil, rankn = 0, very = false, time = 5*TICRATE},
		['lap_time'] = -1,
		['canLap'] = 0,

		['toppins'] = {},

		['curItem'] = false,
		['curItem_equipped'] = false,
		['curItem_mobj'] = nil,
		['invItems'] = {},
		['ringBank'] = 0,

		['exitShield'] = SH_NONE,
		['pvpCooldown'] = 0,
		
		['movementData'] = {},
		['currentTeleportDest'] = {},
		
		['rank'] = 1,
		['rank_changetime'] = -1,
		['extremeNotif'] = 0,

		['scoreReduce'] = {time = false, by = 0},

		['pizzaMobj'] = false,
		['pizzaMobj_skindata'] = {},
		['pizzaface_skin'] = "pizzaface",
		['snick_skin'] = "snick",
		['johnghost_skin'] = "john",
		
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
		['camper_time'] = 0,

		['menumode'] = { inmenu = false, menutype = nil }
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
		"shakeintensity",
		"currentchasers",
		"pizzaface",
		"lapPortal",
		"pillarJohn",
		"snick",
		"johnGhost",
		"skinIndex",
		"wartimer",
		"wartimerStart",
		"overtime",
		"overtimeStart",
		"time",
		"maxtime",
		"pftime",
		"maxpftime",
		"spawnGate",
		"__fadedmus",
		"wartime",
		"overtime_time",
		"maxotTime",
		"secrets",
		"secret_count",
		"pizzafacetps",
		"game_over",
		"hud_pt",
		"matchLog",
		"max_laps",
		"max_elaps",
		"max_erings",
		"ai_pizzaface",
		"maxrankrequirement"
	}

	for _,i in pairs(net) do
		PTV3[i] = n($)
	end
end)

addHook('MapChange', function()
	has_inited = false
	PTV3:init()
end)

local function PreparePizzaTimer(minutes, seconds)
	if not seconds then return end

	PTV3.time = seconds*TICRATE

	if not minutes then return end

	PTV3.time = $+minutes*TICRATE*60
end

addHook('MapLoad', function(map)
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

	PTV3.setJohnBlocks()

	for i, v in ipairs(PTV3.secrets) do
		if PTV3.secrets[i-1] ~= nil and PTV3.secrets[i-1].sgroup == v.sgroup then continue
		else
			PTV3.secret_count = $+1
		end
	end

	local alive, pizzafaces, total = PTV3.playerCount and PTV3:playerCount()

	PreparePizzaTimer(mapheaderinfo[map].pizzatimelimit_mins ~= nil and tonumber(mapheaderinfo[map].pizzatimelimit_mins) or CV_PTV3['time'].value, mapheaderinfo[map].pizzatimelimit_secs ~= nil and tonumber(mapheaderinfo[map].pizzatimelimit_secs) or 1)

	PTV3.overtime_time = multiplayer and (120+29)*TICRATE or TICRATE*60
	PTV3.maxtime = PTV3.time
	PTV3.pftime = 30*TICRATE
	PTV3.maxpftime = PTV3.pftime

	if not titlemapinaction then
		PTV3.skinIndex.pizzaface = P_RandomRange(0, #PTV3_SKINS.pizzaface)
		PTV3.skinIndex.snick = P_RandomRange(0, #PTV3_SKINS.snick)
		PTV3.skinIndex.johnGhost = P_RandomRange(0, #PTV3_SKINS.johnGhost)

		CONS_Printf(consoleplayer, "Pizzaface is... "..PTV3_SKINS.pizzaface[PTV3.skinIndex.pizzaface].name)
		CONS_Printf(consoleplayer, "Snick is... "..PTV3_SKINS.snick[PTV3.skinIndex.snick].name)
		CONS_Printf(consoleplayer, "John is... "..PTV3_SKINS.johnGhost[PTV3.skinIndex.johnGhost].name)
	end
	
	if gametype == GT_PTV3DM
	and not PTV3.titlecards[gamemap] then
		PTV3:pizzafaceSpawn()
	end
end)

-- I don't care if it's not there in the actual gametype, I want it gone.
addHook("MobjThinker", function(sign) if sign and sign.valid then P_RemoveMobj(sign) end end, MT_SIGN)