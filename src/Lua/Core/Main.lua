local cutsceneTime

local function SpawnGateController(MaxTimeOpen)
	if (leveltime > MaxTimeOpen and not PTV3.pizzatime)
	or (PTV3.game_over and PTV3.pizzatime) then
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

local function HUBThinker()
	if not multiplayer then return end
	
	local countdown_active = false
	local chosenMap = nil

	for _, gate in ipairs(PTV3_HUB.gates) do
		if gate.votes then countdown_active = true break end
	end

	PTV3.votetime = countdown_active and max(0, $-1) or 5*TICRATE
	if not (PTV3.votetime % TICRATE) and countdown_active then S_StartSound(nil, sfx_s23a) end
	if PTV3.votetime > 1 then return end

	local highestNum = 0
	for _, gate in ipairs(PTV3_HUB.gates) do
		if highestNum < gate.votes then
			highestNum = gate.votes
			chosenMap = gate.map
		end
	end

	G_SetCustomExitVars(chosenMap, 2)
	G_ExitLevel()
end

local function RoundThinker()
	local alive = PTV3:playerCount("alive")
	local finished = PTV3:playerCount("finished")
	local total = PTV3:playerCount("total")

	if PTV3.endtime > 0 then
		PTV3.game_over = max($+1, 0)
		
		if PTV3.game_over >= (21*TICRATE)-10 then
			G_SetCustomExitVars(multiplayer and M_MapNumber("PT") or nil, 1)
			G_ExitLevel()
		end
		return
	end

	-- Everything that's controlled when the timer starts is in here.
	if PTV3.pizzatime then
		PTV3.time = max(0, $-1)
		consoleplayer.realtime = PTV3.time

		if multiplayer then
			PTV3.pftime = max(0, $-1)
			if not PTV3.pftime and not (PTV3.pizzaface and PTV3.pizzaface.valid) then PTV3:pizzafaceSpawn() end

			if not PTV3.overtime
			and PTV3.time <= 5*TICRATE
			and not PTV3.__fadedmus then
				local maxtime = min(5*TICRATE, PTV3.time)
				S_FadeMusic(25, maxtime*MUSICRATE/TICRATE)
				PTV3.__fadedmus = true
			end

			if not PTV3.time and not PTV3.overtime then
				if PTV3:canOvertime() then
					PTV3:overtimeToggle()
				else
					PTV3:endGame()
				end
			end

			if #alive - #finished <= 0 then PTV3:endGame() end
		else
			if not PTV3.time and not (PTV3.pizzaface and PTV3.pizzaface.valid) then PTV3:pizzafaceSpawn() end
		end

		if PTV3.wartimer then
			PTV3.overtime_time = max(0, $-(PTV3.overtime_elapser/TICRATE))

			if PTV3.overtime_time then
				if not (PTV3.overtime_time % TICRATE) then
					S_StartSoundAtVolume(nil, sfx_wartim, 255/3)
					PTV3.overtime_elapser = PTV3.pizzatime < 0 and min($+10, 3*TICRATE) or TICRATE
				end
			else
				if not PTV3:canOvertime() and PTV3.overtime then PTV3:endGame() end
			end
		end
	elseif gametype == GT_PTV3DM and leveltime > PTV3.maxTitlecardTime then
		PTV3.pftime = max(0, $-1)
	end

	if #alive and #finished == #alive then
		local canEnd = true

		for p in players.iterate do
			if not (p and p.mo and p.PTRound and not p.PTRound.specforce) then continue end

			if p.PTRound.canLap then
				canEnd = false
				break
			end
		end

		if canEnd then
			PTV3:endGame()
		end
	end

	if gametype == GT_PTV3DM then
		if not PTV3.overtime and PTV3.pizzatime
		and #total > 2 and #alive <= 2 then
			PTV3:overtimeToggle()
		end
	end
end

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if ((p.pflags & PF_FINISHED) or p.exiting) then
			p.exiting = 0
			p.pflags = $ & ~(PF_FINISHED | PF_FULLSTASIS)
		end
	end

	if PTV3.tplist and #PTV3.tplist > 0 then
		for _, tps in pairs(PTV3.tplist) do
			if not tps then continue end
			table.remove(PTV3.tplist, tonumber(_))
			
			if not (tps.mo and tps.mo.valid and tps.mo.player and tps.mo.player.valid and tps.mo.player.mo and tps.mo.player.mo.valid) then
				continue
			end
			
			P_SetOrigin(tps.mo, tps.coords.x, tps.coords.y, tps.coords.z)
			
			tps.mo.angle = tps.coords.angle

			local p = tps.mo.player

			if tps.relative then
				P_InstaThrust(p.mo, tps.coords.angle, p.speed)
			else
				p.mo.momx, p.mo.momy, p.mo.momz = 0,0,0
			end

			p.PTRound.lap_in = $ and false or false
			p.PTRound.fake_exit = false
			p.mo.flags2 = $ & ~MF2_DONTDRAW

			if tps.source and tps.source.type == MT_PTV3_SECRET then
				p.pflags = $|PF_SPINNING|PF_JUMPED
				tps.mo.state = S_PLAY_ROLL
				P_SetObjectMomZ(tps.mo, -12*FU, false)
			end

			if (PTV3.pizzaface and PTV3.pizzaface.valid)
			and PTV3.pizzaface.target == (p and p.mo)
			and tps.source ~= PTV3.johnGhost then
				local pizza = PTV3.pizzaface
				P_SetOrigin(pizza, tps.coords.x, tps.coords.y, tps.coords.z)
				pizza.momx, pizza.momy, pizza.momz = 0, 0, 0
				pizza.cooldown = 3*TICRATE
			end
			
			p.PTRound.lastTeleportDest = tps.coords
		end
	end

	if PTV3.spawnGate and PTV3.spawnGate.valid then
		cutsceneTime = gamemap ~= M_MapNumber("PT") and PTV3.maxTitlecardTime+(2*TICRATE) or 2*TICRATE

		SpawnGateController(cutsceneTime-TICRATE)
		if consoleplayer and not PTV3.pizzatime then
			consoleplayer.realtime = max(0, leveltime-cutsceneTime)
		end
	end

	PTV3.shakeintensity = PTV3.highestlap < 10 and max(4, PTV3.highestlap) or 10

	if gamemap == M_MapNumber("PT") then HUBThinker() return end

	RoundThinker()
end)

addHook("MobjDeath", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.player) then return end

	s.player.score = $+15
end, MT_RING)