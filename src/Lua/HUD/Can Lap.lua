return function(v,p)
	if not PTV3:isPTV3() then return end
	if not (p.PTRound and p.PTRound.canLap and not (p.PTRound.extremeNotif)) then return end

	local time = (5*TICRATE)-p.PTRound.canLap

	local startTime = min(FixedDiv(time, TICRATE), FU)
	local endTime = min(FixedDiv(p.PTRound.canLap, TICRATE), FU)

	local tweenTime = min(startTime, endTime)

	local x = 160*FU
	local y = ease.outcubic(tweenTime, 200*FU, 170*FU)

	customhud.CustomFontString(v,
		x, y,
		"You can lap!",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3,
		SKINCOLOR_WHITE
	)
	customhud.CustomFontString(v,
		x, y+(10*FU),
		"Press Fire to lap before time runs out!",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3,
		SKINCOLOR_WHITE
	)
end