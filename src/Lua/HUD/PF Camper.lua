return function(v,p)
	if not PTV3:isPTV3() then return end
	if not (p and p.ptv3 and p.ptv3.camper) then return end

	local x = 160*FU
	local y = 170*FU

	customhud.CustomFontString(v,
		x, y,
		"You have been caught camping!",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
	customhud.CustomFontString(v,
		x, y+(10*FU),
		"Move away to be able to kill players again.",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
end