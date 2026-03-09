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

local function drawPage_Dresser(v, p)
    if p.PTGlobal.menumode.menutype ~= "dresser" then return end
    
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

local function drawPage_Skins(v, p)
    if p.PTGlobal.menumode.menutype ~= "skins" then return end

    local screenWidth = v.width() * FU / v.dupx()
	local screenHeight = v.height() * FU / v.dupy()

    local chaserlist = {}

    for i, chaser in ipairs(PTV3_SKINS) do
        print(chaser[0].name)
        chaserlist[i] = chaser[0].name
    end

    local list_x = 32*FU
	local list_y = screenHeight/5
	local scale = FU-(FU/9)
	
	local intensity = 2*FU
	local shakeX = v.RandomRange(-intensity, intensity)
	local shakeY = v.RandomRange(-intensity, intensity)

    local chaser_portrait = v.cachePatch("CS_PIZZAFACE")
    local chaser_portY = chaser_portrait.height
	
	v.drawFill(25, 0, chaser_portrait.width, screenHeight, 35|V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawFill(0, 80, v.width(), chaser_portrait.height, 35|V_SNAPTOLEFT|V_SNAPTOTOP)

    v.drawScaled(list_x, list_y, scale, chaser_portrait, V_SNAPTOLEFT)
    customhud.CustomFontString(v,
        (list_x+(chaser_portrait.width/2)*scale)+shakeX, (list_y+(chaser_portrait.height)*scale)+shakeY,
        "Pizzaface",
        "PTFNT",
        V_SNAPTOLEFT,
        "center",
        FU/2,
        SKINCOLOR_WHITE
    )
end

return function(v,p)
    if not p.PTRound then return end
    if not p.PTGlobal.menumode.inmenu then return end

    drawScrollingBG(v,v.cachePatch('OPTIONBG'),FU/3)

    drawPage_Dresser(v, p)
    drawPage_Skins(v, p)
end