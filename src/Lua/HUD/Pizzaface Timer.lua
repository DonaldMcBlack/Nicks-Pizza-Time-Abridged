local function drawBarFill(v, x, y, patch, flags, scale, offset, length, color)
	local prog = -offset

	while prog < length do
		if prog+(patch.width*FU) < length then
			if prog < 0 then
				v.drawCropped(
					x, y,
					scale, scale,
					patch,
					flags,
					color,
					-prog,
					0,
					(patch.width*FU)-prog,patch.height*FU
				)
			else
				v.drawScaled(x+FixedMul(prog, scale), y, scale, patch, flags, color)
			end
			prog = $+(patch.width*FU)
		else
			if prog > 0 then
				v.drawCropped(
					x+FixedMul(prog, scale), y,
					scale, scale,
					patch,
					flags,
					color,
					0, 0,
					length-prog,
					patch.height*FU
				)
			else
				v.drawCropped(
					x, y,
					scale, scale,
					patch,
					flags,
					color,
					-prog, 0,
					length,
					patch.height*FU
				)
			end
			prog = length
		end
	end
end

return function(v)
	if not PTV3:isPTV3() then return end
	if not PTV3.pizzatime and gametype ~= GT_PTV3DM then return end
	if not multiplayer then return end

	local time = PTV3.HUD_returnTime(-1, 5*FU)

	local fill = v.cachePatch('PFBARFILL')
	local bar = v.cachePatch('PFBAR')

	local scale = (FU/4)*3/2
	
	local x = (160*FU)-(bar.width*(scale/2))
	local y = ease.linear(time, 200*FU, PTV3.pizzatime and 160*FU or 180*FU)

	-- if leveltime-PTV3.starttime_pizzatime > PTV3.maxpftime+(2*TICRATE) then
	-- 	time = PTV3.HUD_returnTime(PTV3.starttime_pizzatime+PTV3.maxpftime+(2*TICRATE), 3*TICRATE, nil, true)
		
	-- 	y = ease.linear(time, 160*FU, 210*FU)
	-- end

	local o = 5*scale
	local of = 5*FU

	local width = (bar.width*FU)-of
	local bwidth = (bar.width*scale)
	local progress = FixedMul(width, FixedDiv(PTV3.maxpftime-PTV3.pftime, PTV3.maxpftime))

	local frame = (leveltime/2) % 12
	local j = v.cachePatch('SPINPF'..frame)

	local j_prog = max(-6*scale, min(FixedMul(progress, scale)+o-(j.width*scale/2), (bar.width*scale)-(j.width*scale)+(8*scale)))

	drawBarFill(v, max(x+o, 0), y+o, fill, V_SNAPTOBOTTOM, scale, FixedDiv(leveltime % (fill.width*4), fill.width*4)*fill.width, progress)

	v.drawScaled(x, y, scale, bar, V_SNAPTOBOTTOM)
	v.drawScaled(x+j_prog, y-(3*scale), scale, j, V_SNAPTOBOTTOM)

	local text = string.format("%d:%02d", G_TicsToMinutes(PTV3.pftime), G_TicsToSeconds(PTV3.pftime))
	customhud.CustomFontString(v,
		x+(bar.width*(scale/2)), y+(6*scale),
		text,
		"PTFNT",
		V_SNAPTOBOTTOM,
		"center",
		scale,
		SKINCOLOR_WHITE
	)

	--PTV3.drawText(v, x+(bwidth/2), y-(16*FU), "WILL ADD SMTH HERE LATER")
end