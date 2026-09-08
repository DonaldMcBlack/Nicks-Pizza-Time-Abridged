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