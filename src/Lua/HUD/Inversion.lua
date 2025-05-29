return function(v)
	if not PTV3.minusworld and PTV3.pizzatime then return end
    if PTV3.hud_pt < 0 then return end
    local rendoption = v.renderer()
	
	local patch = v.cachePatch('TRANSFG')
	local scale = (v.height()/v.dupx())*FU

    if rendoption == "opengl" then
        v.drawScaled(0,0,scale,patch,V_SNAPTOTOP|V_SNAPTOLEFT|V_SUBTRACT|TR_TRANS20)
    end
end