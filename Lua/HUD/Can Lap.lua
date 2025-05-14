return function(v,p)
	if not PTV3:isPTV3() then return end
	if not (p.ptv3 and p.ptv3.canLap and not (p.ptv3.extremeNotif)) then return end

	local time = (5*TICRATE)-p.ptv3.canLap

	local startTime = min(FixedDiv(time, TICRATE), FU)
	local endTime = min(FixedDiv(p.ptv3.canLap, TICRATE), FU)

	local tweenTime = min(startTime, endTime)

	local x = 160*FU
	local y = ease.outcubic(tweenTime, 200*FU, 170*FU)

	customhud.CustomFontString(v,
		x, y,
		"You can lap!",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		x, y+(10*FU),
		"Press Fire to lap before time runs out!",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
end