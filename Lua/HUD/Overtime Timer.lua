return function(v)
	if not PTV3:isPTV3() then return end
	if not (PTV3.pizzatime or PTV3.minusworld) then return end
	if not PTV3.overtime then return end

	-- explosion
	local expFrames = 17
	local expTime = min((leveltime-PTV3.overtimeStart)/3, expFrames)
	if expTime ~= expFrames then
		local b = v.cachePatch("PIZZABAR")
		local explode = v.cachePatch("EXPLODE"..expTime)
		local scale = FU/3

		local hscale = FixedMul(FixedDiv(b.width*2, explode.width), scale)
		local vscale = FixedMul(FU*3/2, scale)

		v.drawStretched(160*FU-(explode.width*(hscale/2)), 180*FU+(b.height*((FU/3)/2)-(explode.height*(vscale/2))), hscale, vscale, explode, V_SNAPTOBOTTOM)
	end

	-- war timer
	local tweenTime = PTV3.HUD_returnTime(PTV3.overtimeStart, TICRATE, TICRATE, true)
	local timer = v.cachePatch("WARALAR1")

	local scale = FU/3
	local tweenY = ease.linear(tweenTime, 0, -timer.height*scale)

	local x = 160*FU-(timer.width*(scale/2))
	local y = (200*FU)+tweenY

	v.drawScaled(x, y, scale, timer, V_SNAPTOBOTTOM)

	-- text

	local text = ("%02d %02d"):format(
		G_TicsToMinutes(PTV3.overtime_time),
		G_TicsToSeconds(PTV3.overtime_time)
	)

	customhud.CustomFontString(v,
		x+(100*scale), y+(50*scale),
		text,
		"WARFN",
		V_SNAPTOBOTTOM,
		"left",
		scale,
		SKINCOLOR_RED
	)
end