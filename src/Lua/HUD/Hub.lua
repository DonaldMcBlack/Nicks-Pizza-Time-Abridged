return function(v, p)
    if not PTV3:isPTV3() then return end
    if gamemap ~= M_MapNumber("PT") then return end
	if not multiplayer then return end

	local timer_colour = SKINCOLOR_BLACK

	for _, gate in ipairs(PTV3_HUB.gates) do
		if gate.votes then timer_colour = SKINCOLOR_WHITE break end
	end

    customhud.CustomFontString(v,
		160*FU, 24*FU,
		tostring(G_TicsToSeconds(PTV3.votetime)),
		"PTFNT",
		V_SNAPTOTOP,
		"center",
		FU/3,
		timer_colour
	)
end