addHook('MobjSpawn', function(pf)
	pf.destscale = (FU/2)*5/4
	pf.scale = (FU/2)*5/4
	pf.spritexscale = $*2
	pf.spriteyscale = $*2
	pf.shadowscale = pf.scale*3
	pf.cooldown = 3*TICRATE
	pf.brokentimer = -1

	pf.skindata = {}
end, MT_PTV3_PIZZAFACE)

addHook('ShouldDamage', function(t,i,s) return false end, MT_PTV3_PIZZAFACE)
addHook('MobjDamage', function(t,i,s)   return true end, MT_PTV3_PIZZAFACE)
addHook('MobjRemoved', function(t,i,s)  return true end, MT_PTV3_PIZZAFACE)
addHook('MobjDeath', function(t,i,s)    return true end, MT_PTV3_PIZZAFACE)

addHook('MobjThinker', function(pf)
	local pmo = (pf.tracer and pf.tracer.valid) and pf.tracer or nil
	local noAI = pmo and true or false
	local skindata

	if pmo then
		pf.momx,pf.momy,pf.momz = pmo.momx, pmo.momy, pmo.momz
		skindata = pmo.player.PTRound.pizzaMobj_skindata
	else
		if not (PTV3.pizzaface and PTV3.pizzaface.valid) then PTV3.pizzaface = pf end
		skindata = pf.skindata
	end

	skindata.update(pf)
	pf.brokentimer = max($-1, 0)

	if noAI then return end
	skindata.behaviour(pf)
end, MT_PTV3_PIZZAFACE)

local function PFTouchSpecial(pf, pmo)
	if pf.cooldown then return end
	if pf.tracer == pmo then return end

	local victim = pmo.player
	local src = pf
	local skindata

	if pf.tracer and pf.tracer.valid then
		src = pf.tracer
		local p = pf.tracer.player
		skindata = p.PTRound.pizzaMobj_skindata

		if p and p.valid and p.PTRound and (p.PTRound.camper or p.PTRound.stun) then
			return
		end
	else
		skindata = pf.skindata
	end

	if victim.powers[pw_invulnerability] or (victim.PTRound and (victim.PTRound.fake_exit or victim.PTRound.chaser)) then
		return
	end

	if PTV3.callbacks("PizzafaceKill", pf, pmo) then return end
	skindata.touch(src, pmo)
end

addHook('TouchSpecial', function(pf, pmo)
	PFTouchSpecial(pf, pmo)
	return true
end, MT_PTV3_PIZZAFACE)

-- Spawns Pizzaface.
function PTV3:pizzafaceSpawn(skin)
	local canSpawnAI = not (self.pizzaface and self.pizzaface.PTRound)

	local alive = PTV3:playerCount("alive")
	local pos = {}
	local start_or_end = self.pizzatime < 0 and self.spawn or self.endpos
	local pf = nil
	local skindata = nil

	if canSpawnAI then
		if self.pizzaface and self.pizzaface.valid then return end
		local randomplayer = alive[P_RandomRange(1, #alive)].mo --players[P_RandomRange(0, #alive-1)].mo

		pos = not randomplayer and start_or_end or gametype == GT_PTV3DM and self.spawn or randomplayer
		self.pizzaface = P_SpawnMobj(pos.x, pos.y, pos.z, MT_PTV3_PIZZAFACE)
	else
		if self.pizzaface.PTRound and self.pizzaface.PTRound.pizzaMobj and self.pizzaface.PTRound.pizzaMobj.valid then return end

		pf = P_SpawnMobj(self.pizzaface.mo.x, self.pizzaface.mo.y, self.pizzaface.mo.z, MT_PTV3_PIZZAFACE)
		pf.tracer = self.pizzaface.mo
		self.pizzaface.PTRound.pizzaMobj = pf
	end

	if skin then
		for _,i in pairs(PTV3_SKINS.pizzaface) do
			if skin == string.lower(PTV3_SKINS.pizzaface[_].name) then skin = PTV3_SKINS.pizzaface[_] break end
		end
	end

	skindata = PTV3:ApplyChaserSkin("pizzaface", skin ~= nil and skin or PTV3_SKINS.pizzaface[self.skinIndex.pizzaface])

	if self.pizzaface.PTRound then
		self.pizzaface.PTRound.pizzaMobj_skindata = skindata
	else
		self.pizzaface.skindata = skindata
	end

	pf = self.pizzaface.PTRound and self.pizzaface.PTRound.pizzaMobj or self.pizzaface

	skindata.spawn(pf)

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