freeslot("SPR_PIPT")
freeslot("MT_PTV3_PIZZAPOST", "S_PTV3_PIZZAPOST_IDLE", "S_PTV3_PIZZAPOST_FLASH", "S_PTV3_PIZZAPOST_EXTEND")
sfxinfo[freeslot "sfx_pizpst"].caption = "Pizzapost"

states[S_PTV3_PIZZAPOST_IDLE] = {
	sprite = SPR_PIPT,
	frame = A,
    tics = -1,
    nextstate = S_NULL
}

states[S_PTV3_PIZZAPOST_FLASH] = {
    sprite = SPR_PIPT,
    frame = I|FF_ANIMATE,
    tics = -1,
    var1 = 1,
    var2 = 5,
    nextstate = S_NULL
}

states[S_PTV3_PIZZAPOST_EXTEND] = {
    sprite = SPR_PIPT,
    frame = A|FF_ANIMATE,
    tics = 8,
    var1 = 7,
    var2 = 1,
    nextstate = S_PTV3_PIZZAPOST_FLASH
}

mobjinfo[MT_PTV3_PIZZAPOST] = {
	spawnstate = S_PTV3_PIZZAPOST_IDLE,
    painsound = sfx_strpst,
    spawnhealth = 1,
    reactiontime = 8,
    speed = 8,
	radius = 64*FU,
	height = 80*FU,
    mass = 4,
	flags = MF_SPECIAL
}

addHook("MobjSpawn", function(mo)
	if not PTV3:isPTV3() then return end

	table.insert(PTV3.pizzafacetps, {x=mo.x, y=mo.y, z=mo.z})

    local pizzapost = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_PTV3_PIZZAPOST)
    pizzapost.angle = mo.angle

    P_RemoveMobj(mo)
end, MT_STARPOST)

addHook("TouchSpecial", function(post, mo)
    if not mo.player and mo.player.PTRound then return true end

    local p = mo.player

    if p.PTRound.pizzapost_id == post then return true end

    p.PTRound.pizzapost_id = post
    post.state = S_PTV3_PIZZAPOST_EXTEND
    S_StartSound(post, sfx_pizpst)

    return true
end, MT_PTV3_PIZZAPOST)

addHook("ShouldDamage", function(target, inflictor, source, damage, damagetype)
    if not PTV3:isPTV3() then return end

	if damagetype == DMG_CRUSHED or damagetype == DMG_DEATHPIT then
		local player = target.player
		if player.playerstate == PST_LIVE then
            if player.PTRound.pizzapost_id then
                local post = player.PTRound.pizzapost_id
                P_SetOrigin(target, post.x, post.y, post.z)
                target.angle = post.angle
            else return true
            end
            target.momx = 0
            target.momy = 0
            P_SetObjectMomZ(target, 0, false)
            P_ResetPlayer(player)

            player.powers[pw_nocontrol] = TICRATE / 2
            P_FlashPal(player, PAL_MIXUP, 10)
            S_StartSound(target, sfx_mixup)
		end
		return false
	end
end, MT_PLAYER)