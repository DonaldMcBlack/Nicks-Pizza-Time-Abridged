local frame = 1
local tics = 0
return function(v)
	if not PTV3:isPTV3() then return end
	if PTV3.game_over >= (21*TICRATE)-10 then tics = 0 return end
	
	tics = $+1
	local sw = FixedDiv(v.width()*FU, v.dupx()*FU)
	local sh = FixedDiv(v.height()*FU, v.dupy()*FU)

	local time = PTV3.HUD_returnTime(PTV3.game_over, TICRATE/2, TICRATE, true)
	local tween = ease.linear(time, -1*sh, sh/2-(4*FU))

	if leveltime % 2 then
		if tween == sh/2-(4*FU) then
			frame = min($+frame, 9)
			if frame == 2 then S_StartSound(nil, sfx_dmpain) end
		else 
			frame = 1
		end
	end
	local timeup = v.cachePatch("TIMESUP"..frame)

	v.drawScaled(sw/4-(FU*4), tween, FU/4, timeup, V_SNAPTOTOP)
end