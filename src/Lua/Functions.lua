-- helper functions

local function randomChoice(...)
	local options = {...}
	return options[P_RandomRange(1,#options)]
end

local function getAllVarNames(array, ...)
	local values = {}
	local ignore = {...}
	for _,i in pairs(array) do
		local add = true
		
		for e,v in pairs(ignore) do
			if _ == v then
				add = false
				break
			end
		end
		
		if add then
			table.insert(values, _)
		end
	end

	return values
end

--[[
* l_supertextfont.lua
* (sprkizard)
* (May 29, 2020 12:42)
* Desc: Custom font drawer

* Usage: TODO
]]


-- Copy of the creditwidth function in-source, but accounting for any given font type
-- https://github.com/STJr/SRB2/blob/225095afa2fb1c61d12cf96c1b7c56cb4dbb4350/src/v_video.c#L3211
local function GetInternalFontWidth(str, font)
	-- No string
	if not (str) then return 0 end

	local width = 0

	for i=1,#str do
		-- Spaces before fonts
		if str:sub(i):byte() == 32 then
			width = $1+2
			continue
		end

		-- TODO: count special characters?
		if str:sub(i):byte() >= 200 then
			width = $1+8
			continue
		end

		-- (Using patch width by the way)
		if (font == "STCFN") then -- default font
			width = $1+8
		elseif (font == "TNYFN") then
			width = $1+7
		elseif (font == "LTFNT") then
			width = $1+20
		elseif (font == "TTL") then
			width = $1+29
		elseif (font == "CRFNT" or font == "NTFNT") then -- TODO: Credit font centers wrongly
			width = $1+16
		elseif (font == "NTFNO") then
			width = $1+20
		elseif (font == "PCFNT") then
			width = $1+5
		else
			width = $1+8
		end
	end
	return width*FU
end

local fonts = {
	['Combo'] = "PTCMB",
	['Credits'] = "PCFNT",
	['Lap'] = "PTLAP",
	['Old'] = "PTFNT",
	['War'] = "WARFN"
}

function PTV3.drawText(v, x, y, str, parms)

	-- Scaling
	local scale = (parms and parms.scale) or 1*FRACUNIT
	local hscale = (parms and parms.hscale) or 0
	local vscale = (parms and parms.vscale) or 0
	local yscale = (8*(FRACUNIT-scale))
	-- Spacing
	local xspacing = (parms and parms.xspace) or 0 -- Default: 8
	local yspacing = (parms and parms.yspace) or 4
	-- Text Font
	local font = (parms and parms.font) or "Old"
	local color = (parms and parms.color) or v.getColormap(nil, SKINCOLOR_WHITE)
	local uppercs = (parms and parms.uppercase) or false
	local align = (parms and parms.align) or nil
	local flags = (parms and parms.flags) or 0

	local drawscale = FU/3
	font = fonts[font] or "PTFNT"

	-- Split our string into new lines from line-breaks
	local lines = {}

	for ls in str:gmatch("[^\r\n]+") do
		table.insert(lines, ls)
	end

	-- For each line, set some stuff up
	for seg=1,#lines do
		
		local line = lines[seg]
		-- Fixed Position
		local fx = x
		local fy = y
		-- Offset position
		local off_x = 0
		local off_y = 0
		-- Current character & font patch (we assign later later instead of local each char)
		local char
		local charpatch

		-- Alignment options
		if (align) then
			-- TODO: not working correctly for CRFNT
			if (align == "center") then
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)/2), scale) -- accs for scale
			elseif (align == "right") then
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)), scale)
			end
		end

		-- Go over each character in the line
		for strpos=1,#line do

			-- get our character step by step
			char = line:sub(strpos, strpos)

			-- TODO: custom skincolors will make a mess of this since the charlimit is 255
			-- Set text color, inputs, and more through special characters
			-- Referencing skincolors https://wiki.srb2.org/wiki/List_of_skin_colors

			-- TODO: effects?
			-- if (char:byte() == 161) then
			-- 	continue
			-- end
			-- print(strpos<<27)
			-- off_x = (cos(v.RandomRange(ANG1, ANG10)*leveltime))
			-- off_y = (sin(v.RandomRange(ANG1, ANG10)*leveltime))
			-- local step = strpos%3+1
			-- print(step)
			-- off_x = cos(ANG10*leveltime)*step
			-- off_y = sin(ANG10*leveltime)*step

			-- Skip and replace non-existent space graphics
			if not char:byte() or char:byte() == 32 then
				fx = $1+2*scale
				continue
			end

			-- Unavoidable non V_ALLOWLOWERCASE flag toggle (exclude specials above 210)
			if (uppercs or (font == "CRFNT" or font == "NTFNT"))
			and not (char:byte() >= 210) then
				char = tostring(char):upper()
			end

			-- transform the char to byte to a font patch
			charpatch = v.cachePatch( string.format("%s%03d", font, string.byte(char)) )

			local _xs = charpatch.width
			if font == "PCFNT" then _xs = 5*3 end

			-- Draw char patch
			v.drawStretched(
				fx+off_x, fy+off_y+yscale,
				FixedMul(drawscale, scale+hscale), FixedMul(drawscale, scale+vscale), charpatch, flags, color)
			-- Sets the space between each character using font width
			fx = $1+(xspacing+_xs)*FixedMul(drawscale, scale+hscale)
			--fy = $1+yspacing*scale
			--fy = $1+yspacing*scale
		end

		-- Break new lines by spacing and patch width for semi-accurate spacing
		y = $1+(yspacing+charpatch.height)*scale 
	end
end

function PTV3:logEvent(text, type)
	local notifer = "* - "
	if type == 1 then
		notifer = "!!! - "
	elseif type == 2 then
		notifer = ">> - "
	end
		
	print(notifer..text)
end

local function getRandomPlayer(conditions)
	local p

	while not (p and p.valid) do
		p = players[P_RandomKey(32)]

		if (p and p.valid) and not (conditions and conditions(p)) then
			p = nil
		end
	end

	return p
end

function PTV3:playerCount()
	if not PTV3:isPTV3(true) then return end
	local total = {}
	local alive = {}
	local alive_2 = {}
	local pizzafaces = {}
	local finished = {}
	local unfinished = {}

	for p in players.iterate do
		if not p.ptv3 then continue end
		if p.ptv3.swapModeFollower then continue end
		if p and p.valid then
			table.insert(total, p)
		end
		if p.ptv3.chaser then
			table.insert(pizzafaces, p)
			continue
		end
		if p.mo
		and p.mo.valid
		and not p.ptv3.specforce
		and not p.ptv3.swapModeFollower then
			table.insert(alive, p)
			if p.mo.health then
				table.insert(alive_2, p)
			end
			if p.ptv3.fake_exit then
				table.insert(finished, p)
			else
				table.insert(unfinished, p)
			end
		end
	end
	
	return alive, pizzafaces, finished, unfinished, alive_2, total
end


local oppositefaces = {
	--awake to asleep
	["JOHNBLK1"] = "JOHNBLK0",
	--asleep to awake
	["JOHNBLK0"] = "JOHNBLK1",
}

PTV3.switchJohnBlocks = function()
	if mapheaderinfo[gamemap].ptv3_nofofflip ~= nil
		return
	end
	
	for sec in sectors.iterate
		for rover in sec.ffloors()
			if not rover.valid then continue end
			local side = rover.master.frontside
			
			if not (side.midtexture == R_TextureNumForName("JOHNBLK1")
			or side.midtexture == R_TextureNumForName("JOHNBLK0"))
			--or side.midtexture == R_TextureNumForName("TKISBKB1")
			--or side.midtexture == R_TextureNumForName("TKISBKB2"))
				continue
			end
			
			local oppositeface = oppositefaces[
					string.sub(R_TextureNameForNum(side.midtexture),1,8)
				]
				
			--???????
			if oppositeface == nil then continue end
			
			--awake to asleep
			if rover.flags & FOF_SOLID
				rover.flags = $|FOF_TRANSLUCENT|FOF_NOSHADE &~(FOF_SOLID|FOF_CUTLEVEL|FOF_CUTSOLIDS)
				rover.alpha = 128
			--asleep to awake
			else
				rover.flags = $|FOF_SOLID|FOF_CUTLEVEL|FOF_CUTSOLIDS &~(FOF_TRANSLUCENT|FOF_NOSHADE)
				rover.alpha = 255
			end
			side.midtexture = R_TextureNumForName(oppositeface)
		end
	end
end

function PTV3:canLap(p)
	if not p.ptv3 then return 0 end
	if p.ptv3.chaser then return 0 end

	if gametype == GT_PTV3DM then
		return 1
	end

	if not self.overtime then
		if p.ptv3.extreme then
			if p.ptv3.laps < self.max_laps+self.max_elaps then return 1 end
		else
			if self.max_elaps and p.ptv3.laps > self.max_laps then
				return 2
			end

			if p.ptv3.laps <= self.max_laps then
				return 1
			end
		end
	end
	return 0
end


function PTV3:forceLap(p)
	if p.ptv3.chaser then return false end

	if gametype == GT_PTV3DM then
		return true
	end

	if p.ptv3.extreme
	and p.ptv3.laps < self.max_laps+self.max_elaps then
		return true
	end

	return false
end

function PTV3:canOvertime()
	local alive, pizzafaces, finished, unfinished, alive_2, total = PTV3:playerCount()
	local normalLappers = {}
	local extremeLappers = {}

	for _,p in pairs(alive) do
		if not (p and p.ptv3 and not p.ptv3.specforce) then continue end

		if p.ptv3.extreme then
			extremeLappers[#extremeLappers+1] = p
		else
			normalLappers[#normalLappers+1] = p
		end
	end

	if #alive > 1 then
		if #finished < #normalLappers/2 then
			return true
		end
	elseif #alive ~= #finished then
		return true
	end

	return false
end

function PTV3:endGame()
	if PTV3.game_over >= 0 then return end

	PTV3.game_over = leveltime
	for p in players.iterate do
		if p.mo then
			if (not p.ptv3.fake_exit) then
				P_KillMobj(p.mo)
			end
			p.mo.flags = $|MF_NOTHINK
		end
	end

	PTV3.callbacks("EndGame")
end

function PTV3:canExit(p)
	if (p and p.ptv3 and p.ptv3.chaser) then return false end
	return true
end

function PTV3:doPlayerExit(p)
	if not (p and p.ptv3 and not p.ptv3.fake_exit) then return end

	if not (p.ptv3.extreme or PTV3.overtime)
	and p.ptv3.laps < self.max_laps then
		p.ptv3.canLap = 5*TICRATE
	end
	S_StartSound(p.mo, sfx_winer)

	p.ptv3.fake_exit = true
end

-- Enters Extreme Mode.
function PTV3:extremeToggle(p)
	p.ptv3.extreme = true
	if not self.extreme then
		self.extreme = true

		P_SetSkyboxMobj(nil, false)
		P_SetupLevelSky(34)
		S_StartSound(nil, P_RandomRange(41,43))
		P_FlashPal(consoleplayer, 1, 15)

		if globalweather ~= (1 or 5) then
			P_SwitchWeather(5)
		elseif globalweather == 6 then P_SwitchWeather(1) end
	end
end

function PTV3:overtimeToggle()
	if self.overtime then return end
	self.overtime = true
	self.overtimeStart = leveltime
	S_StartSound(nil, sfx_timexp)

	if not (PTV3.snick) then
		PTV3:snickSpawn()
	end

	if consoleplayer
	and consoleplayer.ptv3
	and not consoleplayer.ptv3.insecret then
		P_SetSkyboxMobj(nil,false)
		P_SetupLevelSky(9)
	end

	PTV3.callbacks("OvertimeStart")
end

-- Sets a teleport to a specified set of coordinates. Mainly used by Lap Portals, transitions, and John.
function PTV3:queueTeleport(p, coords, relative, src)
	if not p or not p.mo then return end

	local mobjteleport = {
		mo = p.mo,
		coords = coords or self.endpos,
		relative = relative,
		source = src
	}
	
	table.insert(PTV3.tplist, mobjteleport)
	PTV3.callbacks('TeleportPlayer', p)
end

-- Enters a new lap for the player who entered a Lap Portal.
function PTV3:newLap(p, int)
	if not (self.pizzatime or self.minusworld) then return end
	if not p.ptv3 then return end
	if p.ptv3.chaser then return end
	if not (self:canLap(p)) then return end

	if p.ptv3.isSwap and not p.ptv3.swapModeFollower then
		self:newLap(p.ptv3.isSwap, int)
	end

	if not int then return end
	p.ptv3.laps = $+int

	local raw_time = leveltime - PTV3.hud_pt

	if p.ptv3.lap_time >= 0 then
		raw_time = leveltime - p.ptv3.lap_time
	end

	local time = string.format( "%02d:%02d", G_TicsToMinutes(raw_time), G_TicsToSeconds(raw_time) )
	local event_text = p.name.." has made it to Lap "..p.ptv3.laps.." in "..time.."!"

	if self:canLap(p) == 2 then
		self:extremeToggle(p)
		event_text = $.." If Overtime starts while in Extreme Laps, then this player will die."
	end

	if p.ptv3.extreme then
		event_text = $:gsub("to Lap", "to Extreme Lap")
	else
		P_AddPlayerScore(p, 3000)
	end

	if (PTV3.spawnGate and PTV3.spawnGate.valid) and PTV3.spawnGate.lappers[p] then
		PTV3.spawnGate.lappers[p] = false
	end

	if abs(p.ptv3.laps) ~= 1 then
		if PTV3.minusworld then
			self:queueTeleport(p, PTV3.spawn, p.ptv3.extreme)
		else
			self:queueTeleport(p, PTV3.endpos, p.ptv3.extreme)
		end
	end

	-- For the quakes
	if ((PTV3.minusworld and not PTV3.pizzatime) or PTV3.extreme) then PTV3.shakeintensity = min(p.ptv3.laps, 5) end

	-- Speed up Pizzaface
	if PTV3.pizzaface and PTV3.pizzaface.angry then
		PTV3.pizzaface.incremspeed = $+(FU/(PTV3.max_elaps - (PTV3.max_elaps/2)))
		PTV3.pizzaface.incremspeedthreshold = $-1
	end

	p.ptv3.lap_time = leveltime
	p.powers[pw_invulnerability] = 5*TICRATE

	if p == displayplayer then S_StartSound(nil, sfx_lap2, p) end

	if p.ptv3.isSwap and p.ptv3.isSwap.valid then
		p.ptv3.isSwap.powers[pw_invulnerability] = 5*TICRATE
	end

	if p.ptv3.combo then
		p.ptv3.combo_pos = self.MAX_COMBO_TIME
	end

	-- Spawn Pizzaface
	if abs(p.ptv3.laps) >= 3 and not (self.pizzaface and self.pizzaface.valid) then
		self.pftime = 0
		if not multiplayer then PTV3.time = 0 end
	end

	-- Spawn Snick
	if abs(p.ptv3.laps) >= 4 and not (self.snick and self.snick.valid) then
		self:snickSpawn()
	end

	-- Spawn John Ghost
	if abs(p.ptv3.laps) >= 5 and not (self.johnGhost and self.johnGhost.valid) then
		self:johnGhostSpawn()
	end
	
	PTV3:logEvent(event_text, 2)
	PTV3.callbacks('NewLap', p)
end

local function PrepareYourPizza(p, event)
	PTV3.shakeintensity = 2
	local time = string.format( "%02d:%02d", G_TicsToMinutes(leveltime), G_TicsToSeconds(leveltime) )
	PTV3:logEvent(p.name.." has started "..event.." in "..time.."!", 1)

	local alive, pizzafaces, finished, unfinished, alive_2, total = PTV3:playerCount()

	if gametype ~= GT_PTV3DM
	and multiplayer
	and #total > 1 then
		local pfp = getRandomPlayer(function(rp)
			return rp.ptv3
			and rp ~= p
			and rp.ptv3.swapModeFollower ~= p.mo
		end)
		
		pfp.ptv3.chaser = true
		pfp.ptv3.chasertype = "pizzaface"
		pfp.powers[pw_shield] = SH_NONE
		pfp.powers[pw_invulnerability] = 0
		if pfp.ptv3.isSwap then
			if pfp.ptv3.swapModeFollower
			and pfp.ptv3.swapModeFollower.valid then
				local mo = pfp.ptv3.swapModeFollower
				mo.player.ptv3.swapModeFollower = nil
				mo.player.ptv3.isSwap = false
			end
			pfp.ptv3.swapModeFollower = nil
			pfp.ptv3.isSwap = false
		end
		if pfp.ptv3.insecret then
			PTV3:exitSecret(pfp)
		end
		PTV3:logEvent(pfp.name.." is Pizzaface for this round.", 1)
	end

	PTV3.switchJohnBlocks()
end

function PTV3:startPizzaTime(p)
	self.pizzatime = true
	self.hud_pt = leveltime
	if gametype == GT_PTV3DM then
		self:snickSpawn()
	end
	for player in players.iterate do
		if not player.mo then continue end
		if not player.ptv3 then continue end

		player.ptv3.laps = $+1

		if (player.ptv3.insecret) then
			player.ptv3.secret_tptoend = true
		elseif player ~= p then
			self:queueTeleport(player, self.endpos)
			player.powers[pw_invulnerability] = 5*TICRATE
		end
		if player.ptv3.combo then
			player.ptv3.combo_pos = PTV3.MAX_COMBO_TIME
		end
	end

	PrepareYourPizza(p, "Pizza Time")
	PTV3.callbacks('PizzaTime', p)
end

function PTV3:startMinusWorld(p)
	self.minusworld = true
	self.hud_pt = leveltime
	self.shakeintensity = 2

	S_StartSound(nil, sfx_s3k9f)
	P_SetOrigin(PTV3.spawnGate, PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z)
	PTV3.spawnGate.angle = PTV3.endpos.a

	for player in players.iterate do
		if not player.mo and not player.ptv3 then continue end
		
		player.ptv3.laps = $-1

		if (player.ptv3.insecret) then
			player.ptv3.secret_tptoend = true
		else
			self:queueTeleport(player, self.spawn)
		end
		if player.ptv3.combo then
			player.ptv3.combo_pos = PTV3.MAX_COMBO_TIME
		end
	end

	PrepareYourPizza(p, "Minus World")
	PTV3.callbacks('MinusWorld', p)
end

// for the funny
function PTV3:returnPizzaface()
	if PTV3.pftime then
		return false
	end

	if PTV3.pizzaface.type ~= MT_PTV3_PIZZAFACE then
		if PTV3.pizzaface.ptv3.pizzaMobj
		and PTV3.pizzaface.ptv3.pizzaMobj.valid then
			return PTV3.pizzaface.ptv3.pizzaMobj
		end
	elseif PTV3.pizzaface
	and PTV3.pizzaface.valid then
		return PTV3.pizzaface
	end

	return false
end

function PTV3:initSwapMode(p, p2)
	if not (p and p2 and p.ptv3 and p2.ptv3) then return false end
	if not p.mo then return false end
	if not p2.mo then return false end

	if p2.ptv3.swapModeFollower then
		p2.ptv3.swapModeFollower = nil
	end
	p.ptv3.swapModeFollower = p2.mo
	
	p.ptv3.isSwap = p2
	p2.ptv3.isSwap = p

	self:doEffect(p2.mo, "Taunt")

	return true
end

function PTV3:doFollowerTP(flwr, lder, index)
	if index == nil then index = 2 end
	if not lder.ptv3 then return end
	local data = lder.ptv3.movementData
	if not data[1] then return end

	if data[#data-index] then
		local data = data[#data-index]

		if flwr.player then
			local pflags = data.pflags & ~(PF_DIRECTIONCHAR|PF_ANALOGMODE|PF_AUTOBRAKE|PF_APPLYAUTOBRAKE|PF_FORCESTRAFE)
			
			flwr.player.ptv3.fake_exit = data.fake_exit
			flwr.player.pflags = $|pflags
			flwr.player.drawangle = data.angle
		end
		P_SetOrigin(flwr,
			data.x+FixedMul(lder.mo.radius*2, -cos(lder.drawangle)),
			data.y+FixedMul(lder.mo.radius*2, -sin(lder.drawangle)),
			data.z
		)
		flwr.momx = data.momx
		flwr.momy = data.momy
		flwr.momz = data.momz
	end

	local state = S_PLAY_STND

	if (flwr.momx or flwr.momy) then
		state = S_PLAY_WALK
	end
	if not P_IsObjectOnGround(flwr) then
		state = S_PLAY_SPRING
	end

	flwr.state = state
end
