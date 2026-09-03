local function _iconShit(v,x,y,scale,patch,color,namecolor,...)
	local texts = {...}

	v.drawScaled(x, y, scale, patch, nil, color)

	for _,i in ipairs(texts) do
		customhud.CustomFontString(v,
			x,y+((10*scale)*(_-1)),
			i,
			"PTFNT",
			nil,
			"center",
			FixedMul(FU/3, scale),
		    namecolor)
	end
end

local function drawPlayerIcon(v,dp,p,c)
	if not (dp and dp.PTRound and dp.PTRound.chaser) then return end
	if (p and p.PTRound and p.PTRound.chaser) then return end

	local result = K_GetScreenCoords(v,dp,c,p.mo)
	local scale = max(FU/2, FixedMul(result.scale, FU))
	local dist = R_PointToDist2(c.x, c.y, p.mo.x, p.mo.y)
	local patch = v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0)

	if dist > 20000*FU then return end

	if not result.onscreen then 
		local playerResult = K_GetScreenCoords(v,dp,c,dp.mo)

		if not playerResult.onscreen then
			return
		end

		local radius = FixedMul(dp.mo.radius, dp.mo.scale)
		local height = FixedMul(dp.mo.height, dp.mo.scale)

		local angle = R_PointToAngle2(dp.mo.x, dp.mo.y, p.mo.x, p.mo.y) - c.angle + ANGLE_90

		local x = playerResult.x
		local y = playerResult.y-FixedMul(height/2, playerResult.scale)

		local momx = P_ReturnThrustX(nil, angle, FixedMul(radius*3/2, playerResult.scale))
		local momy = P_ReturnThrustY(nil, angle, FixedMul(height/2, playerResult.scale))

		x = $+momx
		y = $-momy
		_iconShit(v,
			x,y,
			FU/2,
			patch, v.getColormap(p.mo.skin, p.mo.color),
			tostring(dist/FU).." FU"
		)

		return
	end


	result.y = $-FixedMul(p.mo.height, result.scale)


	_iconShit(v,
		result.x,result.y,
		max(result.scale, FU/2),
		patch, v.getColormap(p.mo.skin, p.mo.color),
		tostring(dist/FU).." FU"
	)
end

local function drawChaserIcon(v,dp,c, chaser, norenderdetails)
	if (dp and dp.PTRound and dp.PTRound.chaser) then return end
	if not (chaser and chaser.valid) then return end

	local result = K_GetScreenCoords(v,dp,c, chaser)

	local dist = R_PointToDist2(0, 0, R_PointToDist2(dp.mo.x, dp.mo.y, chaser.x, chaser.y), dp.mo.z-chaser.z)
	if dist > 8000*FU then return end

	local scale = max(FU/2, FixedMul(result.scale, FU))

	local p = nil
	local color = SKINCOLOR_WHITE
	local chaser_name = chaser.skindata.display_name[PTV3.pizzatime or 1]
	local icon = chaser.skindata.icons[chaser.skindata.current_icon]

	if chaser == PTV3.pizzaface then
		p = (PTV3.pizzaface.tracer and PTV3.pizzaface.tracer.valid) and PTV3.pizzaface.tracer.player
		if PTV3.pizzaface.skindata.enraged then
			color = (leveltime % 8)/2 and SKINCOLOR_KETCHUP or SKINCOLOR_CRIMSON
		end
	else
		p = (chaser.tracer and chaser.tracer.valid) and chaser.tracer.player
	end

	if p and p.PTRound then return end

	if not result.onscreen then
		local playerResult = K_GetScreenCoords(v,dp,c,dp.mo)

		if not playerResult.onscreen then
			return
		end

		local radius = FixedMul(dp.mo.radius, dp.mo.scale)
		local height = FixedMul(dp.mo.height, dp.mo.scale)

		local angle = R_PointToAngle2(dp.mo.x, dp.mo.y, chaser.x, chaser.y) - c.angle + ANGLE_90

		local x = playerResult.x
		local y = playerResult.y-FixedMul(height/2, playerResult.scale)

		local momx = P_ReturnThrustX(nil, angle, FixedMul(radius*3/2, playerResult.scale))
		local momy = P_ReturnThrustY(nil, angle, FixedMul(height/2, playerResult.scale))

		x = $+momx
		y = $-momy

		if norenderdetails then
			_iconShit(v,
				x,y,
				FU/2,
				v.cachePatch(icon),
				nil,
				color,
				"",
				"",
				""
			)
		else
			_iconShit(v,
				x,y,
				FU/2,
				v.cachePatch(icon),
				nil,
				color,
				tostring(dist/FU).." FU",
				p and p.name or chaser_name,
				p and p.PTRound and p.PTRound.camper and "CAMPER" or ""
			)
		end
		return
	end

	if P_CheckSight(dp.mo, chaser) then return end
	result.y = $-FixedMul(chaser.height, result.scale)

	_iconShit(v,
		result.x,result.y,
		max(result.scale, FU/2),
		v.cachePatch(icon),
		nil,
		color,
		tostring(dist/FU).." FU",
		p and p.name or chaser_name,
		p and p.PTRound and p.PTRound.pfcamper and "CAMPER" or ""
	)
end

local function SortChasersByDistance(pmo, prevChaser, nextChaser)
	local dist = R_PointToDist2(0, 0, R_PointToDist2(pmo.x, pmo.y, prevChaser.x, prevChaser.y), pmo.z-prevChaser.z)
	local dist2 = R_PointToDist2(0, 0, R_PointToDist2(pmo.x, pmo.y, nextChaser.x, nextChaser.y), pmo.z-nextChaser.z)

	return dist < dist2
end

local function drawGateName(v, dp, c, gate)
	if not (dp and dp.PTRound) then return end
	if not (gate and gate.valid) then return end

	local result = K_GetScreenCoords(v, dp, c, gate)

	if not result.onscreen then return end

	local dist = R_PointToDist2(0, 0, R_PointToDist2(dp.mo.x, dp.mo.y, gate.x, gate.y), dp.mo.z-gate.z)
	if dist > 8000*FU then return end

	local scale = max(FU/4, FixedMul(result.scale, FU))

	local p = nil
	local color = SKINCOLOR_WHITE

	result.y = $-FixedMul(gate.height, result.scale)

	customhud.CustomFontString(v,
	result.x, result.y,
	mapheaderinfo[gate.map].lvlttl,
	"PTFNT",
	nil,
	"center",
	scale,
	color)

	if multiplayer then
		local voteresult_y = result.y-FixedMul(gate.height/2, result.scale)
		customhud.CustomFontString(v,
			result.x, voteresult_y,
			tostring(gate.votes),
			"PTFNT",
			nil,
			"center",
			scale,
			color
		)
	end

	if not mapheaderinfo[gate.map].actnum then return end

	result.y = $+FixedMul(gate.height/2, result.scale)

	customhud.CustomFontString(v,
	result.x, result.y,
	"Act "..mapheaderinfo[gate.map].actnum,
	"PTFNT",
	nil,
	"center",
	scale,
	color)

end

return function(v,dp,c)
	if not PTV3:isPTV3() then return end
	if not (dp and dp.mo) then return end

	local norender_details = true

	for p in players.iterate do
		if not (p and p.mo and p.mo.health) then continue end
		drawPlayerIcon(v,dp,p,c)
	end

	for _, gate in ipairs(PTV3_HUB.gates) do
		drawGateName(v, dp, c, gate)
	end

	for _,chaser in ipairs(PTV3.currentchasers) do
		if not (chaser and chaser.valid) then
			table.remove(PTV3.currentchasers, _)
			continue
		end

		for next = _+1, #PTV3.currentchasers do
			if PTV3.currentchasers[next] and PTV3.currentchasers[next].valid then
				if chaser == PTV3.currentchasers[next] then table.remove(PTV3.currentchasers, next) return end

				if SortChasersByDistance(dp.mo, chaser, PTV3.currentchasers[next]) then
					PTV3.currentchasers[_], PTV3.currentchasers[next] = PTV3.currentchasers[next], PTV3.currentchasers[_]
				else
					PTV3.currentchasers[next], PTV3.currentchasers[_] = PTV3.currentchasers[next], PTV3.currentchasers[_]
				end
				chaser = PTV3.currentchasers[_]
			else
				continue
			end
		end

		if _ == #PTV3.currentchasers then
			norender_details = false
		end
		drawChaserIcon(v, dp, c, chaser, norender_details)
	end
end