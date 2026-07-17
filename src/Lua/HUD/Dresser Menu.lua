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

local ContextPage = {
	{text = "Skins",},
	{text = "Inventory"}
}

local Pages = {
    ['dresser'] = {
        ['accept'] = { [1] = "skins", [2] = "inventory"},
        ['decline'] = false
    },
    ['skins'] = {
        ['decline'] = "dresser"
    },
    ['inventory'] = {
        ['decline'] = "dresser"
    }
}

local function len(t)
    local count = 0
    for _ in pairs(t) do
        count = $+1
    end
    print(count)
    return count
end

local function drawPage_Dresser(v, p)
    if p.PTGlobal.menumode.menutype ~= "dresser" then return end
    
    for i, sel in ipairs(ContextPage) do
        customhud.CustomFontString(v,
            (i*100)*FU, 120*FU,
            sel.text,
            "PTFNT",
            V_SNAPTOTOP,
            "center",
            FU/3,
            p.PTGlobal.menumode.selection == i and SKINCOLOR_WHITE or SKINCOLOR_BLACK
        )
    end
end

local chasers = { "pizzaface", "snick", "john" }

local function drawPage_Skins(v, p)
    if p.PTGlobal.menumode.menutype ~= "skins" then return end

    local screenWidth = v.width() * FU / v.dupx()
	local screenHeight = v.height() * FU / v.dupy()

    local i = 0

    while i < #PTV3_SKINS do
        for j, skin in ipairs(PTV3_SKINS[chasers[i]]) do
            print(skin.name)
        end

        i = $+1
    end

    for i in ipairs(chasers) do
        for j, skin in ipairs(PTV3_SKINS[i]) do
            print(chasers[i].."skin:".." "..skin[0].name)

            local list_x = i*32*FU
            local list_y = screenHeight/(i*5)
            local scale = FU-(FU/(i*9))

            local chaser_portrait = v.cachePatch("CS_"..skin[j].name)

            v.drawFill(25, 0, chaser_portrait.width, screenHeight, 35|V_SNAPTOLEFT|V_SNAPTOTOP)
            v.drawFill(0, 80, v.width(), chaser_portrait.height, 35|V_SNAPTOLEFT|V_SNAPTOTOP)
            v.drawScaled(list_x, list_y, scale, chaser_portrait, V_SNAPTOLEFT)

            if i == 0 then
                local intensity = 2*FU
                local shakeX = v.RandomRange(-intensity, intensity)
                local shakeY = v.RandomRange(-intensity, intensity)

                
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
        end
    end

    
	
	
    -- local chaser_portY = chaser_portrait.height
	
	


end

return function(v,p)
    if not p.PTRound then return end
    if not p.PTGlobal.menumode.inmenu then return end

    drawScrollingBG(v,v.cachePatch('OPTIONBG'),FU/3)

    drawPage_Dresser(v, p)
    drawPage_Skins(v, p)

    if p.PTGlobal.sidemove < 0 and p.PTGlobal.lastsidemove >= 0 then
        local length = len(Pages[p.PTGlobal.menumode.menutype]['accept'])
        p.PTGlobal.menumode.selection = ($-1) <= 0 and length or $-1
        print(p.PTGlobal.menumode.selection)
    end
    if p.PTGlobal.sidemove > 0 and p.PTGlobal.lastsidemove <= 0 then
        local length = len(Pages[p.PTGlobal.menumode.menutype]['accept'])
        p.PTGlobal.menumode.selection = ($+1) >= length and 1 or $+1
        print(p.PTGlobal.menumode.selection)
    end

    if (p.PTGlobal.buttons & BT_JUMP) and not (p.PTGlobal.lastbuttons & BT_JUMP) then
        S_StartSound(nil, sfx_addfil, p)
        p.PTGlobal.menumode.menutype = Pages[$]['accept'][p.PTGlobal.menumode.selection]
        p.PTGlobal.menumode.selection = 1
    end

    if (p.PTGlobal.buttons & BT_SPIN) and not (p.PTGlobal.lastbuttons & BT_SPIN) then
        S_StartSound(nil, sfx_adderr, p)

        if p.PTGlobal.menumode.menutype == "dresser" then
            p.PTGlobal.menumode.inmenu = false
        else
            p.PTGlobal.menumode.menutype = Pages[$]['decline']
        end
        p.PTGlobal.menumode.selection = 1
    end
end