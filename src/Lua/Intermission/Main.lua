local drawParallax = dofile "Intermission/Draw Parallax"
local inttime = 0

local linear = ease.linear
local outcubic = ease.outcubic
local incubic = ease.incubic

local rankTexts = {
	["E"] = { line = "That's a moray!", color = SKINCOLOR_WHITE, size = FU/4 },
	["D"] = { line = "Were you even trying?", color = SKINCOLOR_BLACK, size = FU/4 },
	["C"] = { line = "Not your best...", color = SKINCOLOR_GREEN, size = FU/4 },
	["B"] = { line = "Could be better", color = SKINCOLOR_BLUE, size = FU/4 },
	["A"] = { line = "Awesome!", color = SKINCOLOR_RED, size = FU/4 },
	["S"] = { line = "PERFECT", color = SKINCOLOR_GOLD, size = FU/2 }
}

addHook("NetVars", function(n)
	inttime = n($)
end)

addHook("IntermissionThinker", do
	if not PTV3:isPTV3(true) then return end

	inttime = $+1
end)

addHook("MusicChange", function(old, new)
	if PTV3:isPTV3(true)
	and (new == "_inter" or new == "_clear") then
		local p = consoleplayer
		if not (p and p.valid and p.ptv3) then return end

		local rank = p.ptv3.rank
		if not PTV3.ranks[rank]
		or p.ptv3.specforce then
			return "ERANK"
		end

		return PTV3.ranks[rank].music
	end
end)

addHook("MapLoad", do
	inttime = 0
	hud.enable "intermissiontally"
end)

local rotationTable = {
	5,
	4,
	3,
	2,
	1,
	8
}

local function hAndHTween(startTween, endTween, time, start, half, finish)
	if time < FU/2 then
		return startTween(time*2, start, half)
	else
		return endTween((time-(FU/2))*2, half, finish)
	end
end

addHook("HUD", function(v)
	if not PTV3:isPTV3(true) then return end
	hud.disable "intermissiontally"

	v.drawFill(nil, nil, nil, nil, 0)

	local p = consoleplayer
	if not (p and p.valid and p.ptv3) then return end

	local color = v.getColormap(p.skin, p.skincolor)

	local screenWidth = FixedDiv(v.width()*FU, v.dupx()*FU)
	local screenHeight = FixedDiv(v.height()*FU, v.dupy()*FU)

	local rank = PTV3.ranks[p.ptv3.rank].rank
	if p.ptv3.specforce then
		rank = "E"
	end

	local scale = FU/3
	local x = screenWidth/2
	local y = screenHeight/2
	local rotation = rotationTable[1]
	local sprite = SPR2_STND
	local tweenTime

	if rank ~= "P" then
		tweenTime = FixedDiv(max(0, min(inttime-80, 20)), 20)
		scale = incubic(tweenTime, FU/3, FU*4)
		x = hAndHTween(outcubic, incubic, tweenTime, $, 0, 120*FU)
		y = outcubic(tweenTime, $, (screenHeight/2)+(120*FU))
	
		rotation = rotationTable[linear(tweenTime, 1, 6)]
	else
		local waitTime = 80
		local spindashTics = waitTime+(TICRATE-8)
		local rollTics = spindashTics+5
		local bounceOffTics = rollTics+TICRATE

		local spindashScale = FU*16
		local spindashY = screenHeight+(16*FU)
		local afterScale = FU
		local afterY = y+(20*FU)

		if inttime >= waitTime
		and inttime < spindashTics then
			rotation = 1
			sprite = SPR2_SPIN
		end
		if inttime >= spindashTics
		and inttime < rollTics then
			sprite = SPR2_ROLL
			rotation = 1
			tweenTime = max(0, min(FixedDiv(inttime-spindashTics, rollTics-spindashTics), FU))
			
			scale = linear(tweenTime, $, spindashScale)
			y = linear(tweenTime, $, spindashY)
		end
		if inttime >= rollTics then
			tweenTime = max(0, min(FixedDiv(inttime-rollTics, bounceOffTics-rollTics), FU))
			sprite = SPR2_FALL
			local background = v.cachePatch("PRANKBG")
			local sWidth = FixedDiv(screenWidth, background.width*FU)
			local sHeight = FixedDiv(screenHeight, background.height*FU)
			local bgScale = sWidth > sHeight and sWidth or sHeight

			v.drawStretched(
				(screenWidth/2)-(background.width*(bgScale/2)),
				(screenHeight/2)-(background.height*(bgScale/2)),
				bgScale,
				bgScale,
				background,
				V_SNAPTOLEFT|V_SNAPTOTOP
			)
			if tweenTime == FU then
				sprite = SPR2_STND
			end
			rotation = 1
			
			scale = linear(tweenTime, spindashScale, afterScale)
			y = hAndHTween(outcubic, incubic, tweenTime, spindashY, $-(35*FU), $+(12*FU))
		end
	end
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP

	if rotation
	and rotation > 5 then
		flags = $|V_FLIP
	end

	sprite = v.getSprite2Patch(p.skin, sprite, false, A, rotation)
	local displayrank = v.cachePatch("RES_"..rank)

	v.drawScaled(x, y, scale, sprite, flags, color)

	if tweenTime == FU
	and rank ~= "P" then
		v.drawScaled(120*FU, (5*FU)/2, FU/2, displayrank, V_SNAPTORIGHT|V_SNAPTOTOP)

		customhud.CustomFontString(v,
			140*FU, 150*FU,
			rankTexts[rank].line,
			"PTFNT",
			V_SNAPTORIGHT,
			"center",
			rankTexts[rank].size,
			rankTexts[rank].color
		)
	end
end, "intermission")