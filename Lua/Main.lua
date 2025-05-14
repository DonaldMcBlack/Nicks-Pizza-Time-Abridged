sfxinfo[freeslot("sfx_winer")].caption = "You won!"

local cutsceneTime = PTV3.maxTitlecardTime+(2*TICRATE)

local function FakeExit(p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then return end
	if not p.ptv3.fake_exit then return end

	if p.ptv3.swapModeFollower
	and p.ptv3.swapModeFollower.valid then
		return
	end

	p.pflags = $|PF_FULLSTASIS

	if ((p.cmd.buttons & BT_ATTACK
	and not (p.ptv3.buttons & BT_ATTACK))
	and p.ptv3.canLap)
	or p.ptv3.extreme
	or gametype == GT_PTV3DM then
		if gametype == GT_PTV3
		and p.ptv3.laps == PTV3.max_laps then
			if p.ptv3.extremeNotif then
				if p.ptv3.extremeNotif < 4*TICRATE
					PTV3:newLap(p)
				end
			else
				p.ptv3.extremeNotif = 5*TICRATE
				p.ptv3.canLap = 5*TICRATE
			end
		else
			if p.ptv3.canLap > TICRATE then
				p.ptv3.canLap = TICRATE
			end
			PTV3:newLap(p)
		end
	end
end

addHook('PlayerSpawn', function(p)
	if not PTV3:isPTV3() then return end
	if not (p and p.mo) then return end
	if not p.ptv3 then PTV3:player(p) end

	if PTV3.pizzatime then
		PTV3:teleportPlayer(p)
	end
	if p.ptv3.insecret then
		local link = PTV3.secrets[p.ptv3.insecret][0]
		PTV3:teleportPlayer(p, {x=link.x,y=link.y,z=link.z,a=p.mo.angle})
		return
	end
end)

addHook('MobjDamage', function(mo)
	if not PTV3:isPTV3() then return end
	if not mo.player then return end

	mo.player.score = max($-250, 0)
end, MT_PLAYER)

states[freeslot "S_PTV3_WALKANIM"] = {
	sprite = SPR_PLAY,
	frame = SPR2_WALK,
	tics = 3,
	nextstate = S_PTV3_WALKANIM
}

local function normalThinker(p)
	--[[if not PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.endsec then
		PTV3:startPizzaTime(p)
	end]]

	if leveltime < cutsceneTime
	and PTV3.spawnGate
	and PTV3.spawnGate.valid then
		if leveltime < PTV3.maxTitlecardTime then return end

		local time = leveltime - PTV3.maxTitlecardTime
		local remain = cutsceneTime - leveltime

		local tweenTime = min(FixedDiv(time, TICRATE), FU)

		local spawn = PTV3.spawnGate.spawnPoints[#p+1] or PTV3.spawnGate.spawnPoints[1]
		local sg = PTV3.spawnGate

		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		p.drawangle = sg.angle

		local tweenX = ease.outcubic(tweenTime, sg.x, spawn.x)
		local tweenY = ease.outcubic(tweenTime, sg.y, spawn.y)
		local tweenZ = ease.outcubic(tweenTime, sg.z, spawn.z)

		P_SetOrigin(p.mo,
			tweenX,
			tweenY,
			tweenZ)

		if remain > 1 then
			local state = S_PTV3_WALKANIM
			if remain < TICRATE then
				state = S_PLAY_PAIN
			end
			if p.mo.state ~= state then
				p.mo.state = state
			end
			p.mo.angle = PTV3.spawnGate.angle+ANGLE_180
		else
			p.mo.state = S_PLAY_STND
			p.mo.angle = PTV3.spawnGate.angle
		end

		return
	end

	if not (PTV3.spawnGate and PTV3.spawnGate.valid)
	and not p.ptv3.fake_exit
	and PTV3.spawnsector
	and PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.spawnsector
	and PTV3:canExit(p) then
		PTV3:doPlayerExit(p)
	end

	if PTV3.pizzatime
	and not (leveltime % TICRATE) 
	and not p.ptv3.pizzaface
	and not p.ptv3.fake_exit
	and p.score > 0 then
		local reduceBy = 10
		if p.ptv3.extreme then
			reduceBy = 20
		end
		if PTV3.overtime then
			reduceBy = 40
		end
		p.score = max(0, $-reduceBy)
		p.ptv3.scoreReduce = leveltime
	end

	PTV3.callbacks("PlayerThink", p)

	FakeExit(p)

	if p.ptv3.isSwap
	and p.ptv3.isSwap.valid then
		local p2 = p.ptv3.isSwap
		
		p2.ptv3.banana = p.ptv3.banana
		p2.ptv3.banana_angle = p.ptv3.banana_angle
		p2.ptv3.banana_speed = p.ptv3.banana_speed

		if p2.ptv3
		and p2.ptv3.swapModeFollower ~= p.mo then
			p2.ptv3.swapModeFollower = p.mo
		end

		if (not (p.ptv3.fake_exit) and p.cmd.buttons & BT_ATTACK
		and not (p.ptv3.buttons & BT_ATTACK))
		and p2.mo
		and p2.mo.health then
			P_SetOrigin(p2.mo, p.mo.x, p.mo.y, p.mo.z)
			p.ptv3.savedData = {}
		
			PTV3:initSwapMode(p, p2)
		end
	end

	table.insert(p.ptv3.savedData, {
		x = p.mo.x,
		y = p.mo.y,
		z = p.mo.z,
		angle = p.drawangle,
		momx = p.mo.momx,
		momy = p.mo.momy,
		momz = p.mo.momz
	})

	if #p.ptv3.savedData > (3*6) then
		table.remove(p.ptv3.savedData, 1)
	end
end

local function followerThinker(p)
	p.pflags = $|PF_FULLSTASIS

	local flwr = p.ptv3.swapModeFollower.player
	
	p.score = flwr.score
	p.rings = flwr.rings

	if p.ptv3.isSwap
	and flwr ~= p.ptv3.isSwap then
		p.ptv3.swapModeFollower = p.ptv3.isSwap.mo
		flwr = p.ptv3.isSwap
	end

	local smT = PTV3.callbacks("SwapModeThinker", p)

	if not smT then
		PTV3:doFollowerTP(p.mo, flwr, 2)
	end
end

local function cAngle(p)
	return p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, p.cmd.forwardmove*FRACUNIT, -p.cmd.sidemove*FRACUNIT)
end

addHook("ShouldDamage", function(t,i,s)
	if not (t and t.player and t.player.ptv3 and t.player.ptv3.pizzaface) then return end

	return false
end)

addHook('PlayerThink', function(p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then PTV3:player(p) end

	p.spectator = p.ptv3.specforce

	if p.ptv3.specforce then
		return
	end

	if not p.mo then return end

	if PTV3.game_over > 0 then
		p.pflags = $|PF_FULLSTASIS
		p.deadtimer = 130
		return
	end

	p.ptv3.pvpCooldown = max(0, $-1)
	p.ptv3.extremeNotif = max(0, $-1)

	if p.ptv3.pizzaface then
		p.powers[pw_shield] = SH_NONE
		p.mo.scale = FU*5/4
		p.mo.flags2 = $|MF2_DONTDRAW
		if PTV3.pizzaface
		and PTV3.pizzaface.valid then
			PTV3.pizzaface.tracer = p.mo
		end
		p.pflags = $|PF_THOKKED & ~PF_SPINNING
		p.mo.skin = "sonic"
		p.mo.momx = 0
		p.mo.momy = 0
		p.mo.momz = 0
		if not (PTV3.pftime) then
			p.ptv3.pizzaStun = max(0, $-1)
		end
		if not (p.ptv3.pizzaStun)
		and not (PTV3.pftime)
		and (PTV3.pizzaface and not PTV3.pizzaface.cooldown) then
			local speed = ease.linear(FixedDiv(p.ptv3.pfBoost, p.ptv3.maxPfBoost), 27*FU, 42*FU)
			local isMoving = false
			local moveAngle
			local airDir = 0
			local increaseTime = 0
			
			p.ptv3.pfBoost = max(0, $-1)
			if p.cmd.buttons & BT_JUMP then
				isMoving = true
				airDir = 1
			end
			if p.cmd.buttons & BT_SPIN then
				isMoving = true
				airDir = -1
			end
			if abs(abs(p.cmd.sidemove) > 10 and p.cmd.sidemove or 0)
			or abs(abs(p.cmd.forwardmove) > 10 and p.cmd.forwardmove or 0) then
				moveAngle = cAngle(p)
				isMoving = true
			end
			if isMoving then
				if p.cmd.buttons & BT_CUSTOM1
				and not (p.ptv3.buttons & BT_CUSTOM1)
				and not (p.ptv3.pfBoost) then
					p.ptv3.pfBoost = p.ptv3.maxPfBoost
					speed = ease.linear(FixedDiv(p.ptv3.pfBoost, p.ptv3.maxPfBoost), 27*FU, 35*FU)
				end
				if moveAngle ~= nil then
					p.mo.momx = FixedMul(speed, cos(moveAngle))
					p.mo.momy = FixedMul(speed, sin(moveAngle))
				end
				p.mo.momz = speed*airDir
			else
				p.ptv3.pfBoost = 0
			end
			P_MovePlayer(p)

			if not p.ptv3.pfcamper then
				if isMoving then
					p.ptv3.pfcamper_movetime = $+1
				else
					p.ptv3.pfcamper_movetime = 0
				end
	
				if p.ptv3.pfcamper_movetime then
					increaseTime = $+1
					if p.ptv3.pfcamper_movetime > 10 then
						increaseTime = $+1
					end
				end
		
				if increaseTime then
					if increaseTime == 2 then
						p.ptv3.pfcamper_time = min(2*TICRATE, $+1)
					end
				else
					p.ptv3.pfcamper_time = max(0, $-1)
				end

				if not (p.ptv3.pfcamper_time) then
					p.ptv3.pfcamper = true
				end
			else
				local sectorCount = 0
				local sectors = p.ptv3.pfcamper_sectors

				if not sectors[p.mo.subsector.sector] then
					sectors[p.mo.subsector.sector] = true
				end

				for sec,_ in pairs(sectors) do
					sectorCount = $+1
				end

				if sectorCount > 4 then
					-- its really 3 but it also counts the players sector that this started in
					p.ptv3.pfcamper_time = 2*TICRATE
					p.ptv3.pfcamper_movetime = 0
					p.ptv3.pfcamper_sectors = {}
					p.ptv3.pfcamper = false
				end
			end
		else
			p.ptv3.pfcamper_time = 2*TICRATE
			p.ptv3.pfcamper_movetime = 0
			p.ptv3.pfcamper_sectors = {}
			p.ptv3.pfcamper = false
		end
	elseif PTV3.pizzatime
	and not PTV3.panicSpriteBlacklist[p.mo.skin] then
		local speed = FixedHypot(p.rmomx, p.rmomy)

		if speed == 0
		and P_IsObjectOnGround(p.mo) 
		and not (p.pflags & (PF_SPINNING|PF_STARTDASH))then
			if p.mo.state == S_PLAY_STND then
				p.mo.state = S_PTV3_PANIC
			end
		elseif p.mo.state == S_PTV3_PANIC then
			if speed >= 0
			and P_IsObjectOnGround(p.mo) then
				p.mo.state = S_PLAY_WALK
			end
			if p.pflags & PF_STARTDASH then
				p.mo.state = S_PLAY_SPINDASH
			end
			if p.pflags & PF_SPINNING then
				p.mo.state = S_PLAY_ROLL
			end
		end
	end

	if (p.ptv3.swapModeFollower
	and p.ptv3.swapModeFollower.valid) then
		followerThinker(p)
	else
		normalThinker(p)
	end

	p.ptv3.buttons = p.cmd.buttons
end)

addHook('ThinkFrame', function()
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if not p.mo then continue end
		if not p.ptv3 then continue end
		if p.ptv3.specforce then continue end
		if p.ptv3.swapModeFollower
		and p.ptv3.swapModeFollower.valid then continue end

		if p.ptv3.banana
		and P_IsObjectOnGround(p.mo) then
			p.ptv3.banana = $-1
			p.mo.momz = 8*(FU*P_MobjFlip(p.mo))
		end
	end
end)

addHook("ShouldDamage", function(mobj)
	if not (mobj
	and mobj.valid
	and mobj.player
	and mobj.player.ptv3
	and mobj.player.ptv3.swapModeFollower) then
		return
	end

	return false
end, MT_PLAYER)

sfxinfo[freeslot "sfx_wartim"].caption = "Beep!"

addHook("PlayerCmd", function(p, cmd)
	if not PTV3:isPTV3() then return end
	if not (PTV3.spawnGate
	and PTV3.spawnGate.valid
	and leveltime < cutsceneTime) then
		if not (p and p.ptv3 and p.ptv3.fake_exit) then return end
	end

	local buttons = 0
	if (p and p.ptv3 and p.ptv3.fake_exit)
	and cmd.buttons & BT_ATTACK then
		buttons = $|BT_ATTACK
	end

	cmd.buttons = buttons
	cmd.forwardmove = 0
	cmd.sidemove = 0
end)

sfxinfo[freeslot "sfx_doorsh"].caption = "SLAM!"

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	G_SetCustomExitVars(M_MapNumber("LB"))

	for p in players.iterate do
		if p.ptv3 then
			p.ptv3.canLap = max(0, $-1)
			PTV3:checkRank(p)
			local percent = PTV3:returnNextRankPercent(p)
		end
	end

	if PTV3.spawnGate
	and PTV3.spawnGate.valid then
		if leveltime > PTV3.maxTitlecardTime+TICRATE
		and not PTV3.pizzatime then
			if PTV3.spawnGate._frame ~= A then
				S_StartSound(PTV3.spawnGate, sfx_doorsh)
				P_StartQuake(FU*5, TICRATE/2)
			end
			PTV3.spawnGate._frame = A
			if gametype == GT_PTV3DM
			and not (PTV3.pizzaface and PTV3.pizzaface.valid) then
				PTV3:pizzafaceSpawn()
			end
		else
			PTV3.spawnGate._frame = B
		end
	end

	if PTV3.game_over > -1 then
		if leveltime - PTV3.game_over > 5*TICRATE then
			G_ExitLevel()
		end
		return
	end

	if PTV3.pizzatime then
		PTV3.time = max(0, $-1)
		PTV3.pftime = max(0, $-1)
		if not PTV3.overtime
		and PTV3.time <= 5*TICRATE
		and not PTV3.__fadedmus then
			local maxtime = min(5*TICRATE, PTV3.time)
			S_FadeMusic(25, maxtime*MUSICRATE/TICRATE)
			PTV3.__fadedmus = true
		end
		if PTV3.overtime then
			PTV3.overtime_time = max(0, $-1)
			if PTV3.overtime_time
			and not (PTV3.overtime_time % TICRATE) then
				S_StartSoundAtVolume(nil, sfx_wartim, 255/3)
			end

			if PTV3.overtime_time == 0
			or not PTV3:canOvertime() then
				PTV3:endGame()
			end
		end
	end

	if not (PTV3.time)
	and not PTV3.overtime then
		--if PTV3:canOvertime() then
		if PTV3:canOvertime() then
			PTV3:overtimeToggle()
		else
			PTV3:endGame()
		end
	end

	local alive, pizzafaces, finished, unfinished, alive_2, total = PTV3:playerCount()

	if gametype == GT_PTV3DM
	and not PTV3.overtime
	and PTV3.pizzatime
	and #total > 2
	and #alive <= 2 then
		PTV3:overtimeToggle()
	end

	if (PTV3.pizzaface or PTV3.snick)
	and multiplayer
	and #alive == 0 then
		PTV3:endGame()
	end

	if multiplayer
	and #alive
	and #finished == #alive then
		local canEnd = true

		for p in players.iterate do
			if not (p and p.mo and p.ptv3 and not p.ptv3.specforce) then continue end

			if p.ptv3.canLap then
				canEnd = false
				break
			end
		end

		if canEnd then
			PTV3:endGame()
		end
	end

	if gametype == GT_PTV3DM
	and PTV3.pizzaface
	and PTV3.pizzaface.valid then
		local increase = (FU/(TICRATE*18))
		if not PTV3.overtime then
			PTV3.pizzaface.flyspeed = $+increase
		else
			PTV3.pizzaface.flyspeed = $+FixedMul(increase, FU+FU/3)
		end
	end

	if PTV3.pizzatime and not (PTV3.pftime) and not PTV3.pizzaface then
		PTV3:pizzafaceSpawn()
	end
	if PTV3.pizzatime and consoleplayer then
		consoleplayer.realtime = PTV3.time
	end
	if PTV3.titlecards[gamemap]
	and consoleplayer
	and not PTV3.pizzatime then
		consoleplayer.realtime = max(0, leveltime-cutsceneTime)
	end
end)

addHook("MobjDeath", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.player) then return end

	s.player.score = $+15
end, MT_RING)

addHook("MobjDamage", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (t and t.player) then return end

	t.player.score = max(0, $-350)
end, MT_PLAYER)

addHook("PlayerCmd", function(p, cmd)
	if not PTV3:isPTV3() then return end
	if not (PTV3.game_over > 0) then return end

	cmd.buttons = 0
	cmd.forwardmove = 0
	cmd.sidemove = 0
end)

addHook("MobjDeath", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (i and i.valid and (i.type == MT_PTV3_PIZZAFACE or i.type == MT_PLAYER)) then return end
	if not (t and t.player and t.player.ptv3) then return end

	if t.player.ptv3.swapModeFollower then
		local mo = t.player.ptv3.swapModeFollower

		mo.player.ptv3.swapModeFollower = nil
		mo.player.ptv3.isSwap = nil
	end
	t.player.ptv3.isSwap = nil
	t.player.ptv3.swapModeFollower = nil
end, MT_PLAYER)