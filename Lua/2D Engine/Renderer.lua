local dh = dofile "2D Engine/Backend/DrawHelper"

local function renderObjects(v)
	if not PTV3_2D:canRun() then return end

	v.drawFill()

	for y,_ in pairs(PTV3_2D.map.tiles) do
		for x,t in pairs(_) do
			local x = (x*32)*FU
			local y = (y*32)*FU

			local patch = v.cachePatch("JOHNTILES")

			dh:drawCropped(v, x, y, FU, FU, patch, nil, nil, t.x*FU, t.y*FU, t.w*FU, t.h*FU)
		end
	end

	for _,obj in pairs(PTV3_2D.objects) do
		local refObj = PTV3_2D:getRefObj(obj)
		
		refObj.draw(obj, v, dh)
	end

	for p in players.iterate do
		if not (p and p.ptv3_2d) then continue end
		local p2d = p.ptv3_2d

		local flags
		if p2d.dir >= 0 then
			flags = V_FLIP
		end

		local sprite = v.getSprite2Patch(p.mo and p.mo.skin or p.skin, p2d.display.spr2, false, p2d.display.frame, 3)

		local x = p2d.x+(p2d.width/2)
		local y = p2d.y+p2d.height

		dh:drawScaled(v, x, y, FU, sprite, flags, v.getColormap(p.mo and p.mo.skin or p.skin, p.mo and p.mo.color or p.skincolor))
	end

	if PTV3_2D.timeLeft then
		customhud.CustomFontString(v,
			160*FU,8*FU,
			tostring(PTV3_2D.timeLeft/TICRATE),
			"PTFNT",
			V_SNAPTOTOP,
			"center",
			FU/3
		)
	else
		customhud.CustomFontString(v,
			160*FU,8*FU,
			"Time's up!",
			"PTFNT",
			V_SNAPTOTOP,
			"center",
			FU/3
		)
		customhud.CustomFontString(v,
			160*FU,18*FU,
			"Map: "..G_BuildMapTitle(PTV3_2D.selectedMap),
			"PTFNT",
			V_SNAPTOTOP,
			"center",
			FU/3
		)
	end
end

customhud.SetupItem("2D Render", "ptv3", renderObjects, "gameandscores", 24)