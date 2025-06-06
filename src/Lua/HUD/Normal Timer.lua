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
	if not (PTV3.pizzatime or PTV3.minusworld) then return end
	if PTV3.overtime then return end

	local time = PTV3.HUD_returnTime(PTV3.hud_pt, 5*FU)

	local f = v.cachePatch('PIZZAFILL')
	local b = v.cachePatch('PIZZABAR')
	
	local scale = FU/4
	scale = $*3/2
	
	local x = (160*FU)-(b.width*(scale/2))
	local y

	if PTV3.time then
		y = ease.linear(time, 220*FU, 180*FU)
	else
		y = ease.linear(time, 180*FU, 220*FU)
	end
	
	local o = 5*scale
	local of = 5*FU

	local time = PTV3.time
	local maxtime = CV_PTV3['time'].value*TICRATE

	local width = (b.width*FU)-of
	local bwidth = (b.width*scale)
	local progress = FixedMul(width, FixedDiv(maxtime-time, maxtime))

	if time <= 5*TICRATE
	and not PTV3.overtime
	and not (PTV3.game_over > -1)
	and multiplayer then
		local maxTime = min(maxtime, 5*TICRATE)
		local shakePerc = FixedDiv(maxTime-time, maxTime)*6

		x = $+v.RandomRange(-shakePerc, shakePerc)
		y = $+v.RandomRange(-shakePerc, shakePerc)

		v.fadeScreen(0xFF00, ease.linear(shakePerc/6, 0, 31/2))
	end

	local frame = leveltime % 22
	local j = v.cachePatch('JOHN'..frame)

	local j_prog = max(-6*scale, min(FixedMul(progress, scale)+o-(j.width*scale/2), (b.width*scale)-(j.width*scale)+(8*scale)))

	drawBarFill(v, x+o, y+o, f, V_SNAPTOBOTTOM, scale, FixedDiv(leveltime % (f.width*4), f.width*4)*f.width, progress)

	if PTV3.overtime then
		local maxtime = PTV3.maxotTime
		local progress = FixedMul(width, FixedDiv(maxtime-PTV3.overtime_time, maxtime))
		
		drawBarFill(v, x+o, y+o, f, V_SNAPTOBOTTOM, scale, FixedDiv(leveltime % (f.width*4), f.width*4)*f.width, progress, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER))
	end

	v.drawScaled(x, y, scale, b, V_SNAPTOBOTTOM)
	v.drawScaled(x+j_prog, y-(3*scale), scale, j, V_SNAPTOBOTTOM)

	local text = string.format("%d:%02d", G_TicsToMinutes(PTV3.time), G_TicsToSeconds(PTV3.time))
	PTV3.drawText(v, x+(b.width*(scale/2)), y+(6*scale), text, {
		--scale = scale*3+(scale/3),
		align = "center",
		flags = V_SNAPTOBOTTOM}
	)

	if not multiplayer then
		frame = leveltime % 17
		local p = v.cachePatch("PFCES"..frame)

		v.drawScaled(x+(bwidth-10*FU), y-(15*FU), scale, p, V_SNAPTOBOTTOM)
	end

	--PTV3.drawText(v, x+(bwidth/2), y-(16*FU), "WILL ADD SMTH HERE LATER")
end