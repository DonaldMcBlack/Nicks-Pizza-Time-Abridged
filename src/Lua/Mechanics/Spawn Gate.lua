states[freeslot "S_PTV3_SPAWNGATE"] = {
	sprite = freeslot "SPR_EXGA",
	frame = B
}

mobjinfo[freeslot "MT_PTV3_SPAWNGATE"] = {
	spawnstate = S_PTV3_SPAWNGATE,
	radius = 60*FU,
	height = 190*FU,
	flags = MF_SPECIAL
}

addHook("MobjSpawn", function(gate)
	gate._frame = B
	gate.frame = B
	gate.spawnPoints = {}
	gate.lappers = {}

	for t in mapthings.iterate do
		if t.type < 1
		and t.type > 32 then
			continue
		end

		local sec = R_PointInSubsector(t.x*FU, t.y*FU).sector

		gate.spawnPoints[t.type] = {
			x = t.x*FU,
			y = t.y*FU,
			z = sec.floorheight+(t.z*FU),
			a = t.angle*ANG1
		}
	end
end, MT_PTV3_SPAWNGATE)

addHook("MobjThinker", function(gate)
	gate.frame = gate._frame

	for p in players.iterate do
		if not (p and p.mo and p.ptv3.fake_exit) then continue end
		if not gate.lappers[p] then continue end

		if PTV3:forceLap(p) then
			PTV3:newLap(p, 1)
			gate.lappers[p] = false
		else
			P_SetOrigin(p.mo, gate.x, gate.y, gate.z+(gate.height/2)-(p.mo.height/2))
			p.mo.flags2 = $|MF2_DONTDRAW
		end
	end
end, MT_PTV3_SPAWNGATE)

addHook("TouchSpecial", function(gate, pmo)
	if not (gate and gate.valid
	and pmo and pmo.valid and pmo.player and pmo.player.ptv3) then
		return true
	end
	if not (PTV3.pizzatime or PTV3.minusworld) then return true end

	local p = pmo.player
	
	if p.ptv3.fake_exit then return true end
	if gate.lappers[p] == true then return true end

	gate.lappers[p] = true
	if not PTV3:canExit(p) then return true end

	PTV3:doPlayerExit(p)
	return true
end, MT_PTV3_SPAWNGATE)