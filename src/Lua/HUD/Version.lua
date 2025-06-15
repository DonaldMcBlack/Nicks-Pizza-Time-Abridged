return function(v)
    local versionNotif = "This is an indev build. Do NOT distribute."

    customhud.CustomFontString(v,
		(160*FU), FU,
		versionNotif,
		"STCFN",
		V_SNAPTOTOP|V_50TRANS,
		"center",
		FU/2,
        SKINCOLOR_WHITE
	)
end