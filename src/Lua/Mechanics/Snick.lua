local function followC(p) return p.mo.health and p.PTRound and not p.PTRound.chaser and not (p.PTRound.fake_exit) end

addHook('MobjSpawn', function(snick)
	snick.shadowscale = snick.scale
	snick.skindata = {}
end, MT_PTV3_SNICK)

addHook("ShouldDamage", function(t,i,s) return false end, MT_PTV3_SNICK)

addHook('MobjThinker', function(snick)
	local runCode = true
	if snick.tracer then
		local t = snick.tracer

		snick.momx, snick.momy, snick.momz = t.momx, t.momy, t.momz
		runCode = false
	elseif not (PTV3.snick and PTV3.snick.valid) then
		PTV3.snick = snick
	end

	if not (leveltime % 8)
	and (snick.momx ~= 0 or snick.momy ~= 0 or snick.momz ~= 0)
	and not PTV3.snick.PTRound then
		PTV3:doEffect(snick, "Snick Afterimage")
	end

	if not runCode then return end

	local player = PTV3:getNearestPlayer(PTV3.spawn, followC, "player_t")
	snick.target = player and player.mo
	if snick.target then
		snick.skindata.behaviour(snick)
	else
		snick.momx,snick.momy,snick.momz = 0,0,0
	end
end, MT_PTV3_SNICK)

addHook('TouchSpecial', function(snick, pmo)
	if (pmo and pmo.player and pmo.player.PTRound and pmo.player.PTRound.chaser) then return true end

	local skindata = snick.tracer and snick.tracer.player.PTRound.pizzaMobj_skindata or snick.skindata
	if skindata.touch then skindata.touch(snick, pmo) end
	return true
end, MT_PTV3_SNICK)

function PTV3:snickSpawn(skin)
	local canSpawnAI = not (self.snick and self.snick.PTRound)

	if canSpawnAI then
		if self.snick and self.snick.valid then return end

		local pos = {}
		local clonething = PTV3.pizzatime < 0 and self.spawn or self.endpos

		for _,i in pairs(clonething) do
			pos[_] = i
		end
		
		pos.z = $+(420*FU)
		self.snick = P_SpawnMobj(pos.x, pos.y, pos.z, MT_PTV3_SNICK)

		if skin then
			for _,i in pairs(PTV3_SKINS.snick) do
				if skin == string.lower(PTV3_SKINS.snick[_].name) then PTV3:ApplyChaserSkin("snick", self.snick.skindata, PTV3_SKINS.snick[_]) break end
			end
		else
			PTV3:ApplyChaserSkin("snick", self.snick.skindata, PTV3_SKINS.snick[self.skinIndex.snick])
		end

		if not self.snick.skindata then
			error("Skin is null. Picking default skin.")
			self.snick.skindata = PTV3_SKINS.snick[0]
		end
	else
		if self.snick.PTRound
		and self.snick.PTRound.pizzaMobj and self.snick.PTRound.pizzaMobj.valid then return end

		local snick = P_SpawnMobj(self.snick.mo.x, self.snick.mo.y, self.snick.mo.z, MT_PTV3_SNICK)

		if skin then
			for _,i in pairs(PTV3_SKINS.snick) do
				if skin == string.lower(PTV3_SKINS.snick[_].name) then PTV3:ApplyChaserSkin("snick", self.snick.PTRound.pizzaMobj_skindata, PTV3_SKINS.snick[_]) break end
			end
		else
			error("Skin is null. Picking default skin.")
			self.snick.PTRound.pizzaMobj_skindata = PTV3_SKINS.snick[0]
		end

		snick.state = self.snick.PTRound.pizzaMobj_skindata.states.normal
		snick.tracer = self.snick.mo

		self.snick.PTRound.pizzaMobj = snick
	end

	table.insert(self.currentchasers, self.snick)
end