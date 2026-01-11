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

function PTV3:isPTV3(dontCheckState)
	if not dontCheckState
	and gamestate ~= GS_LEVEL then
		return false
	end

	return gametype == GT_PTV3 or gametype == GT_PTV3DM or not multiplayer
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

rawset(_G, "P_FlyTo", function(mo, fx, fy, fz, sped, addques)
	local z = mo.z+(mo.height/2)
    if mo.valid then
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - z)
        if flyto < 1 then
            flyto = 1
        end
		
        if addques then
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - z, flyto), sped)
        end
    end
end)

rawset(_G,'L_DoBrakes', function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end)

rawset(_G, "L_SpeedCap", function(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd, ang =
		R_PointToDist2(0,0,spd_xy,mo.momz),
		R_PointToAngle2(0,0,mo.momx,mo.momy)
	if spd > limit then
		if factor == nil then
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakes(mo,factor)
		return factor
	end
end)

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

PTV3.setJohnBlocks = function()
	if mapheaderinfo[gamemap].ptv3_nofofflip ~= nil then return end

	-- TODO: Don't hardcode this for just the John Block textures
	for sec in sectors.iterate do
		for rover in sec.ffloors() do
			if not rover.valid then continue end
			local side = rover.master.frontside
			
			if not (side.midtexture == R_TextureNumForName("JOHNBLK1")
			or side.midtexture == R_TextureNumForName("JOHNBLK0")) then
				continue
			end


			if side.midtexture == R_TextureNumForName("JOHNBLK0") then
				rover.flags = $|FOF_TRANSLUCENT|FOF_NOSHADE &~(FOF_SOLID|FOF_CUTLEVEL|FOF_CUTSOLIDS)
				rover.alpha = 128
			end
		end
	end
end

PTV3.switchJohnBlocks = function()
	if mapheaderinfo[gamemap].ptv3_nofofflip ~= nil then return end
	
	for sec in sectors.iterate do
		for rover in sec.ffloors() do
			if not rover.valid then continue end
			local side = rover.master.frontside
			
			if not (side.midtexture == R_TextureNumForName("JOHNBLK1")
			or side.midtexture == R_TextureNumForName("JOHNBLK0")) then
				continue
			end
			
			local oppositeface = oppositefaces[
				string.sub(R_TextureNameForNum(side.midtexture),1,8)
			]
				
			--???????
			if oppositeface == nil then continue end
			
			--awake to asleep
			if rover.flags & FOF_SOLID then
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

--- Force the player to lap under certain conditions.
--- @param p player_t
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

--- Can the game switch to Overtime?
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

--- Ends the game.
function PTV3:endGame()
	if PTV3.game_over <= 0 then return end

	PTV3.game_over = max($-1, 0)
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

--- Can enter the Exit Gate?
---@param p player_t
function PTV3:canExit(p)
	if (p and p.ptv3 and p.ptv3.chaser) then return false end
	return true
end

---@param p player_t
function PTV3:doPlayerExit(p)
	if not (p and p.ptv3 and not p.ptv3.fake_exit) then return end

	if not (p.ptv3.extreme or PTV3.overtime)
	and p.ptv3.laps < self.max_laps then
		p.ptv3.canLap = 5*TICRATE
	end
	S_StartSound(p.mo, sfx_winer)

	p.ptv3.fake_exit = true
end

--- Enters Extreme Mode.
---@param p player_t
function PTV3:extremeToggle(p)
	p.ptv3.extreme = true
	if not self.extreme then
		self.extreme = true

		P_SetSkyboxMobj(nil, false)
		P_SetupLevelSky(1029)
		S_StartSound(nil, P_RandomRange(41,43))
		P_FlashPal(consoleplayer, 1, 15)

		if globalweather ~= (1 or 5) then
			P_SwitchWeather(5)
		elseif globalweather == 6 then P_SwitchWeather(1) end
	end
end

--- Enters Overtime.
function PTV3:overtimeToggle()
	if self.overtime then return end
	self.overtime = true
	self.overtimeStart = leveltime

	if not self.wartimer then
		self.wartimer = true
		self.wartimerStart = leveltime
	end

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
---@param p player_t
---@param relative boolean
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
---@param p player_t
---@param int number
function PTV3:newLap(p, int)
	if not (self.pizzatime or self.minusworld) then return end
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
		self:queueTeleport(p, PTV3.pizzatime < 0 and PTV3.spawn or PTV3.endpos, p.ptv3.extreme)
	end

	-- For the quakes
	if (PTV3.pizzatime < 0 or PTV3.extreme) then PTV3.shakeintensity = min(p.ptv3.laps, 5) end

	p.ptv3.lap_time = leveltime
	p.powers[pw_invulnerability] = 5*TICRATE

	if p == displayplayer then
		S_StartSound(nil, PTV3.pizzatime < 0 and sfx_lap_2 or sfx_lap2, p)
	end

	if p.ptv3.isSwap and p.ptv3.isSwap.valid then
		p.ptv3.isSwap.powers[pw_invulnerability] = 5*TICRATE
	end

	if p.ptv3.combo then
		p.ptv3.combo_pos = self.MAX_COMBO_TIME
	end

	if gametype ~= GT_PTV3DM then
		-- Speed up Pizzaface
		if self.pizzaface and self.pizzaface.angry then
			self.pizzaface.skindata.incremspeed = $+(FU/(self.max_elaps - (self.max_elaps/2)))
			self.pizzaface.skindata.incremspeedthreshold = max($-1, 0)
		end
		-- Spawn Pizzaface
		if abs(p.ptv3.laps) >= 3 and not (self.pizzaface and self.pizzaface.valid) then
			self.pftime = 0
			if not multiplayer then PTV3.time = 0 end
		end

		-- Spawn Snick
		if abs(p.ptv3.laps) >= 4 then
			if not (self.snick and self.snick.valid) then self:snickSpawn() end

			if not self.wartimer and not multiplayer then
				self.wartimer = true
				self.wartimerStart = leveltime
			else
				self.overtime_time = multiplayer and $+(120+29)*TICRATE or $+TICRATE*60
				S_StartSound(nil, sfx_wartup, p)
			end
		end

		-- Spawn John Ghost
		if abs(p.ptv3.laps) >= 5 and not (self.johnGhost and self.johnGhost.valid) then
			self:johnGhostSpawn()
		end
	end
	
	PTV3:logEvent(event_text, 2)
	PTV3.callbacks('NewLap', p)
end

--- Starts either Pizza Time or Minus World given that int is defined, else defaults to Pizza Time. P is the player who triggered it.
---@param p player_t
---@param int number
function PTV3:startPizzaTime(p, int)
	int = $ > 0 and 1 or -1

	self.pizzatime = int
	self.hud_pt = leveltime

	local callback_string = self.pizzatime < 0 and 'MinusWorld' or 'PizzaTime'
	PTV3.shakeintensity = 2

	if self.pizzatime < 0 then
		if PTV3.spawnGate and PTV3.spawnGate.valid then
			P_SetOrigin(PTV3.spawnGate, PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z)
			PTV3.spawnGate.angle = PTV3.endpos.a
		end

		S_StartSound(nil, sfx_s3k9f)
	end

	for player in players.iterate do
		if not player.mo and not player.ptv3 then continue end

		player.ptv3.laps = $+int

		if (player.ptv3.insecret) then player.ptv3.secret_tptoend = true end

		if int < 0 then
			self:queueTeleport(player, self.spawn)
		elseif player ~= p then
			self:queueTeleport(player, self.endpos)
		end

		player.powers[pw_invulnerability] = 5*TICRATE
		
		if player.ptv3.combo then player.ptv3.combo_pos = PTV3.MAX_COMBO_TIME end
	end

	local event = self.pizzatime < 0 and "Minus World" or "Pizza Time"

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
	PTV3.callbacks(callback_string, p)
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
