return function(v,p)
	if not PTV3:isPTV3() then return end
	if p.PTRound.chaser then return end
	if gamemap == M_MapNumber("PT") then return end

	local rank = PTV3.ranks[p.PTRound.rank]
	local rank_patch = gametype == GT_PTV3DM and "DM_"..rank.rank.."RANK" or "PT_"..rank.rank.."RANK"
	local rankfill_patch = gametype == GT_PTV3DM and "DM_"..rank.rank.."FILL" or "PT_"..rank.rank.."FILL"

	rank_patch = v.cachePatch(rank_patch)

	local x = 48*FU
	local y = 68*FU
	local s = FU/3
	
	if p.PTRound.rank_changetime >= 0 then
		local time = PTV3.HUD_returnTime(p.PTRound.rank_changetime, FU/8)

		if time < FU then
			s = ease.linear(time, FU/2, FU/3)
		end
	end

	x, y = $-((rank_patch.width/2)*s), $-((rank_patch.width/2)*s)

	v.drawScaled(x, y, s, rank_patch, V_SNAPTOLEFT|V_SNAPTOTOP)

	if rank.fill then
		local percent = PTV3:returnNextRankPercent(p)
		if percent == 0 then return end

		y = y+(rank_patch.height*s)-(rank_patch.height*FixedMul(percent, s))
		
		local croph = FixedMul(rank_patch.height*FU, max(0,percent))
		local cropy = (rank_patch.height*FU)-croph
		
		if cropy < 0 then cropy = FU end

		v.drawCropped(
			x, y,
			s, s,
			v.cachePatch(rankfill_patch),
			V_SNAPTOLEFT|V_SNAPTOTOP, nil,
			0, cropy,
			rank_patch.width*FU,
			croph
		)
	end
end