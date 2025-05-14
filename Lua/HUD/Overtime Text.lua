return function(v)
	if not PTV3:isPTV3() then return end
	if not PTV3.overtime then return end

	local tweenTime = PTV3.HUD_returnTime(PTV3.overtimeStart, TICRATE, 0, true)
	if leveltime-PTV3.overtimeStart >= 4*TICRATE then
		tweenTime = PTV3.HUD_returnTime(PTV3.overtimeStart, TICRATE, 4*TICRATE, true)
	end

	local flashTime = PTV3.HUD_returnTime(PTV3.overtimeStart, TICRATE/2, 0, true)

	v.fadeScreen(SKINCOLOR_WHITE, ease.linear(flashTime, 10, 0))

	local over = v.cachePatch("PTOVER")
	local time = v.cachePatch("PTTIME")

	local scale = FU/3

	local height = (over.height+time.height)*scale

	local screenHeight = (v.height()/v.dupy())*FU

	local topY1 = -(over.height*scale)
	local topY2 = (screenHeight/2)-(height/2)
	
	local bottomY1 = screenHeight
	local bottomY2 = ((screenHeight/2)-(height/2))+(over.height*scale)
	
	if leveltime-PTV3.overtimeStart >= 4*TICRATE then
		topY1,topY2,bottomY1,bottomY2 = $2,$1,$4,$3
	end
	
	local topTween = ease.outcubic(tweenTime, topY1, topY2)
	local bottomTween = ease.outcubic(tweenTime, bottomY1, bottomY2)

	v.drawScaled((160*FU)-(over.width*(scale/2)), topTween, scale, over, V_SNAPTOTOP)
	v.drawScaled((160*FU)-(time.width*(scale/2)), bottomTween, scale, time, V_SNAPTOTOP)
end