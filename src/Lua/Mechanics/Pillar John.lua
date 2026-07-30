freeslot(
	"MT_PTV3_PILLARJOHN",
	"SPR_JOHN",
	"S_PTV3_PILLARJOHN",
	"S_PTV3_PILLARJOHNSCARED",
	"sfx_jpilr"
)

sfxinfo[sfx_jpilr].caption = "John collapsed!"

states[S_PTV3_PILLARJOHN] = {
	sprite = SPR_JOHN,
	frame = A|FF_ANIMATE,
	tics = -1,
	var1 = 9,
	var2 = 2,
	nextstate = S_PTV3_PILLARJOHN
}

states[S_PTV3_PILLARJOHNSCARED] = {
	sprite = SPR_JOHN,
	frame = K|FF_ANIMATE,
	tics = -1,
	var1 = 4,
	var2 = 2,
	nextstate = S_PTV3_PILLARJOHNSCARED
}

mobjinfo[MT_PTV3_PILLARJOHN] = {
	spawnstate = S_PTV3_PILLARJOHN,
	spawnhealth = 2,
	radius = 64*FU,
	height = 200*FU,
	flags = MF_SPECIAL|MF_ENEMY
}

addHook("ShouldDamage", function(t,i,s) return true end, MT_PTV3_PILLARJOHN)
addHook('MobjDamage', function(t,i,s) return true end, MT_PTV3_PILLARJOHN)

addHook("MobjSpawn", function(john) PTV3.pillarJohn = john end, MT_PTV3_PILLARJOHN)
addHook("MobjDeath", function(john, i, s) if not PTV3.pizzatime then PTV3:startPizzaTime(s.player, 1) end end, MT_PTV3_PILLARJOHN)

addHook("TouchSpecial", function(john, pmo)
	if not (pmo and pmo.player and pmo.player.PTRound) then return true end
	if john.health < 2 then return true end
	if PTV3.pizzatime < 0 then return end

	john.health = 1

	local killAngle = R_PointToAngle2(john.x, john.y, pmo.x, pmo.y)

	john.momx = FixedMul(-16*cos(killAngle), john.scale)
	john.momy = FixedMul(-16*sin(killAngle), john.scale)
	john.momz = 16*john.scale

	S_StartSound(nil, sfx_jpilr)
	P_StartQuake(15*FU, 5*TICRATE)

	if not PTV3.pizzatime then PTV3:startPizzaTime(pmo.player, 1) end

	return true
end, MT_PTV3_PILLARJOHN)

addHook("MobjThinker", function(john)
	if not (john and john.valid) then return end
	if PTV3.pizzatime < 0 then P_RemoveMobj(john) return end

	if john.health >= 2 then
		local can_see_player = P_LookForPlayers(john, 2000*FU, true, false)
		if not can_see_player then john.target = nil end

		if john.target ~= nil then
			local p = john.target.player
			local nextstate = p.pflags & (PF_SPINNING|PF_STARTDASH|PF_JUMPED) and S_PTV3_PILLARJOHNSCARED or S_PTV3_PILLARJOHN
			if john.state ~= nextstate then john.state = nextstate end
		elseif john.state ~= S_PTV3_PILLARJOHN then
			john.state = S_PTV3_PILLARJOHN
		end
	else
		john.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT
		john.frame = P

		if john.z > john.ceilingz or (john.z+john.height) < john.floorz then
			P_RemoveMobj(john)
		end
	end
end, MT_PTV3_PILLARJOHN)

-- I don't care if it's not there in the actual gametype, I want it gone.
addHook("MobjThinker", function(sign)
	if PTV3:isPTV3() and sign and sign.valid then P_RemoveMobj(sign) end
end, MT_SIGN)