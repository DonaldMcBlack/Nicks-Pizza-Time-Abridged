return function(v,p)
	if not multiplayer or PTV3.game_over then return end
	if not (p and p.PTRound and p.PTRound.specforce and PTV3.snick and PTV3.snick.valid and not PTV3.snick.PTRound) then return end

	customhud.CustomFontString(v,
		160*FU, 175*FU,
		"Press fire to respawn as Snick.",
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		FU/3
	)
end