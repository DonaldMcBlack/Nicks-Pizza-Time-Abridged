freeslot("MT_PTV3_LEVELGATE")

mobjinfo[MT_PTV3_LEVELGATE] = {
	--$Name "Level Gate"
    --$Sprite EXGAA0
    --$Category "PTV3A"
	--$Color 1
	--$Angled
	doomednum = 2223,
    spawnstate = S_PTV3_SPAWNGATE,
	radius = 60*FU,
	height = 190*FU,
	flags = MF_SPECIAL
}

addHook("MapThingSpawn", function(mo, mt)
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
			mo.map = map
		end
	end

	if multiplayer then mo.votes = {} end

	table.insert(PTV3_HUB.gates, mo)
	print(mapheaderinfo[mo.map].lvlttl)
end, MT_PTV3_LEVELGATE)

addHook("MapChange", function(map)
	for mapnum in pairs(PTV3_HUB.gates) do PTV3_HUB.gates[mapnum] = nil end
end)

addHook("MobjThinker", function(mo)

	searchBlockmap("objects", function(refmobj, foundmobj)
		if foundmobj and foundmobj.valid and foundmobj.player then
			local p = foundmobj.player

			if p.ptv3.forwardmove == 1 then
				if multiplayer then

					if not mo.votes[p] then table.insert(mo.votes, p)
					else table.remove(mo.votes, p) end
					
					print(mo.votes[p])
				else
					G_SetCustomExitVars(mo.map, 2)
					G_ExitLevel()
				end
			end
		end
	end, mo,
	mo.x-FU*100, mo.x+FU*100,
	mo.y-FU*100, mo.y+FU*100)
end, MT_PTV3_LEVELGATE)