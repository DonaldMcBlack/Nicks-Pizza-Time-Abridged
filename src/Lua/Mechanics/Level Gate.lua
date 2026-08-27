freeslot("MT_PTV3_LEVELGATE")

mobjinfo[MT_PTV3_LEVELGATE] = {
	--$Name "Level Gate"
    --$Sprite EXGAA1
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
		and data.typeoflevel & TOL_PTV3
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

	if multiplayer then mo.votes = 0 end

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

			if p.mo.z < mo.z or p.mo.z > mo.z+mo.height then return end

			local forwardmove = p.PTGlobal.forwardmove

			if forwardmove == 50 and forwardmove ~= p.PTGlobal.lastforwardmove then
				if multiplayer then
					if p.PTRound.gate_vote then
						p.PTRound.gate_vote.votes = $-1
						if p.PTRound.gate_vote == mo then p.PTRound.gate_vote = nil return end

						p.PTRound.gate_vote = mo
						p.PTRound.gate_vote.votes = $+1
					else
						p.PTRound.gate_vote = mo
						mo.votes = $+1
					end
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