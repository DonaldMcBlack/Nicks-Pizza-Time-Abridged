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

	local total = v.cachePatch("RINGTOTAL"..(leveltime/10) % 3)

	local x, y = 5*FU, 5*FU
	local scale = FU/3

	v.drawScaled(x, y, scale, total, V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP)

	customhud.CustomFontString(v,
		x+(total.width*(scale/2))+3*FU, y+((total.height*scale)/3)+5*FU,
		tostring(p.PTGlobal.ringBank),
		"PTFNT",
		V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS,
		"center",
		FU/3,
		SKINCOLOR_WHITE
	)
end