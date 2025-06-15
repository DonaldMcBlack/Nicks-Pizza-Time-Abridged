addHook('MobjDamage', function(mo)
	if not PTV3:isPTV3() then return end
	if not mo.player then return end

	mo.player.score = max($-250, 0)
end, MT_PLAYER)