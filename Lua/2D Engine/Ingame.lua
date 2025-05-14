local function isColliding(x,y,w,h, x2,y2,w2,h2)
	return (x < x2+w2
	and x2 < x+w
	and y < y2+h2
	and y2 < y+h)
end

addHook("PreThinkFrame", do
	if not PTV3_2D:canRun() then return end

	for p in players.iterate do
		if not p.ptv3_2d then
			PTV3_2D:playerInit(p)
		end

		p.ptv3_2d.buttons = p.cmd.buttons
		p.ptv3_2d.forwardmove = p.cmd.forwardmove
		p.ptv3_2d.sidemove = p.cmd.sidemove
		-- this stops the inputs from registering within srb2 btw

		p.cmd.sidemove = 0
		p.cmd.forwardmove = 0
		p.cmd.buttons = 0
		p.pflags = $ |PF_FULLSTASIS
	end
end)

addHook("ThinkFrame", do
	if not PTV3_2D:canRun() then return end

	for p in players.iterate do
		if not p.ptv3_2d then
			PTV3_2D:playerInit(p)
		end

		local p2d = p.ptv3_2d

		local sidemove = FixedDiv(p2d.sidemove, 50)
		local forwardmove = FixedDiv(p2d.forwardmove, 50)

		if abs(sidemove) >= FU/25 then
			local maxMoveTime = 9
			p2d.acceltime = min($+1, maxMoveTime)

			local dir = sidemove > 0 and 1 or -1
			p2d.dir = dir

			p2d.momx = FixedMul(12*abs(sidemove), FixedDiv(p2d.acceltime, maxMoveTime))*dir
		else
			p2d.momx = 0
			p2d.acceltime = 0
		end

		p2d.momy = $+(FU*2)

		if p2d.grounded
		and p2d.buttons & BT_JUMP
		and not (p2d.prevbuttons & BT_JUMP) then
			p2d.momy = -(FU*22)
			p2d.grounded = false
			p2d.jumped = true
		end

		if not p2d.grounded
		and not (p2d.buttons & BT_JUMP)
		and p2d.jumped then
			p2d.momy = 0
			p2d.jumped = false
		end

		if not p2d.grounded
		and p2d.momy >= 0
		and p2d.jumped then
			p2d.jumped = false
		end

		if p2d.grounded
		and p2d.jumped then
			p2d.jumped = false
		end

		p2d.x = $+p2d.momx
		for _,obj in pairs(PTV3_2D.map.blocks) do
			local x,y,w,h = obj.x,obj.y,obj.width,obj.height

			if not isColliding(p2d.x,p2d.y,p2d.width,p2d.height, x,y,w,h) then
				continue
			end

			local midpx = p2d.x+(p2d.width/2)
			local midpy = p2d.y+(p2d.height/2)

			local tmidpx = x+(w/2)
			local tmidpy = y+(h/2)

			if midpx >= tmidpx then
				p2d.x = x+w
			else
				p2d.x = x-p2d.width
			end
			p2d.momx = 0
		end
		p2d.y = $+p2d.momy
		p2d.grounded = false
		for _,obj in pairs(PTV3_2D.map.blocks) do
			local x,y,w,h = obj.x,obj.y,obj.width,obj.height

			if not isColliding(p2d.x,p2d.y,p2d.width,p2d.height, x,y,w,h) then
				continue
			end

			local midpx = p2d.x+(p2d.width/2)
			local midpy = p2d.y+(p2d.height/2)

			local tmidpx = x+(w/2)
			local tmidpy = y+(h/2)

			if midpy >= tmidpy then
				p2d.y = y+h
			else
				p2d.y = y-p2d.height
				p2d.grounded = true
			end
			p2d.momy = 0
		end

		local newSpr2 = p2d.display.spr2
		if not p2d.grounded then
			newSpr2 = p2d.momy >= 0 and SPR2_FALL or SPR2_SPNG
		else
			if abs(p2d.momx) > 0 then
				newSpr2 = SPR2_WALK
			else
				newSpr2 = SPR2_STND
			end
		end

		if p2d.display.spr2 ~= newSpr2 then
			p2d.display.spr2 = newSpr2
			p2d.display.frame = A
		end

		pcall(function()
			-- cant believe i have to do this but here we are
			local maxframes = skins[p.skin]

			if maxframes then
				maxframes = $.sprites[p2d.display.spr2]
			end
			if maxframes then
				maxframes = $.numframes
			else
				maxframes = nil
			end
	
			if not (leveltime % 2)
			and maxframes then
				p2d.display.frame = $+1
				if p2d.display.frame >= maxframes-1 then
					p2d.display.frame = A
				end
			end
		end)

		p2d.camera.x = p2d.x
		p2d.camera.y = p2d.y

		p2d.prevbuttons = p2d.buttons
	end

	for _,obj in pairs(PTV3_2D.objects) do
		local refObj = PTV3_2D:getRefObj(obj)
		
		refObj.think(obj)
	end
	-- actual game logic
	PTV3_2D.timeLeft = max(0, $-1)
	if not (PTV3_2D.timeLeft) then
		if PTV3_2D.waitTime == 2*TICRATE then
			S_StartSound(nil, sfx_lvpass)
			local map = 0
			local highestVotes = 0
			
			for _,gate in pairs(PTV3_2D.gates) do
				if gate.votes > highestVotes then
					map = gate.map
					highestVotes = gate.votes
				elseif highestVotes > 0
				and gate.votes == highestVotes then
					local choices = {gate.map, map}
					map = choices[P_RandomRange(1,2)]
				end
			end

			if highestVotes == 0 then
				local gates = PTV3_2D.gates
				local choices = {gates[1].map, gates[2].map, gates[3].map}
				map = choices[P_RandomRange(1,3)]
			end

			PTV3_2D.selectedMap = map
			G_SetCustomExitVars(map, 2)
		end
		PTV3_2D.waitTime = max(0, $-1)
		if not (PTV3_2D.waitTime) then
			G_ExitLevel()
		end
	end
end)