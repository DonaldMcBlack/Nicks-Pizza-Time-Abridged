addHook('MobjSpawn', function(snick)
	snick.shadowscale = snick.scale
	snick.skindata = {}
end, MT_PTV3_SNICK)

addHook("ShouldDamage", function(t,i,s) return false end, MT_PTV3_SNICK)

addHook('MobjThinker', function(snick)
	local pmo = (snick.tracer and snick.tracer.valid) and snick.tracer or nil
	local noAI = pmo and true or false
	local skindata

	if pmo then
		snick.momx, snick.momy, snick.momz = pmo.momx, pmo.momy, pmo.momz
		skindata = pmo.player.PTRound.pizzaMobj_skindata
	else
		if not (PTV3.snick and PTV3.snick.valid) then PTV3.snick = snick end
		skindata = snick.skindata
	end

	skindata.update(snick)
	if noAI then return end
	skindata.behaviour(snick)
end, MT_PTV3_SNICK)

addHook('TouchSpecial', function(snick, pmo)
	if (pmo and pmo.player and pmo.player.PTRound and pmo.player.PTRound.chaser) then return true end

	local skindata = snick.tracer and snick.tracer.player.PTRound.pizzaMobj_skindata or snick.skindata
	skindata.touch(snick, pmo)
	return true
end, MT_PTV3_SNICK)

function PTV3:snickSpawn(skin)
	local canSpawnAI = not (self.snick and self.snick.PTRound)
	local pos = {}
	local start_or_end = self.pizzatime < 0 and self.spawn or self.endpos
	local snick = nil
	local skindata = nil

	if canSpawnAI then
		if self.snick and self.snick.valid then return end

		pos = start_or_end
		self.snick = P_SpawnMobj(pos.x, pos.y, pos.z+(420*FU), MT_PTV3_SNICK)
	else
		if self.snick.PTRound and self.snick.PTRound.pizzaMobj and self.snick.PTRound.pizzaMobj.valid then return end

		snick = P_SpawnMobj(self.snick.mo.x, self.snick.mo.y, self.snick.mo.z, MT_PTV3_SNICK)
		snick.tracer = self.snick.mo
		self.snick.PTRound.pizzaMobj = snick
	end

	if skin then
		for _,i in pairs(PTV3_SKINS.snick) do
			if skin == string.lower(PTV3_SKINS.snick[_].name) then skin = PTV3_SKINS.snick[_] break end
		end
	end

	skindata = self:ApplyChaserSkin("snick", skin ~= nil and skin or PTV3_SKINS.snick[self.skinIndex.snick])

	if self.snick.PTRound then
		self.snick.PTRound.pizzaMobj_skindata = skindata
	else
		self.snick.skindata = skindata
	end

	snick = self.snick.PTRound and self.snick.PTRound.pizzaMobj or self.snick

	skindata.spawn(snick)

	table.insert(self.currentchasers, self.snick)
end