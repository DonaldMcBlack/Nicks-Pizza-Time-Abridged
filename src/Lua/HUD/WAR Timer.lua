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
	local patchname = PTV3.pizzatime < 0 and "MARIDLE" or "WARRED"
	local timer_colour = SKINCOLOR_RED

	if time <= 10*TICRATE then
		patchname = (PTV3.pizzatime < 0 and "MARPANIC" or "WARPANIC") + leveltime % 3
	end

	if PTV3.pizzatime < 0 then
		if time < PTV3.overtime_time then
			time = min($+72, PTV3.overtime_time) or $
			patchname = "MARADD" + leveltime % 3
		end
	else
		if time < PTV3.overtime_time then
			time = min($+24, PTV3.overtime_time) or $
			timer_colour = SKINCOLOR_GREEN
			patchname = "WARGREEN"
		end
	end
	

	local timer = v.cachePatch(patchname)
	local tweenTime = PTV3.HUD_returnTime(PTV3.wartimerStart, TICRATE, TICRATE, true)

	local scale = FU/3
	local tweenY = ease.linear(tweenTime, 0, -timer.height*scale)

	local x = 160*FU-(timer.width*(scale/2))
	local y = (200*FU)+tweenY

	if time <= 5*TICRATE then
		local maxTime = min(PTV3.maxottime, 5*TICRATE)
		local shakePerc = FixedDiv(maxTime-time, maxTime)*6

		if time > 0 then
			x = $+v.RandomRange(-shakePerc, shakePerc)
			y = $+v.RandomRange(-shakePerc, shakePerc)
		end

		v.fadeScreen(0xFB00, ease.linear(shakePerc/3, 0, 31/2))
	end

	v.drawScaled(x, y, scale, timer, V_SNAPTOBOTTOM)

	if PTV3.pizzatime < 0 and time < PTV3.overtime_time then return end

	-- text
	local text = PTV3.pizzatime < 0 and ("%02d %02d"):format(G_TicsToSeconds(time), G_TicsToCentiseconds(time)) or ("%02d %02d"):format(G_TicsToMinutes(time), G_TicsToSeconds(time))

	local font = PTV3.pizzatime < 0 and "MARFN" or "WARFN"

	if PTV3.pizzatime < 0 then
		local shakePerc = (PTV3.overtime_elapser/TICRATE)*FU/2

		if time > 0 then
			x = $+v.RandomRange(-shakePerc, shakePerc)
			y = $+v.RandomRange(-shakePerc, shakePerc)
		end
	end

	customhud.CustomFontString(v,
		x+(100*scale), y+(65*scale),
		text,
		font,
		V_SNAPTOBOTTOM,
		"left",
		scale,
		timer_colour
	)
end