return function(v,p)
	if not PTV3:isPTV3() then return end
	if not PTV3.pizzatime then return end
	if type(p.ptv3.scoreReduce) ~= "number" then return end

	local tweenTime = max(0, min(FixedDiv(leveltime-p.ptv3.scoreReduce, TICRATE), FU))

	local one = v.cachePatch("STTNUM1")
	local zero = v.cachePatch("STTNUM0")
	if PTV3.overtime then
		one = v.cachePatch("STTNUM4")
		zero = v.cachePatch("STTNUM5")
	elseif p.ptv3.extreme then
		one = v.cachePatch("STTNUM2")
		zero = v.cachePatch("STTNUM0")
	else
		one = v.cachePatch("STTNUM1")
		zero = v.cachePatch("STTNUM0")
	end

	local x = ease.linear(tweenTime, 105*FU, 125*FU)
	local alphaTween = ease.linear(min(tweenTime*3/2, FU), 0, 10)
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP|(V_10TRANS*alphaTween)

	if alphaTween < 10 then
		v.drawScaled(x, 10*FU, FU, one, flags, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER))
		v.drawScaled(x+(one.width*FU), 10*FU, FU, zero, flags, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER))
	end
end