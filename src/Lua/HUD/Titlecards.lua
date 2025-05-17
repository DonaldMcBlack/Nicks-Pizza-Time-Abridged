local screenFadeTime = TICRATE/4
local fadeTime = TICRATE/2

return function(v)
	if not PTV3:isPTV3() then return end
	if not (PTV3.titlecards[gamemap]) then return end

	-- fade the screen
	local tweenTime = min(
		FixedDiv(
			max(0, leveltime-PTV3.maxTitlecardTime),
			fadeTime
		),
		FU
	)

	local fadeStuff = ease.linear(tweenTime, 32, 0)

	v.fadeScreen(0xFF00, min(fadeStuff, 31))
	if fadeStuff == 32 then
		v.drawFill()
	end

	local titlecard = v.cachePatch(PTV3.titlecards[gamemap].g)

	local scale = FixedDiv(v.height()/v.dupy(), titlecard.height)

	local startTweenTime = min(FixedDiv(leveltime, fadeTime), FU)
	local endTweenTime = min(FixedDiv(max(0, PTV3.maxTitlecardTime-leveltime), fadeTime), FU)

	local tweenTime = min(startTweenTime, endTweenTime)

	local tween = ease.linear(tweenTime, 10, 0)

	local alpha = V_10TRANS*tween
	local flags = V_SNAPTOTOP|alpha

	if tween < 10 then
		local color
		if gametype == GT_PTV3DM then
			color = v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
		end
		v.drawStretched(160*FU-(titlecard.width*(scale/2)),0, scale, scale, titlecard, flags, color)
		if gametype == GT_PTV3DM then
			local shakeX = v.RandomRange(-2*FU, 2*FU)
			local shakeY = v.RandomRange(-2*FU, 2*FU)
			customhud.CustomFontString(v,
				(160*FU)+shakeX, ((200-20)*FU)+shakeY,
				"Death Mode",
				"PTFNT",
				V_SNAPTOBOTTOM,
				"center",
				FU/3
			)
			customhud.CustomFontString(v,
				(160*FU)+shakeX, ((200-10)*FU)+shakeY,
				"Last person standing wins.",
				"PTFNT",
				V_SNAPTOBOTTOM,
				"center",
				FU/3
			)
		end
	end
end