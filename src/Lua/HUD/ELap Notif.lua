return function(v,p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then return end
	if not (p.ptv3.extremeNotif) then return end

	v.fadeScreen(0xFF00, 12)

	local intensity = 3*FU
	local shakeX = v.RandomRange(-intensity, intensity)
	local shakeY = v.RandomRange(-intensity, intensity)

	customhud.CustomFontString(v,
		160*FU, 24*FU,
		"You are gonna be forced to do",
		"PTFNT",
		V_SNAPTOTOP,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		(160*FU)+shakeX, ((24+12)*FU)+shakeY,
		"9 consecutive Extreme Laps.",
		"PTFNT",
		V_SNAPTOTOP,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		160*FU, (12*8)*FU,
		"If Overtime starts",
		"PTFNT",
		0,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		(160*FU)+shakeX, (((12*8)+12)*FU)+shakeY,
		"You will die.",
		"PTFNT",
		0,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		160*FU, ((200-8)-12)*FU,
		"Press Fire to continue.",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
end