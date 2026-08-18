addHook('MobjSpawn', function(john)
	john.skindata = {}
end, MT_PTV3_JOHNGHOST)

addHook("ShouldDamage", function(t,i,s) return false end, MT_PTV3_JOHNGHOST)

addHook('MobjThinker', function(john)
	local player = (john.tracer and john.tracer.valid) and john.tracer or nil
	local noAI = player and true or false

	if player then
		john.momx, john.momy, john.momz = player.momx, player.momy, player.momz
	elseif not (PTV3.pizzaface and PTV3.pizzaface.valid) then
		PTV3.johnGhost = john
	end

	john.skindata.update(john)
	if noAI then return end
	john.skindata.behaviour(john)
end, MT_PTV3_JOHNGHOST)

addHook('TouchSpecial', function(john, pmo)
	if (pmo and pmo.player and pmo.player.PTRound and pmo.player.PTRound.chaser) then return end
	
	local skindata = john.tracer and john.tracer.player.PTRound.pizzaMobj_skindata or john.skindata
	skindata.touch(john, pmo)
	return true
end, MT_PTV3_JOHNGHOST)

function PTV3:johnGhostSpawn(skin)
	local canSpawnAI = not (self.johnGhost and self.johnGhost.PTRound)
	local pos = {}
	local spawn = self.pizzatime < 0 and {x = 0, y = 0, z = 0, angle = 0} or self.endpos
	local john = nil
	local skindata = nil

	if canSpawnAI then
		if self.johnGhost and self.johnGhost.valid then return end
		
		pos = spawn
		self.johnGhost = P_SpawnMobj(pos.x, pos.y, pos.z+(420*FU), MT_PTV3_JOHNGHOST)
	else
		if self.johnGhost.PTRound and self.johnGhost.PTRound.pizzaMobj and self.johnGhost.PTRound.pizzaMobj.valid then return end

		john = P_SpawnMobj(self.johnGhost.mo.x, self.johnGhost.mo.y, self.johnGhost.mo.z, MT_PTV3_JOHNGHOST)
		john.tracer = self.johnGhost.mo
		self.johnGhost.PTRound.pizzaMobj = john
	end

	if skin then
		for _,i in pairs(PTV3_SKINS.johnGhost) do
			if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then skin = PTV3_SKINS.johnGhost[_] break end
		end
	end

	skindata = self:ApplyChaserSkin("johnGhost", skin ~= nil and skin or PTV3_SKINS.johnGhost[self.skinIndex.johnGhost])

	if self.johnGhost.PTRound then
		self.johnGhost.PTRound.pizzaMobj_skindata = skindata
	else
		self.johnGhost.skindata = skindata
	end

	john = self.johnGhost.PTRound and self.johnGhost.PTRound.pizzaMobj or self.johnGhost

	skindata.spawn(john)

	table.insert(self.currentchasers, self.johnGhost)
end