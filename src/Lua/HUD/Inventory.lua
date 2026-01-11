return function(v,p)
	if not p.mo then return end
	if not p.ptv3 then return end
	if gamemap == M_MapNumber("PT") then return end

	local x = 16*FU
	local y = (42+16)*FU
	local s = FU/2
	
	v.drawScaled(x, y, s, v.cachePatch("PTINVEN"), V_SNAPTOLEFT|V_SNAPTOTOP)
	if p.ptv3.curItem then
		local item = PTV3.items[p.ptv3.curItem].graphic
		local x = item.offset_x and x+item.offset_x or x
		local y = item.offset_y and y+item.offset_y or y
		local s = FixedMul(s, item.scale) or s
		local patch = v.cachePatch(item.name)

		local flags = p.ptv3.curItem_equipped == true and V_SNAPTOTOP|V_SNAPTOLEFT|V_MODULATE or V_SNAPTOTOP|V_SNAPTOLEFT

		v.drawScaled(x, y, s, patch, flags)
	end
end