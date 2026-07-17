return function(v,p)
	if not p.mo then return end
	if not p.PTRound then return end
	if gamemap == M_MapNumber("PT") then return end

	local x = 16*FU
	local y = (42+16)*FU
	local s = FU/2

	local flags = p.PTGlobal.curItem == nil and V_50TRANS|V_SNAPTOLEFT|V_SNAPTOTOP or V_SNAPTOLEFT|V_SNAPTOTOP
	
	v.drawScaled(x, y, s, v.cachePatch("PTINVEN"), flags)
	if p.PTGlobal.curItem then
		local item = PTV3.items[p.PTGlobal.curItem].graphic
		x = item.offset_x and x+item.offset_x or x
		y = item.offset_y and y+item.offset_y or y
		s = FixedMul(s, item.scale) or s
		local patch = v.cachePatch(item.name)

		flags = p.PTRound.curItem_equipped == true and V_SNAPTOTOP|V_SNAPTOLEFT|V_MODULATE or V_SNAPTOTOP|V_SNAPTOLEFT

		v.drawScaled(x, y, s, patch, flags)
	end
end