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
	if not PTV3.pizzatime then return end
	if leveltime-PTV3.hud_pt > PTV3.maxpftime+(8*TICRATE) then return end

	local f = v.cachePatch('PFBARFILL')
	local b = v.cachePatch('PFBAR')

	local time = PTV3.HUD_returnTime(PTV3.hud_pt, 5*FU)

	local scale = FU/4
	scale = $*3/2
	
	local x = (160*FU)-(b.width*(scale/2))
	local y = ease.linear(time, 200*FU, 160*FU)

	if leveltime-PTV3.hud_pt > PTV3.maxpftime+(2*TICRATE) then
		local time = PTV3.HUD_returnTime(PTV3.hud_pt+PTV3.maxpftime+(2*TICRATE), 3*TICRATE, nil, true)
		
		y = ease.linear(time, 160*FU, 210*FU)
	end

	local o = 5*scale
	local of = 5*FU

	local time = PTV3.pftime
	local maxtime = PTV3.maxpftime

	local width = (b.width*FU)-of
	local bwidth = (b.width*scale)
	local progress = FixedMul(width, FixedDiv(maxtime-time, maxtime))

	local frame = (leveltime/2) % 12
	local j = v.cachePatch('SPINPF'..frame)

	local j_prog = max(-6*scale, min(FixedMul(progress, scale)+o-(j.width*scale/2), (b.width*scale)-(j.width*scale)+(8*scale)))

	drawBarFill(v, x+o, y+o, f, V_SNAPTOBOTTOM, scale, FixedDiv(leveltime % (f.width*4), f.width*4)*f.width, progress)

	v.drawScaled(x, y, scale, b, V_SNAPTOBOTTOM)
	v.drawScaled(x+j_prog, y-(3*scale), scale, j, V_SNAPTOBOTTOM)

	local text = string.format("%d:%02d", G_TicsToMinutes(PTV3.pftime), G_TicsToSeconds(PTV3.pftime))
	PTV3.drawText(v, x+(b.width*(scale/2)), y+(6*scale), text, {
		--scale = scale*3+(scale/3),
		align = "center",
		flags = V_SNAPTOBOTTOM}
	)

	--PTV3.drawText(v, x+(bwidth/2), y-(16*FU), "WILL ADD SMTH HERE LATER")
end