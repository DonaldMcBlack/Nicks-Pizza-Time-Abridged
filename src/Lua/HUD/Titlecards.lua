local function GetSnap(string)
	if type(string) ~= "string" then return string end

	if string == "top" then return V_SNAPTOTOP end
	if string == "bottom" then return V_SNAPTOBOTTOM end
	if string == "left" then return V_SNAPTOLEFT end
	if string == "right" then return V_SNAPTORIGHT end

	return nil
end

return function(v)
	if not PTV3:isPTV3() then return end
	if gamemap == M_MapNumber("PT") then return end
	
	local titlecard = v.patchExists(PTV3.titlecard_bg) and v.cachePatch(PTV3.titlecard_bg) or v.cachePatch("PLACETC")
	local titlecard_name = v.patchExists(PTV3.titlecard_name) and v.cachePatch(PTV3.titlecard_name) or v.cachePatch("PLACETT")

	local x = (mapheaderinfo[gamemap].ptv3_titlecard_x or 300)*FU
	local y = (mapheaderinfo[gamemap].ptv3_titlecard_y or 160)*FU
	local snap = mapheaderinfo[gamemap].ptv3_titlecard_snap or V_SNAPTOBOTTOM|V_SNAPTORIGHT

	-- fade the screen
	local fadeTime = TICRATE/2
	local tweenTime = min(FixedDiv(max(0, leveltime-PTV3.maxTitlecardTime), fadeTime), FU)

	local fadeStuff = ease.linear(tweenTime, 32, 0)

	v.fadeScreen(0xFF00, min(fadeStuff, 31))
	if fadeStuff == 32 then v.drawFill() end

	local scale = FixedDiv(v.height()/v.dupy(), titlecard.height)

	local startTweenTime = min(FixedDiv(leveltime, fadeTime), FU)
	local endTweenTime = min(FixedDiv(max(0, PTV3.maxTitlecardTime-leveltime), fadeTime), FU)

	tweenTime = min(startTweenTime, endTweenTime)

	local tween = ease.linear(tweenTime, 10, 0)

	local alpha = V_10TRANS*tween
	local flags = V_SNAPTOTOP|alpha

	if tween < 10 then
		local color
		local shakeX, shakeY = v.RandomRange(-1*FU, 1*FU), v.RandomRange(-1*FU, 1*FU)

		if gametype == GT_PTV3DM then
			color = v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
		end
		v.drawStretched(140*FU-(titlecard.width*(scale/2)),0, FU/16+scale, scale, titlecard, flags, color)

		flags = $|GetSnap(snap)

		v.drawStretched((x+shakeX)-(titlecard.width*(scale/2)), y+shakeY, FU/3+(scale/8), FU/3+(scale/8), titlecard_name, flags, color)

		if gametype == GT_PTV3DM then
			shakeX, shakeY = v.RandomRange(-2*FU, 2*FU), v.RandomRange(-2*FU, 2*FU)
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