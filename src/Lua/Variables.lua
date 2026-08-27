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

	p.PTGlobal.menumode.inmenu = true
	p.PTGlobal.menumode.menutype = string.lower(menuname)

	CONS_Printf(p, "Entering: "..p.PTGlobal.menumode.menutype)
end)

COM_AddCommand('PTV3_panic', function(p, lap)
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
	
	p.PTRound.chaser = true
	p.PTRound.chasertype = string.lower(chasertype)


	if chasertype == "pizzaface" then
		PTV3.pizzaface = p
		PTV3:pizzafaceSpawn(p.PTGlobal.pizzaface_skin)
	end

	if chasertype == "snick" then
		PTV3.snick = p
		PTV3:snickSpawn(p.PTGlobal.snick_skin)
	end

	if chasertype == "johnghost" then
		PTV3.johnGhost = p
		PTV3:johnGhostSpawn(p.PTGlobal.johnghost_skin)
	end
end, COM_ADMIN)

COM_AddCommand('PTV3_setchaserskin', function(p, skin)
	if not PTV3:isPTV3() then return end

	local skin_name = skin ~= nil and string.lower(skin) or nil

	for _,v in pairs(PTV3_SKINS.pizzaface) do
		if skin_name == string.lower(PTV3_SKINS.pizzaface[_].name) then
			p.PTGlobal.pizzaface_skin = string.lower(PTV3_SKINS.pizzaface[_].name)
			CONS_Printf(p, "Your Pizzaface skin has been set to: "..PTV3_SKINS.pizzaface[_].name)
			return
		end
	end

	for _,v in pairs(PTV3_SKINS.snick) do
		if skin_name == string.lower(PTV3_SKINS.snick[_].name) then
			p.PTGlobal.snick_skin = string.lower(PTV3_SKINS.snick[_].name)
			CONS_Printf(p, "Your Snick skin has been set to: "..PTV3_SKINS.snick[_].name)
			return
		end
	end

	for _,v in pairs(PTV3_SKINS.johnGhost) do
		if skin_name == string.lower(PTV3_SKINS.johnGhost[_].name) then
			p.PTGlobal.johnghost_skin = string.lower(PTV3_SKINS.johnGhost[_].name)
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

COM_AddCommand('PTV3_rollgates', function(p)
	for _, gate in pairs(PTV3_HUB.gates) do
		PTV3_HUB.gates[gate.map] = nil

		local mapsChosen = {}
		local foundMaps = {}
		local hasChosenMap = false

		for map = 1, 1035 do
			local data = mapheaderinfo[map]
		
			if data
			and data.typeoflevel & TOL_COOP
			and data.bonustype <= 0 then
				table.insert(foundMaps, map)
			end
		end

		for _,gate in pairs(PTV3_HUB.gates) do
			mapsChosen[gate.map] = true
		end

		while not hasChosenMap do
			local map = foundMaps[P_RandomRange(1,#foundMaps)]
			if not mapsChosen[map] then
				hasChosenMap = true
				gate.map = map
			end
		end
	end
end, COM_ADMIN)

COM_AddCommand("PTV3_havetogorapidini", function(p)
	p.powers[pw_sneakers] = 100*TICRATE
end)

-- vars
PTV3.maxTitlecardTime = 3*TICRATE

PTV3.synced_variables = {
	['pizzatime'] = 0,
	['total_laps'] = 1,
	['spawn'] = {x=0,y=0,z=0},
	['endpos'] = {x=0,y=0,z=0,a=0},
	['tplist'] = {mobjteleport = {mo=nil, coords=nil,relative=false}},
	['endsec'] = false,
	['lapPortal'] = false,
	['pillarJohn'] = false,
	['spawnsector'] = false,
	['endtime'] = -1,
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
	['pizzaposts'] = {},
	['time'] = 600*TICRATE,
	['maxtime'] = 600*TICRATE,
	['votetime'] = 5*TICRATE,
	['pftime'] = 30*TICRATE,
	['spawnGate'] = false,
	['__fadedmus'] = false,
	['overtime_time'] = TICRATE,
	['maxottime'] = 60*TICRATE,
	['overtime_elapser'] = 1,
	['secret_count'] = 0,
 	['game_over'] = (21*TICRATE)-10, --- 200
	['ranktransitiontime'] = 15*TICRATE,
	['maxrankrequirement'] = 1500,
	['starttime_pizzatime'] = -1,
	['highestlap'] = 0,
	['matchLog'] = {},
	['has_titlecard'] = false,

	-- not net
	['hud_lap'] = -1,
	['hud_secret'] = -1
}

--- Enemies Pizzaface can spawn go here.
PTV3.enemylist = {
	MT_BLUECRAWLA,
	MT_REDCRAWLA,
	-- MT_GFZFISH,
	MT_GOLDBUZZ,
	MT_REDBUZZ,
	MT_JETTBOMBER,
	MT_JETTGUNNER,
	MT_CRAWLACOMMANDER,
	MT_DETON,
	-- MT_SKIM,
	-- MT_TURRET,
	-- MT_POPUPTURRET,
	MT_SPINCUSHION,
	MT_CRUSHSTACEAN,
	MT_BANPYURA,
	MT_BANPSPRING,
	MT_JETJAW,
	MT_SNAILER,
	MT_VULTURE,
	MT_POINTY,
	MT_ROBOHOOD,
	MT_FACESTABBER,
	MT_EGGGUARD,
	MT_GSNAPPER,
	MT_MINUS,
	MT_SPRINGSHELL,
	MT_YELLOWSHELL,
	MT_UNIDUS,
	MT_CANARIVORE,
	MT_PYREFLY,
	MT_PTERABYTE,
	MT_DRAGONBOMBER,
	MT_PENGUINATOR,
	MT_POPHAT,
	MT_HIVEELEMENTAL,
	MT_BUMBLEBORE,
	MT_SPINBOBERT,
	-- MT_HANGSTER
}

-- hooks
addHook('NetVars', function(n)
	local net = {
		"pizzatime",
		"total_laps",
		"spawn",
		"endpos",
		"tplist",
		"endsec",
		"lapPortal",
		"pillarJohn",
		"spawnsector",
		"endtime",
		"extreme",
		"skybox",
		"shakeintensity",
		"currentchasers",
		"pizzaface",
		"snick",
		"johnGhost",
		"skinIndex",
		"wartimer",
		"wartimerStart",
		"overtime",
		"overtimeStart",
		"pizzafacetps",
		"pizzaposts",
		"time",
		"maxtime",
		"votetime",
		"pftime",
		"maxpftime",
		"spawnGate",
		"max_laps",
		"max_elaps",
		"__fadedmus",
		"overtime_time",
		"maxottime",
		"overtime_elapser",
		"secret_count",
		"game_over",
		"ranktransitiontime",
		"maxrankrequirement",
		"starttime_pizzatime",
		"highestlap",
		"matchLog",
		"has_titlecard",

		"time",
		"max_laps",
		"max_elaps",
		"max_erings",
		"ai_pizzaface",
		"time_for_pizzaface_ai",
		"time_for_pizzaface_player",
	}

	for _,i in pairs(net) do
		PTV3[i] = n($)
	end
end)