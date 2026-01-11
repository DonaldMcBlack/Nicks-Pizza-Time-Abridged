local time = 0

return function(v)
	if not PTV3:isPTV3() then return end
	if not PTV3.wartimer then return end

	if PTV3.overtime then
		-- explosion
		local expFrames = 17
		local expTime = min((leveltime-PTV3.wartimerStart)/3, expFrames)
		if expTime ~= expFrames then
			local b = v.cachePatch("PIZZABAR")
			local explode = v.cachePatch("EXPLODE"..expTime)
			local scale = FU/3

			local hscale = FixedMul(FixedDiv(b.width*2, explode.width), scale)
			local vscale = FixedMul(FU*3/2, scale)

			v.drawStretched(160*FU-(explode.width*(hscale/2)), 180*FU+(b.height*((FU/3)/2)-(explode.height*(vscale/2))), hscale, vscale, explode, V_SNAPTOBOTTOM)
		end
	end

	-- war timer
	if not time or time > PTV3.overtime_time then time = PTV3.overtime_time end

	local timer_colour = SKINCOLOR_RED
	local timer = v.cachePatch("WARALAR1")

	if time < PTV3.overtime_time then
		time = min($+24, PTV3.overtime_time) or $
		timer_colour = SKINCOLOR_GREEN
		timer = v.cachePatch("WARALAR2")
	end
	local tweenTime = PTV3.HUD_returnTime(PTV3.wartimerStart, TICRATE, TICRATE, true)
	

	local scale = FU/3
	local tweenY = ease.linear(tweenTime, 0, -timer.height*scale)

	local x = 160*FU-(timer.width*(scale/2))
	local y = (200*FU)+tweenY

	if time <= 5*TICRATE then
		local maxTime = min(PTV3.maxotTime, 5*TICRATE)
		local shakePerc = FixedDiv(maxTime-time, maxTime)*6

		if time > 0 then
			x = $+v.RandomRange(-shakePerc, shakePerc)
			y = $+v.RandomRange(-shakePerc, shakePerc)
		end

		v.fadeScreen(0xFB00, ease.linear(shakePerc/3, 0, 31/2))
	end

	v.drawScaled(x, y, scale, timer, V_SNAPTOBOTTOM)

	-- text

	local text = ("%02d %02d"):format(
		G_TicsToMinutes(time),
		G_TicsToSeconds(time)
	)

	customhud.CustomFontString(v,
		x+(100*scale), y+(50*scale),
		text,
		"WARFN",
		V_SNAPTOBOTTOM,
		"left",
		scale,
		timer_colour
	)
end