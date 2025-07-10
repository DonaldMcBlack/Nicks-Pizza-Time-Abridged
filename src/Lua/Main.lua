sfxinfo[freeslot("sfx_winer")].caption = "You won!"

local cutsceneTime = PTV3.maxTitlecardTime+(2*TICRATE)

sfxinfo[freeslot "sfx_wartim"].caption = "Beep!"
sfxinfo[freeslot "sfx_timexp"].caption = "BOOM!"
sfxinfo[freeslot "sfx_doorsh"].caption = "SLAM!"

addHook("ThinkFrame", function()
	if PTV3.pizzatime or PTV3.minusworld then P_StartQuake(PTV3.shakeintensity*FU, -1) end
end)

local function SpawnGateController(MaxTimeOpen)

	if (leveltime > MaxTimeOpen and not (PTV3.pizzatime or PTV3.minusworld))
	or (PTV3.game_over >= 0 and (PTV3.pizzatime or PTV3.minusworld)) then
		if PTV3.spawnGate._frame ~= A then
			S_StartSound(PTV3.spawnGate, sfx_doorsh)
			P_StartQuake(FU*5, TICRATE/2)
		end

		PTV3.spawnGate._frame = A

		if gametype == GT_PTV3DM and not (PTV3.pizzaface and PTV3.pizzaface.valid) then
			PTV3:pizzafaceSpawn()
		end
	else
		PTV3.spawnGate._frame = B
	end
end

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end
	if displayplayer then
		local skin = displayplayer.mo and displayplayer.mo.skin or displayplayer.skin

		if skin == "takisthefox" then
			customhud.disable("PTV3_Timer")
			customhud.disable("PTV3_Pizzaface Timer")
			customhud.disable("PTV3_Pizza Time")
		else
			customhud.enable("PTV3_Timer")
			customhud.enable("PTV3_Pizzaface Timer")
			customhud.enable("PTV3_Pizza Time")
			hud.enable("rings")
			hud.enable("score")
		end

		if ((displayplayer.pflags & PF_FINISHED) or displayplayer.exiting) then
			displayplayer.exiting = 0
			displayplayer.pflags = $ & ~(PF_FINISHED | PF_FULLSTASIS)
		end

		-- if ((p.pflags & PF_FINISHED) or p.exiting) then
		-- 	p.exiting = 0
		-- 	p.pflags = $ & ~(PF_FINISHED | PF_FULLSTASIS)
		-- end
	end

	if multiplayer then G_SetCustomExitVars(M_MapNumber("PT")) end

	if #PTV3.tplist > 0 then
		for _, tps in pairs(PTV3.tplist) do
			if not tps then continue end
			
			if tps.mo == nil or not (tps.mo and tps.mo.valid and tps.mo.player) then
				table.remove(PTV3.tplist, tonumber(_))
				continue
			end

			local p = tps.mo.player
			P_SetOrigin(tps.mo, tps.coords.x, tps.coords.y, tps.coords.z)
			p.mo.angle = tps.coords.a

			if tps.relative then
				P_InstaThrust(p.mo, tps.coords.a, p.speed)
			else
				tps.mo.momx, tps.mo.momy, tps.mo.momz = 0,0,0
			end

			if p.ptv3.lap_in then p.ptv3.lap_in = false end

			p.ptv3.fake_exit = false
			p.mo.flags2 = $ & ~MF2_DONTDRAW

			if (PTV3.pizzaface and PTV3.pizzaface.valid)
			and PTV3.pizzaface.target == (p and p.mo)
			and tps.source ~= PTV3.johnGhost then
				local pizza = PTV3.pizzaface
				P_SetOrigin(pizza, tps.coords.x, tps.coords.y, tps.coords.z)
				pizza.momx, pizza.momy, pizza.momz = 0, 0, 0
				pizza.cooldown = 3*TICRATE
			end
			
			p.ptv3.currentTeleportDest = tps.coords
			table.remove(PTV3.tplist, tonumber(_))
		end
	end

	if PTV3.spawnGate and PTV3.spawnGate.valid then
		if PTV3.titlecards[gamemap] then
			SpawnGateController(PTV3.maxTitlecardTime+TICRATE)
		else
			SpawnGateController(TICRATE)
		end
	end

	if PTV3.game_over > -1 then
		if leveltime - PTV3.game_over > 5*TICRATE then
			G_ExitLevel()
		end
		return
	end

	-- Everything that's controlled when the timer starts is in here.
	if (PTV3.pizzatime or PTV3.minusworld) then
		PTV3.time = max(0, $-1)

		if consoleplayer then consoleplayer.realtime = PTV3.time end

		if multiplayer then
			PTV3.pftime = max(0, $-1)
			if not PTV3.pftime then PTV3:pizzafaceSpawn() end

			if not PTV3.overtime
			and PTV3.time <= 5*TICRATE
			and not PTV3.__fadedmus then
				local maxtime = min(5*TICRATE, PTV3.time)
				S_FadeMusic(25, maxtime*MUSICRATE/TICRATE)
				PTV3.__fadedmus = true
			end

			if not (PTV3.time)
			and not PTV3.overtime then
				if PTV3:canOvertime() then
					PTV3:overtimeToggle()
				else
					PTV3:endGame()
				end
			end
		else
			if not PTV3.time and not (PTV3.pizzaface and PTV3.pizzaface.valid) then PTV3:pizzafaceSpawn() end
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

	if #alive
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
			PTV3.pizzaface.intspeed = $+increase
		else
			PTV3.pizzaface.intspeed = $+FixedMul(increase, FU+FU/3)
		end
	end

	if PTV3.titlecards[gamemap]
	and consoleplayer
	and not PTV3.pizzatime then
		consoleplayer.realtime = max(0, leveltime-cutsceneTime)
	end

	if HAPPY_HOUR then -- happy hour support
		local hh = HAPPY_HOUR
		hh.othergt = PTV3:isPTV3()
		hh.happyhour = (PTV3.pizzatime or PTV3.minusworld) --and (PTSR.gameover == false)
		hh.timelimit = PTV3.maxtime
		hh.timeleft = PTV3.time
		hh.time = (PTV3.pizzatime or PTV3.minusworld) and leveltime-PTV3.hud_pt or 0
		hh.overtime = PTV3.overtime
		hh.gameover = PTV3.game_over > 0
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