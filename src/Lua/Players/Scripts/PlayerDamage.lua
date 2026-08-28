addHook('MobjDamage', function(mo, enemy)
	if not PTV3:isPTV3() then return end
	if not (mo and mo.valid and mo.player) then return end

	local p = mo.player
	p.score = max($-250, 0)

	if p.PTRound.isTaunting then return true end
	if not p.rings then P_DoPlayerPain(p) return true end
end, MT_PLAYER)