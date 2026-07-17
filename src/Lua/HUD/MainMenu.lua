local function DrawTitle(v)
    if not titlemapinaction then return end

    -- local wid = v.width()*FU/v.dupx()
	local hei = v.height()*FU/v.dupy()
    local logo = v.cachePatch('PTTITLE')
    local y = hei/2 - logo.height*FU/3

    v.drawScaled(60*FU, y, FU/2, logo, V_SNAPTOTOP)
    S_ChangeMusic("TITLEB", true)
end

-- return function(v)
-- 	local hei = v.height()*FU/v.dupy()
--     local logo = v.cachePatch('PTTITLE')
--     local y = hei/2 - logo.height*FU/3

--     v.drawScaled(70*FU, y, FU/2, logo, V_SNAPTOTOP)
-- end

hud.add(DrawTitle)
hud.add(DrawTitle, 'title')