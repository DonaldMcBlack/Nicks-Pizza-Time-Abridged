local function followC(p) return p.mo.health and p.PTRound and not p.PTRound.chaser and not (p.PTRound.fake_exit) end

addHook('MobjSpawn', function(john)
	john.skindata = {}
end, MT_PTV3_JOHNGHOST)

addHook("ShouldDamage", function(t,i,s) return false end, MT_PTV3_JOHNGHOST)

addHook('MobjThinker', function(john)
	if john.tracer then return end

	if PTV3.pizzatime < 0 then
		if john.state ~= S_PTV3_JONATHANPHANTOM then
			john.state = S_PTV3_JONATHANPHANTOM
			john.ambience = sfx_jphmsp
		end
	else
		if john.state ~= S_PTV3_JOHNGHOST then
			john.state = S_PTV3_JOHNGHOST
			john.ambience = sfx_jghtsp
		end
	end

	local player = PTV3:getNearestPlayer(PTV3.spawn, followC, "player_t")
	john.target = player and player.mo

	if john.target then
		john.skindata.behaviour(john)
	else
		john.momx,john.momy,john.momz = 0,0,0
	end
end, MT_PTV3_JOHNGHOST)

addHook('TouchSpecial', function(john, pmo)
	if (pmo and pmo.player and pmo.player.PTRound and pmo.player.PTRound.chaser) then return end
	
	local skindata = john.tracer and john.tracer.player.PTRound.pizzaMobj_skindata or john.skindata
	if skindata.touch then skindata.touch(john, pmo) end
	return true
end, MT_PTV3_JOHNGHOST)

function PTV3:johnGhostSpawn(skin)
	local canSpawnAI = not (self.johnGhost and self.johnGhost.PTRound)

	if canSpawnAI then
		if self.johnGhost and self.johnGhost.valid then return end

		local pos = {}
		local clonething = PTV3.pizzatime > 0 and PTV3.endpos or {x = 0, y = 0, z = 0, a = 0}

		for _,i in pairs(clonething) do pos[_] = i end
		
		pos.z = PTV3.pizzatime > 0 and $+(420*FU) or 0
		self.johnGhost = P_SpawnMobj(pos.x, pos.y, pos.z, MT_PTV3_JOHNGHOST)

		if skin then
			for _,i in pairs(PTV3_SKINS.johnGhost) do
				if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then PTV3:ApplyChaserSkin("johnGhost", self.johnGhost.skindata, PTV3_SKINS.johnGhost[_]) break end
			end
		else
			PTV3:ApplyChaserSkin("johnGhost", self.johnGhost.skindata, PTV3_SKINS.johnGhost[self.skinIndex.johnGhost])
		end

		if not self.johnGhost.skindata then
			error("Skin is null. Picking default skin.")
			self.johnGhost.skindata = PTV3_SKINS.johnGhost[0]
		end
	else
		if self.johnGhost.PTRound
		and self.johnGhost.PTRound.pizzaMobj and self.johnGhost.PTRound.pizzaMobj.valid then return end

		local john = P_SpawnMobj(self.johnGhost.mo.x, self.johnGhost.mo.y, self.johnGhost.mo.z, MT_PTV3_JOHNGHOST)

		if skin then
			for _,i in pairs(PTV3_SKINS.johnGhost) do
				if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then PTV3:ApplyChaserSkin("johnGhost", self.johnGhost.PTRound.pizzaMobj_skindata, PTV3_SKINS.johnGhost[_]) break end
			end
		else
			error("Skin is null. Picking default skin.")
			self.johnGhost.PTRound.pizzaMobj_skindata = PTV3_SKINS.johnGhost[0]
		end

		john.state = self.johnGhost.PTRound.pizzaMobj_skindata.states.normal
		john.tracer = self.johnGhost.mo
		
		self.johnGhost.PTRound.pizzaMobj = john
	end

	table.insert(self.currentchasers, self.johnGhost)
end