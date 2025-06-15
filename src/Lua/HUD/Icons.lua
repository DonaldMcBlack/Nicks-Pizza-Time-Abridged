-- partial and edited sglib

-- returns viewx, viewy, viewz, viewangle, aimingangle, viewroll
local cv_tilting
rawset(_G, "SG_GetViewVars", function(v, p, c, allowspectator)
	local roll = p.viewrollangle
	
	if (p.spectator) and not allowspectator then
		return
	end
	
	if p.awayviewtics then
		local mo = p.awayviewmobj
		return mo.x, mo.y, mo.z, mo.angle, mo.pitch, roll
	elseif c.chase then
		return c.x, c.y, c.z + c.height/2, c.angle, c.aiming, roll
	/*
	elseif p.mo then
		return p.mo.x, p.mo.y, p.viewz, p.mo.angle, p.aiming, roll
	*/
	else
		return p.realmo.x, p.realmo.y, p.viewz, p.realmo.angle, p.aiming, roll
	end
end)

local fovvars
rawset(_G, "R_FOV", function(num)
	if not fovvars then
		fovvars = CV_FindVar("fov")
	end
	
	return fovvars.value
end)

// This version of the function was prototyped in Lua by Nev3r ... a HUGE thank you goes out to them!
-- if only it was exposed
local baseFov = CV_FindVar("fov").value
local BASEVIDWIDTH = 320
local BASEVIDHEIGHT = 200
rawset(_G, "SG_ObjectTracking", function(v, p, c, point, reverse, allowspectator)
	//local cameraNum = c.pnum - 1
	local viewx, viewy, viewz, viewangle, aimingangle, viewroll = SG_GetViewVars(v, p, c, allowspectator)

	// Initialize defaults
	local result = {
		x = 0,
		y = 0,
		scale = FRACUNIT,
		onScreen = false
	}

	// Take the view's properties as necessary.
	local viewpointAngle, viewpointAiming, viewpointRoll
	if reverse then
		viewpointAngle = viewangle + ANGLE_180
		viewpointAiming = InvAngle(aimingangle)
		if viewroll then
			viewpointRoll = viewroll
		end
	else
		viewpointAngle = viewangle
		viewpointAiming = aimingangle
		if viewroll then
			viewpointRoll = InvAngle(viewroll)
		end
	end

	// Calculate screen size adjustments.
	local screenWidth = v.width()/v.dupx()
	local screenHeight = v.height()/v.dupy()

	-- what's the difference between this and r_splitscreen?
	-- future G: seems to alternate between view count and view number depending on where you are in the codebase
	-- may i interest the Krew in stplyrnum? :^)
	if splitscreen then
		// Half-wide screens
		screenWidth = $ >> 1
	end

	local screenHalfW = (screenWidth >> 1) << FRACBITS
	local screenHalfH = (screenHeight >> 1) << FRACBITS

	// Calculate FOV adjustments.
	local fovDiff = R_FOV() - baseFov
	local fov = ((baseFov - fovDiff) / 2) - (p.fovadd / 2)
	local fovTangent = tan(FixedAngle(fov))

	if splitscreen == 1 then
		// Splitscreen FOV is adjusted to maintain expected vertical view
		fovTangent = 10*fovTangent/17
	end

	local fg = (screenWidth >> 1) * fovTangent

	// Determine viewpoint factors.
	
	local h = R_PointToDist2(point.x, point.y, viewx, viewy)
	local da = viewpointAngle - R_PointToAngle2(viewx, viewy, point.x, point.y)
	local dp = viewpointAiming - R_PointToAngle2(0, 0, h, viewz)

	if reverse then da = -da end

	// Set results relative to top left!
	result.x = FixedMul(tan(da), fg)
	result.y = FixedMul((tan(viewpointAiming) - FixedDiv((point.z - viewz), 1 + FixedMul(cos(da), h))), fg)

	result.angle = da
	result.pitch = dp
	result.fov = fg

	// Rotate for screen roll...
	if viewpointRoll then
		local tempx = result.x
		result.x = FixedMul(cos(viewpointRoll), tempx) - FixedMul(sin(viewpointRoll), result.y)
		result.y = FixedMul(sin(viewpointRoll), tempx) + FixedMul(cos(viewpointRoll), result.y)
	end

	// Flipped screen?
	if encoremode then result.x = -result.x end

	// Center results.
	result.x = $ + screenHalfW
	result.y = $ + screenHalfH

	result.scale = FixedDiv(screenHalfW, (h*2)+1)

	result.onScreen = not ((abs(da) > ANG60) or (abs(viewpointAiming - R_PointToAngle2(0, 0, h, (viewz - point.z))) > ANGLE_45))

	// Cheap dirty hacks for some split-screen related cases
	if result.x < 0 or result.x > (screenWidth << FRACBITS) then
		result.onScreen = false
	end

	if result.y < 0 or result.y > (screenHeight << FRACBITS) then
		result.onScreen = false
	end

	// adjust to non-green-resolution screen coordinates
	result.x = $ - ((v.width()/v.dupx()) - BASEVIDWIDTH)<<(FRACBITS-(splitscreen and 2 or 1))
	result.y = $ - ((v.height()/v.dupy()) - BASEVIDHEIGHT)<<(FRACBITS-(splitscreen and 2 or 1))
	return result
end)

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
	if not (dp and dp.ptv3 and dp.ptv3.pizzaface) then return end
	if (p and p.ptv3 and p.ptv3.pizzaface) then return end

	local result = SG_ObjectTracking(v,dp,c,p.mo)
	local scale = max(FU/2, FixedMul(result.scale, FU))
	local dist = R_PointToDist2(c.x, c.y, p.mo.x, p.mo.y)
	local patch = v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0)

	if dist > 12000*FU then return end

	if not result.onScreen then
		local playerResult = SG_ObjectTracking(v,dp,c,dp.mo)

		if not playerResult.onScreen then
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
		patch, 
		v.getColormap(p.mo.skin, p.mo.color),
		v.getColormap(p.mo.skin, p.mo.color),
		tostring(dist/FU).." FU"
	)
end

local function drawChaserIcon(v,dp,c, chaser, icon)
	if (dp and dp.ptv3 and dp.ptv3.pizzaface) then return end
	if not (chaser and chaser.valid) then return end

	local result = SG_ObjectTracking(v,dp,c,chaser)

	local dist = R_PointToDist2(dp.mo.x, dp.mo.y, chaser.x, chaser.y)
	if dist > 5000*FU then return end

	local scale = max(FU/2, FixedMul(result.scale, FU))

	local p
	local color = SKINCOLOR_WHITE
	if chaser == PTV3.pizzaface then
		p = (PTV3.pizzaface.tracer and PTV3.pizzaface.tracer.valid) and PTV3.pizzaface.tracer.player
		if PTV3.pizzaface.angry then

			if (leveltime % 8)/2 then
				color = SKINCOLOR_KETCHUP
			else
				color = SKINCOLOR_CRIMSON
			end
			icon = "PIZZAICON2"
		end
	else
		p = (chaser.target and chaser.target.valid) and chaser.target.player
	end

	if not result.onScreen then 
		local playerResult = SG_ObjectTracking(v,dp,c,dp.mo)

		if not playerResult.onScreen then
			return
		end

		if chaser ~= PTV3.pizzaface and PTV3.extreme then return end

		local radius = FixedMul(dp.mo.radius, dp.mo.scale)
		local height = FixedMul(dp.mo.height, dp.mo.scale)

		local angle = R_PointToAngle2(dp.mo.x, dp.mo.y, chaser.x, chaser.y) - c.angle + ANGLE_90

		local x = playerResult.x
		local y = playerResult.y-FixedMul(height/2, playerResult.scale)

		local momx = P_ReturnThrustX(nil, angle, FixedMul(radius*3/2, playerResult.scale))
		local momy = P_ReturnThrustY(nil, angle, FixedMul(height/2, playerResult.scale))

		x = $+momx
		y = $-momy

		_iconShit(v,
			x,y,
			scale,
			v.cachePatch(icon),
			nil,
			color,
			tostring(dist/FU).." FU",
			chaser.displayname or p and p.name,
			p and p.ptv3 and p.ptv3.pfcamper and "CAMPER" or ""
		)
		return
	end

	result.y = $-FixedMul(chaser.height, result.scale)

	_iconShit(v,
		result.x,result.y,
		max(result.scale, FU/2),
		v.cachePatch(icon),
		nil,
		color,
		tostring(dist/FU).." FU",
		chaser.displayname or p and p.name,
		p and p.ptv3 and p.ptv3.pfcamper and "CAMPER" or ""
	)
end

return function(v,dp,c)
	if not PTV3:isPTV3() then return end
	if not (dp and dp.mo) then return end

	for p in players.iterate do
		if not (p and p.mo and p.mo.health) then continue end
		drawPlayerIcon(v,dp,p,c)
	end

	drawChaserIcon(v,dp,c, PTV3.snick, "SNICKICON")
	drawChaserIcon(v,dp,c, PTV3.john, "JOHNICON")
	drawChaserIcon(v,dp,c, PTV3.pizzaface, "PIZZAICON")
end