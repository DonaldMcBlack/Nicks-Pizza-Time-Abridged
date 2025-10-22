local function drawScrollingBG(v,bgp,scale)
    local width = FixedMul(bgp.width*FU, scale)
    local height = FixedMul(bgp.height*FU, scale)
    local x = leveltime % (width/FU)
    local y = leveltime % (height/FU)
    
    local screen_width = v.width()/v.dupx()*FU
    local screen_height = v.height()/v.dupy()*FU

	for w = 0,FixedDiv(screen_width+width, width)/FU do
		for h = 0,FixedDiv(screen_height+height, height)/FU do
			local badfix = 0
			if FixedMul(h*FU,height) > screen_height then
				badfix = 1/2
			end
			v.drawScaled(FixedMul(w*FU, width)-(x*FU), FixedMul(h*FU, height)-(y*FU)-(badfix*FU), scale, bgp, V_SNAPTOLEFT|V_SNAPTOTOP|V_40TRANS)
		end
	end
end

-- local ContextPage = {
-- 	{text = "Skins", state = PTV3.states.pizzatime},
-- 	{text = "Inventory", state = PTV3.states.gameplay_state}
-- }

local ContextPage = {
	{text = "Skins"},
	{text = "Inventory"}
}

return function(v,p)
    if not p.ptv3 then return end
    if not p.ptv3.menumode.inmenu or p.ptv3.menumode.menutype ~= "dresser" then return end

    drawScrollingBG(v,v.cachePatch('OPTIONBG'),FU/3)
    
    for i, sel in ipairs(ContextPage) do
        customhud.CustomFontString(v,
            (i*20)*FU, 120*FU,
            sel.text,
            "PTFNT",
            V_SNAPTOTOP,
            "center",
            FU/3,
            SKINCOLOR_WHITE
        )
    end
end