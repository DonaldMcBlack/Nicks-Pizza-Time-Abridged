return function(v,p)
	if not (p and p.ptv3 and p.ptv3.specforce and PTV3.snick and PTV3.snick.valid and not PTV3.snick.ptv3) then return end

	customhud.CustomFontString(v,
		160*FU, 175*FU,
		"Press fire to respawn as Snick.",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
end