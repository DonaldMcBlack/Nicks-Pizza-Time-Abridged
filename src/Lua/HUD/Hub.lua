return function(v, p)
    if not PTV3:isPTV3() then return end
    if gamemap ~= M_MapNumber("PT") then return end
	if not multiplayer then return end

    customhud.CustomFontString(v,
		160*FU, 24*FU,
		tostring(PTV3.votetime),
		"PTFNT",
		V_SNAPTOTOP,
		"center",
		FU/3,
		SKINCOLOR_WHITE
	)
end