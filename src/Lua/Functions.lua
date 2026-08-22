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

--- Checks if the gamemode is IT. Use true to skip the GS_LEVEL check.
---@param dontCheckState boolean
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

-- Returns players in-game into individual counts. Alive, Chasers, Finished, Unfinished, and Total.
function PTV3:playerCount()
	if not PTV3:isPTV3(true) then return end
	local total = {}
	local alive = {}
	local chasers = {}
	local finished = {}
	local unfinished = {}

	for p in players.iterate do
		if not p.PTRound then continue end
		-- if p.PTRound.swapModeFollower then continue end
		if p and p.valid then
			table.insert(total, p)
		end
		if p.PTRound.chaser then
			table.insert(chasers, p)
			continue
		end
		if p.mo and p.mo.valid and p.mo.health then -- not p.PTRound.swapModeFollower
			table.insert(alive, p)
			if p.PTRound.fake_exit then
				table.insert(finished, p)
			else
				table.insert(unfinished, p)
			end
		end
	end
	
	return alive, chasers, finished, unfinished, total
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

--- Can the player lap?
--- @param p player_t
function PTV3:canLap(p)
	if not p.PTRound then return 0 end
	if p.PTRound.chaser then return 0 end

	if gametype == GT_PTV3DM then
		return 1
	end

	if not self.overtime then
		if p.PTRound.extreme then
			if p.PTRound.laps < self.max_laps+self.max_elaps then return 1 end
		else
			if self.max_elaps and p.PTRound.laps > self.max_laps then
				return 2
			end

			if p.PTRound.laps <= self.max_laps then
				return 1
			end
		end
	end
	return 0
end

--- Force the player to lap under certain conditions.
--- @param p player_t
function PTV3:forceLap(p)
	if p.PTRound.chaser then return false end

	if gametype == GT_PTV3DM then
		return true
	end

	if p.PTRound.extreme
	and p.PTRound.laps < self.max_laps+self.max_elaps then
		return true
	end

	return false
end

--- Can the game switch to Overtime?
function PTV3:canOvertime()
	local alive, pizzafaces, finished, unfinished, total = PTV3:playerCount()
	local normalLappers = {}
	local extremeLappers = {}

	for _,p in pairs(alive) do
		if not (p and p.PTRound and not p.PTRound.specforce) then continue end

		if p.PTRound.extreme then
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
	
	if PTV3.endtime < 0 then PTV3.endtime = leveltime end

	PTV3.game_over = max($-1, 0)
	for p in players.iterate do
		if p.mo and p.mo.valid then
			if (not p.PTRound.fake_exit) and p.playerstate ~= PST_DEAD then
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
	if (p and p.PTRound and p.PTRound.chaser) then return false end
	return true
end

---@param p player_t
function PTV3:doPlayerExit(p)
	if not (p and p.PTRound and not p.PTRound.fake_exit) then return end

	if not (p.PTRound.extreme or PTV3.overtime)
	and p.PTRound.laps < self.max_laps then
		p.PTRound.canLap = 5*TICRATE
	end
	S_StartSound(p.mo, sfx_winer)

	p.PTRound.fake_exit = true
end

--- Enters Extreme Mode.
---@param p player_t
function PTV3:extremeToggle(p)
	p.PTRound.extreme = true
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
	and consoleplayer.PTRound
	and not consoleplayer.PTRound.insecret then
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

	local start_or_end = PTV3.pizzatime > 0 and self.endpos or self.spawn

	local mobjteleport = {
		mo = p.mo,
		coords = coords or start_or_end,
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
	if not self.pizzatime then return end
	if not (self:canLap(p)) then return end

	-- if p.PTRound.isSwap and not p.PTRound.swapModeFollower then
	-- 	self:newLap(p.PTRound.isSwap, int)
	-- end

	if not int then return end
	p.PTRound.laps = $+int
	self.highestlap = $ < p.PTRound.laps and p.PTRound.laps or $

	local raw_time = leveltime - PTV3.starttime_pizzatime

	if p.PTRound.lap_time >= 0 then
		raw_time = leveltime - p.PTRound.lap_time
	end

	local time = string.format( "%02d:%02d", G_TicsToMinutes(raw_time), G_TicsToSeconds(raw_time) )
	local event_text = p.name.." has made it to Lap "..p.PTRound.laps.." in "..time.."!"

	if self:canLap(p) == 2 then
		self:extremeToggle(p)
		event_text = $.." If Overtime starts while in Extreme Laps, then this player will die."
	end

	if p.PTRound.extreme then
		event_text = $:gsub("to Lap", "to Extreme Lap")
	else
		P_AddPlayerScore(p, 3000)
	end

	if (PTV3.spawnGate and PTV3.spawnGate.valid) and PTV3.spawnGate.lappers[p] then
		PTV3.spawnGate.lappers[p] = false
	end

	if abs(p.PTRound.laps) ~= 1 then
		self:queueTeleport(p, PTV3.pizzatime < 0 and PTV3.spawn or PTV3.endpos, p.PTRound.extreme)
	end

	-- For the quakes
	if (PTV3.pizzatime < 0 or PTV3.extreme) then PTV3.shakeintensity = min(abs(p.PTRound.laps), 10) end

	p.PTRound.lap_time = leveltime
	p.powers[pw_invulnerability] = 5*TICRATE

	if p == displayplayer then
		S_StartSound(nil, PTV3.pizzatime < 0 and sfx_lap_2 or sfx_lap2, p)
	end

	-- if p.PTRound.isSwap and p.PTRound.isSwap.valid then
	-- 	p.PTRound.isSwap.powers[pw_invulnerability] = 5*TICRATE
	-- end

	if p.PTRound.combo then
		p.PTRound.combo_pos = self.MAX_COMBO_TIME
	end

	if gametype ~= GT_PTV3DM then
		-- Spawn Pizzaface
		if abs(p.PTRound.laps) >= 3 and not (self.pizzaface and self.pizzaface.valid) then
			self.pftime = 0
			if not multiplayer then PTV3.time = 0 end
		end

		-- Spawn Snick
		if abs(p.PTRound.laps) >= 4 then
			if not (self.snick and self.snick.valid) then self:snickSpawn() end

			if not self.wartimer and not multiplayer then
				self.wartimer = true
				self.wartimerStart = leveltime
			elseif self.wartimer and not multiplayer then
				if PTV3.pizzatime < 0 then
					PTV3.overtime_time = PTV3.maxottime
					PTV3.overtime_elapser = 0
					S_StartSound(nil, sfx_static)
				else
					self.overtime_time = $+self.maxottime
					S_StartSound(nil, sfx_wartup, p)
				end
			end
		end

		-- Spawn John Ghost
		if abs(p.PTRound.laps) >= 5 and not (self.johnGhost and self.johnGhost.valid) then
			self:johnGhostSpawn()
		end
	end

	if p.PTRound.pizzapost_id then p.PTRound.pizzapost_id = nil end
	
	PTV3:logEvent(event_text, 2)
	PTV3.callbacks('NewLap', p)
end

function PTV3:getNearestPlayer(pos, conditions, type)
	local x,y,z,pl,pm

	for p in players.iterate do
		if not p.mo then continue end
		if conditions and not conditions(p) then continue end
		
		local newx = abs(p.mo.x - pos.x)
		local newy = abs(p.mo.y - pos.y)
		local newz = abs(p.mo.z - pos.z)

		if (x == nil
		or y == nil
		or z == nil)
		or (newx < x
		and newy < y
		and newz < z) then
			x = newx
			y = newy
			z = newz
			pl = p
			pm = p.mo
		end
	end

    -- unlike pf, get the furthest player
    -- the winners need to suffer
    if type == "player_t" then return pl end

	return pm
end

--- Load a chaser's skin into memory.
---@param chaser string
---@param properties table
function PTV3:LoadChaserSkin(chaser, properties)
    if not string then error("No chaser specified") end
	if not properties then error(chaser.." skin not found.") return end
	if type(properties) ~= "table" then error(chaser.." skin is not a table.") return end

	local default_struct = PTV3_SKINS[chaser][0]

	for i,v in pairs(default_struct) do
		if properties[i] == nil or type(properties[i]) ~= type(default_struct[i]) then
			properties[i] = default_struct[i]
		end
	end

	table.insert(PTV3_SKINS[chaser], properties)
end

--- Applies a selected skin to a chaser. Returns skin data.
---@param chaser string
---@param selectedskin table
function PTV3:ApplyChaserSkin(chaser, selectedskin)
	local default_struct = PTV3_SKINS[chaser][0]
	local fresh_skin = {}

	for i, v in pairs(default_struct) do
		if fresh_skin[i] ~= selectedskin[i] then fresh_skin[i] = selectedskin[i] end
	end

	if not fresh_skin then
		error("Skin is null. Picking default skin.")
		fresh_skin = PTV3_SKINS[chaser][0]
	end

	return fresh_skin
end

--- Starts either Pizza Time or Minus World given that int is defined, else defaults to Pizza Time. P is the player who triggered it.
---@param p player_t
---@param int number
function PTV3:startPizzaTime(p, int)
	int = $ > 0 and 1 or -1

	self.pizzatime = int
	self.starttime_pizzatime = leveltime

	local callback_string = self.pizzatime < 0 and 'MinusWorld' or 'PizzaTime'
	PTV3.shakeintensity = 4

	if self.pizzatime < 0 then
		if PTV3.spawnGate and PTV3.spawnGate.valid then
			P_SetOrigin(PTV3.spawnGate, PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z)
			PTV3.spawnGate.angle = PTV3.endpos.angle
		end

		PTV3.overtime_time = mapheaderinfo[gamemap].ptv3_msecs ~= nil and (tonumber(mapheaderinfo[gamemap].ptv3_msecs)*TICRATE) or $/2
		PTV3.maxottime = PTV3.overtime_time

		S_StartSound(nil, sfx_s3k9f)
	end

	for player in players.iterate do
		if not player.mo and not player.PTRound then continue end

		player.PTRound.laps = $+int

		if (player.PTRound.insecret) then player.PTRound.secret_tptoend = true end

		if int < 0 then
			self:queueTeleport(player, self.spawn)
		elseif player ~= p then
			self:queueTeleport(player, self.endpos)
		end

		player.powers[pw_invulnerability] = 5*TICRATE
		
		if player.PTRound.combo then player.PTRound.combo_pos = PTV3.MAX_COMBO_TIME end
	end

	local event = self.pizzatime < 0 and "Minus World" or "Pizza Time"

	local time = string.format( "%02d:%02d", G_TicsToMinutes(leveltime), G_TicsToSeconds(leveltime) )
	PTV3:logEvent(p.name.." has started "..event.." in "..time.."!", 1)

	local alive, pizzafaces, finished, unfinished, total = PTV3:playerCount()

	if gametype ~= GT_PTV3DM
	and multiplayer
	and #total > 1 then
		local pfp = getRandomPlayer(function(rp)
			return rp.PTRound
			and rp ~= p
			and rp.PTRound.swapModeFollower ~= p.mo
		end)
		
		pfp.PTRound.chaser = true
		pfp.PTRound.chasertype = "pizzaface"
		pfp.powers[pw_shield] = SH_NONE
		pfp.powers[pw_invulnerability] = 0
		-- if pfp.PTRound.isSwap then
		-- 	if pfp.PTRound.swapModeFollower
		-- 	and pfp.PTRound.swapModeFollower.valid then
		-- 		local mo = pfp.PTRound.swapModeFollower
		-- 		mo.player.PTRound.swapModeFollower = nil
		-- 		mo.player.PTRound.isSwap = false
		-- 	end
		-- 	pfp.PTRound.swapModeFollower = nil
		-- 	pfp.PTRound.isSwap = false
		-- end
		if pfp.PTRound.insecret then
			PTV3:exitSecret(pfp)
		end
		PTV3:logEvent(pfp.name.." is Pizzaface for this round.", 1)
	end

	PTV3.switchJohnBlocks()
	PTV3.callbacks(callback_string, p)
end

function PTV3:initSwapMode(p, p2)
	if not (p and p2 and p.PTRound and p2.PTRound) then return false end
	if not p.mo then return false end
	if not p2.mo then return false end

	if p2.PTRound.swapModeFollower then
		p2.PTRound.swapModeFollower = nil
	end
	p.PTRound.swapModeFollower = p2.mo
	
	p.PTRound.isSwap = p2
	p2.PTRound.isSwap = p

	self:doEffect(p2.mo, "Taunt")

	return true
end

function PTV3:doFollowerTP(flwr, lder, index)
	if index == nil then index = 2 end
	if not lder.PTRound then return end
	local data = lder.PTRound.movementData
	if not data[1] then return end

	if data[#data-index] then
		local data = data[#data-index]

		if flwr.player then
			local pflags = data.pflags & ~(PF_DIRECTIONCHAR|PF_ANALOGMODE|PF_AUTOBRAKE|PF_APPLYAUTOBRAKE|PF_FORCESTRAFE)
			
			flwr.player.PTRound.fake_exit = data.fake_exit
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
