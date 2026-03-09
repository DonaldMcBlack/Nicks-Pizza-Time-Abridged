local function followC(p) return p.mo.health and p.PTRound and not p.PTRound.chaser and not (p.PTRound.fake_exit) end

addHook('MobjSpawn', function(pf)
	pf.destscale = (FU/2)*5/4
	pf.scale = (FU/2)*5/4
	pf.spritexscale = $*2
	pf.spriteyscale = $*2
	pf.shadowscale = pf.scale*3
	pf.cooldown = 3*TICRATE

	pf.skindata = {}
end, MT_PTV3_PIZZAFACE)

addHook('ShouldDamage', function(t,i,s) return false end, MT_PTV3_PIZZAFACE)
addHook('MobjDamage', function(t,i,s)   return true end, MT_PTV3_PIZZAFACE)
addHook('MobjRemoved', function(t,i,s)  return true end, MT_PTV3_PIZZAFACE)
addHook('MobjDeath', function(t,i,s)    return true end, MT_PTV3_PIZZAFACE)

local function ProcessSkindata(pf)
	local skindata = pf.player and pf.player.PTRound.pizzaMobj_skindata or pf.skindata
	if not S_SoundPlaying(pf, skindata.movesound[(PTV3.pizzatime or 1)]) then S_StartSound(pf, skindata.movesound[(PTV3.pizzatime or 1)]) end

	if not (leveltime % 8) then
		if (pf.momx ~= 0 or pf.momy ~= 0 or pf.momz ~= 0) then
			if pf.player then
				PTV3:doEffect(pf.player.PTRound.pizzaMobj, skindata.effect)
			else
				PTV3:doEffect(pf, skindata.effect)
			end
		end
	end
end

addHook('MobjThinker', function(pf)
	local runCode = true
	local player = (pf.tracer and pf.tracer.valid) and pf.tracer or nil

	if pf.cooldown then
		pf.cooldown = max($-1, 0)
		pf.frame = ($ & ~FF_TRANSMASK)|((pf.cooldown)/16<<FF_TRANSSHIFT)
		runCode = false
	end

	if player then
		pf.momx,pf.momy,pf.momz = player.momx, player.momy, player.momz
		runCode = false
	elseif not (PTV3.pizzaface and PTV3.pizzaface.valid) then
		PTV3.pizzaface = pf
	end

	ProcessSkindata(player or pf)
	pf.angry = (PTV3.extreme or PTV3.overtime) and PTV3.pizzatime > 0 or false

	if not runCode then return end

	pf.target = PTV3:getNearestPlayer(pf, followC)
	if pf.target then
		pf.skindata.behaviour(pf)
	else
		pf.momx, pf.momy, pf.momz = 0, 0, 0
	end

	if pf.brokentimer then pf.brokentimer = $-1 end
end, MT_PTV3_PIZZAFACE)

local function PFTouchSpecial(pf, pmo)
	if pf.cooldown then return end
	if pf.tracer == pmo then return end
	
	local victim = pmo.player
	
	local src = pf
	if pf.tracer and pf.tracer.valid then
		src = pf.tracer
		local p = pf.tracer.player

		if p.PTRound and (p.PTRound.camper or p.PTRound.stun) then
			return
		end
	end
	
	if victim.powers[pw_invulnerability]
	or (victim.PTRound and (victim.PTRound.fake_exit or victim.PTRound.chaser)) then
		return
	end
	
	if PTV3.callbacks("PizzafaceKill", pf, pmo) then return end
	
	P_DamageMobj(pmo, src, src, 999, DMG_INSTAKILL)
end

addHook('TouchSpecial', function(pf, pmo)
	PFTouchSpecial(pf, pmo)
	return true
end, MT_PTV3_PIZZAFACE)

-- Spawns Pizzaface.
function PTV3:pizzafaceSpawn(skin)
	local canSpawnAI = not (self.pizzaface and self.pizzaface.PTRound)

	if canSpawnAI then
		if self.pizzaface and self.pizzaface.valid then return end
		

		local alive = PTV3:playerCount()

		local randomplayer = players[P_RandomRange(0, #alive)]

		local pos = (gametype == GT_PTV3DM or PTV3.pizzatime < 0) and self.spawn or randomplayer.mo

		self.pizzaface = P_SpawnMobj(pos.x, pos.y, pos.z, MT_PTV3_PIZZAFACE)

		if skin then
			for _,i in pairs(PTV3_SKINS.pizzaface) do
				if skin == string.lower(PTV3_SKINS.pizzaface[_].name) then PTV3:ApplyChaserSkin("pizzaface", self.pizzaface.skindata, PTV3_SKINS.pizzaface[_]) break end
			end
		else
			PTV3:ApplyChaserSkin("pizzaface", self.pizzaface.skindata, PTV3_SKINS.pizzaface[self.skinIndex.pizzaface])
		end

		if not self.pizzaface.skindata then
			error("Skin is null. Picking default skin.")
			self.pizzaface.skindata = PTV3_SKINS.pizzaface[0]
		end

		if self.pizzaface.skindata.spawn then
			self.pizzaface.skindata.spawn(self.pizzaface)
		else
			self.pizzaface.state = gametype == GT_PTV3DM and self.pizzaface.skindata.states.happy or self.pizzaface.skindata.states.laughing
		end
		
		self.pizzaface.angry = false
		S_StartSound(nil, self.pizzaface.skindata.laughsound[self.pizzatime] ~= nil and self.pizzaface.skindata.laughsound[self.pizzatime] or self.pizzaface.skindata.laughsound[1])
	else
		if self.pizzaface.PTRound
		and self.pizzaface.PTRound.pizzaMobj and self.pizzaface.PTRound.pizzaMobj.valid then return end

		local pf = P_SpawnMobj(self.pizzaface.mo.x, self.pizzaface.mo.y, self.pizzaface.mo.z, MT_PTV3_PIZZAFACE)

		if skin then
			for _,i in pairs(PTV3_SKINS.pizzaface) do
				if skin == string.lower(PTV3_SKINS.pizzaface[_].name) then PTV3:ApplyChaserSkin("pizzaface", self.pizzaface.PTRound.pizzaMobj_skindata, PTV3_SKINS.pizzaface[_]) break end
			end
		else
			error("Skin is null. Picking default skin.")
			PTV3:ApplyChaserSkin("pizzaface", self.pizzaface.PTRound.pizzaMobj_skindata, PTV3_SKINS.pizzaface[0])
		end

		pf.state = self.pizzaface.PTRound.pizzaMobj_skindata.states.normal
		pf.tracer = self.pizzaface.mo

		self.pizzaface.PTRound.pizzaMobj = pf
		S_StartSound(nil, self.pizzaface.PTRound.pizzaMobj_skindata.laughsound[self.pizzatime] ~= nil and self.pizzaface.PTRound.pizzaMobj_skindata.laughsound[self.pizzatime] or self.pizzaface.PTRound.pizzaMobj_skindata.laughsound[1])
	end

	table.insert(self.currentchasers, self.pizzaface)
end

addHook("LinedefExecute", function(line, mo, sector)
	if gametype == GT_PTV3DM
	or not mo.player
	or not PTV3.pizzaface
	or mo ~= PTV3.pizzaface.target
	or not PTV3.pizzaface.skindata.can_haywire then return end

	PTV3.pizzaface.brokentimer = 10
end, "PIZZABREAK")