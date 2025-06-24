return function(v,p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then return end
	if p.ptv3.scoreReduce.time ~= nil and type(p.ptv3.scoreReduce.time) ~= "number" then return end

	local tweenTime = max(0, min(FixedDiv(leveltime-p.ptv3.scoreReduce.time, TICRATE), FU))

	local numstr = tostring(p.ptv3.scoreReduce.by)
	local patchstr = {}
	for i = 1, #numstr do -- Needs to be single integers or else it'd break
		patchstr[i] = v.cachePatch("STTNUM"+numstr:sub(i, i))
	end

	local x = ease.linear(tweenTime, 115*FU, 135*FU)
	local alphaTween = ease.linear(min(tweenTime*3/2, FU), 0, 10)
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP|(V_10TRANS*alphaTween)

	if alphaTween < 10 then
		for i = 1, #patchstr do
			if i == 1 then v.drawScaled(x, 10*FU, FU, patchstr[i], flags, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER)) end
			if i > 1 then
				v.drawScaled((x+((patchstr[i-1].width*(i-1))*FU)), 10*FU, FU, patchstr[i], flags, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER))
			end
		end
	end
end