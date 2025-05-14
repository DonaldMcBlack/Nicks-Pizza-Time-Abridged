freeslot(
	"MT_PTV3_PILLARJOHN",
	"SPR_JOHN",
	"S_PTV3_PILLARJOHN",
	"sfx_jpilr"
)

states[S_PTV3_PILLARJOHN] = {
	sprite = SPR_JOHN,
	frame = A,
	tics = -1,
	nextstate = S_PTV3_PILLARJOHN
}

mobjinfo[MT_PTV3_PILLARJOHN] = {
	spawnstate = S_PTV3_PILLARJOHN,
	radius = 64*FU,
	height = 200*FU,
	flags = MF_SPECIAL|MF_ENEMY
}

addHook("MobjSpawn", function(john)
	john.isAlive = true
end, MT_PTV3_PILLARJOHN)

local function killJohn(john, pmo)
	if not john.isAlive then return end

	local killAngle = R_PointToAngle2(john.x, john.y, pmo.x, pmo.y)

	john.angle = killAngle

	john.momx = FixedMul(-16*cos(killAngle), john.scale)
	john.momy = FixedMul(-16*sin(killAngle), john.scale)
	john.momz = 16*john.scale

	S_StartSound(john, sfx_jpilr)
	john.isAlive = false

	PTV3:startPizzaTime(pmo.player)
end

addHook("TouchSpecial", function(john, pmo)
	if not (pmo and pmo.player and pmo.player.ptv3) then return true end

	killJohn(john, pmo)

	return true
end, MT_PTV3_PILLARJOHN)

addHook("MobjThinker", function(john)
	if not (john and john.valid) then return end

	if not john.isAlive or PTV3.pizzatime then
		john.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT
		if (john.z > john.ceilingz
		or john.z+john.height < john.floorz) then
			P_RemoveMobj(john)
		end
	end
end, MT_PTV3_PILLARJOHN)