freeslot("sfx_spnsd0", "sfx_spnsd1", "sfx_spnsd3", "sfx_spnsd4", "sfx_spnsd5", "sfx_spnsd6", "sfx_spnsd7")
freeslot("sfx_snsed0", "sfx_snsed1", "sfx_snsed2")

addHook("MobjMoveBlocked", function(pmo, thing, line)
	if (pmo and pmo.valid) and pmo.player and pmo.player.PTRound then
		local p = pmo.player

		if p.PTRound.ragdoll and p.playerstate ~= PST_DEAD then
			P_BounceMove(pmo)
			S_StartSound(pmo, P_RandomRange(sfx_spnsd0,sfx_spnsd7))
			pmo.momx = 3*$/2
			pmo.momy = 3*$/2
		end
	end
end, MT_PLAYER)

return function(p)
    if p.PTRound.ragdoll then
        p.pflags = $|PF_FULLSTASIS

        local mo = p.mo

        if P_IsObjectOnGround(mo) then
            if p.PTRound.ragdoll_bounces then
                mo.momz = (p.PTRound.ragdoll_bounces*8)*(FU*P_MobjFlip(mo))
                mo.state = S_PLAY_PAIN
                S_StartSound(mo, P_RandomRange(sfx_spnsd0, sfx_spnsd7))
				p.PTRound.ragdoll_bounces = $-1
            else
                p.PTRound.ragdoll = max($-1, 1)
                if mo.state ~= S_PLAY_DEAD then
                    mo.state = S_PLAY_DEAD
                    S_StartSound(p.mo, P_RandomRange(sfx_snsed0, sfx_snsed2))
                end

                if p.PTRound.ragdoll == 1 then
                    p.PTRound.ragdoll = 0
                    p.pflags = $ & ~PF_FULLSTASIS
                    P_DoJump(p, true)
                    return
                end
            end
        else
            mo.state = S_PLAY_PAIN

            if abs(mo.momz) > 24*FU then p.PTRound.ragdoll_bounces = 2 end
        end
    else
        p.PTRound.ragdoll_bounces = 1
    end
end