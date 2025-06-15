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

		P_SetOrigin(p.mo, gate.x, gate.y, gate.z+(gate.height/2)-(p.mo.height/2))
		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		p.mo.flags2 = $|MF2_DONTDRAW
	end
	for p,_ in pairs(gate.lappers) do
		if not (p and p.ptv3 and p.mo and not p.ptv3.specforce) then continue end
		PTV3:newLap(p)
	end
	gate.lappers = {}
end, MT_PTV3_SPAWNGATE)

addHook("TouchSpecial", function(gate, pmo)
	if not (gate
		and gate.valid
		and pmo
		and pmo.valid
		and pmo.player
		and pmo.player.ptv3) then return true end

	if not PTV3.pizzatime then return true end

	local p = pmo.player

	if gametype == GT_PTV3DM then
		gate.lappers[p] = true
	else
		if p.ptv3.fake_exit then return true end
		if not PTV3:canExit(p) then return true end

		if PTV3:forceLap(p) then
			gate.lappers[p] = true
			return true
		end

		PTV3:doPlayerExit(p)
	end

	return true
end, MT_PTV3_SPAWNGATE)