return function(p)

    -- Freeflow
    if p.PTRound.freeflow > 9*TICRATE then
        local circle = P_SpawnMobjFromMobj(p.mo, 0, 0, p.mo.scale * (p.mo.height/2), MT_THOK)
        circle.fuse = 7
        circle.scale = p.mo.scale
        circle.destscale = FU/5
        circle.colorized = true
        circle.color = p.mo.color
        circle.momx = -p.mo.momx / 2
        circle.momy = -p.mo.momy / 2
    end

    p.fovadd = (p.PTRound.freeflow >= 5*TICRATE) and (p.PTRound.freeflow - 5*TICRATE)*FU/10 or 0

    -- Escape Tilt
    if not PTV3.pizzatime or not PTV3.starttime_pizzatime then return end

    if (PTV3.extreme or PTV3.overtime) and not S_SoundPlaying(consoleplayer.mo, sfx_rumble) then S_StartSound(consoleplayer.mo, sfx_rumble, consoleplayer) end

    P_StartQuake(PTV3.shakeintensity*FU, 2)

    -- local fxTimer = max(0, leveltime-PTV3.starttime_pizzatime)
	-- local tiltSpeed = 24

    -- local div = (FU/(TICRATE*(tiltSpeed/2))) * ( (fxTimer % (TICRATE*tiltSpeed)) - max(0, (fxTimer % (TICRATE*tiltSpeed)) - (TICRATE*(tiltSpeed/2))) * 2 )
    -- p.viewrollangle = ease.inoutquad(div, ANG1 * (PTV3.shakeintensity*FU)/3, -ANG1 * (PTV3.shakeintensity*FU)/3)
end