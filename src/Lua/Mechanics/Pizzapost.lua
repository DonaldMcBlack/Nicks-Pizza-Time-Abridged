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

	if PTV3.pizzafacetps then
		table.insert(PTV3.pizzafacetps, {x=mo.x, y=mo.y, z=mo.z})
	end

    local pizzapost = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_PTV3_PIZZAPOST)
    pizzapost.angle = mo.angle

    P_RemoveMobj(mo)
end, MT_STARPOST)

local function PizzaPostActivate(post, mo)
    if not mo.player and mo.player.PTRound then return true end

    local p = mo.player

    if p.PTRound.pizzapost_id == post then return true end

    p.PTRound.pizzapost_id = post
    post.state = S_PTV3_PIZZAPOST_EXTEND

    if PTV3.pizzatime < 0 and PTV3.wartimer then
        PTV3.overtime_time = PTV3.maxottime
        PTV3.overtime_elapser = 0
        S_StartSound(nil, sfx_static)
    end
    S_StartSound(post, sfx_pizpst)
end

addHook("TouchSpecial", function(post, mo)
    PizzaPostActivate(post, mo)
    return true
end, MT_PTV3_PIZZAPOST)

addHook("MobjThinker", function(mo) -- Star Post Activator compat
    if mo.subsector.sector.flags & ~SSF_STARPOSTACTIVATOR then return end
    
    for mobj in mo.subsector.sector.thinglist() do
        if not mobj.valid or not mobj.player then continue end
        PizzaPostActivate(mo, mobj)
    end
end, MT_PTV3_PIZZAPOST)

addHook("ShouldDamage", function(target, inflictor, source, damage, damagetype)
    if not PTV3:isPTV3() then return end

	if damagetype == DMG_CRUSHED or damagetype == DMG_DEATHPIT then
		local player = target.player
		if player.playerstate == PST_LIVE then
            local post = player.PTRound.pizzapost_id
            PTV3:queueTeleport(player, (post and post.valid) and post or player.PTRound.lastTeleportDest, false)

            target.momx = 0
            target.momy = 0
            
            P_SetObjectMomZ(target, 0, false)
            P_ResetPlayer(player)

            if (post and post.valid) and (target.flags2 & MF2_OBJECTFLIP) then
                target.flags2 = P_MobjFlip(post) == -1 and $|MF2_OBJECTFLIP or $ & ~MF2_OBJECTFLIP
            end

            player.powers[pw_nocontrol] = TICRATE / 2
            P_FlashPal(player, PAL_MIXUP, 10)
            S_StartSound(target, sfx_mixup)
		end
		return false
	end
end, MT_PLAYER)