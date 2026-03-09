addHook('MobjDamage', function(mo, enemy)
	if not PTV3:isPTV3() then return end
	if not mo.player then return end

	mo.player.score = max($-250, 0)

	if enemy.valid and enemy.type ~= MT_PTV3_PIZZAFACE 
	and not mo.player.rings then P_DoPlayerPain(mo.player) return true end
end, MT_PLAYER)