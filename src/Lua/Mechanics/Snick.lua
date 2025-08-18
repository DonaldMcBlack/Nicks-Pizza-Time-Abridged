local function followC(p)
	return p.mo.health and p.ptv3 and not p.ptv3.chaser and not (p.ptv3.fake_exit)
end

local function getNearestPlayer(pos, conditions)
	local x,y,z,pl

	for p in players.iterate do
		if not p.mo then continue end
		if conditions and not conditions(p) then continue end
		
		local newx = abs(p.mo.x - pos.x)
		local newy = abs(p.mo.y - pos.y)
		local newz = abs(p.mo.z - pos.z)

		-- unlike pf, get the furthest player
		-- the winners need to suffer
		if (x == nil
		or y == nil
		or z == nil)
		or (newx < x
		and newy < y
		and newz < z) then
			x = newx
			y = newy
			z = newz
			pl = p
		end
	end

	return pl
end

function PTV3:LoadSkin_Snick(properties)
	if not properties then error("One of Snick's skins were not found.") return end
	if type(properties) ~= "table" then error("One of Snick's skins is not a table.") return end

	local default_struct = PTV3_SKINS.snick[0]

	for i,v in pairs(default_struct) do
		if properties[i] == nil or type(properties[i]) ~= type(default_struct[i]) then
			properties[i] = default_struct[i]
		end
	end

	table.insert(PTV3_SKINS.snick, properties)
end

addHook('MobjSpawn', function(snick)
	local player = getNearestPlayer(PTV3.spawn, followC)
	if not player then return end

	snick.target = player.mo
	snick.shadowscale = snick.scale
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
	and not PTV3.snick.ptv3 then
		PTV3:doEffect(snick, "Snick Afterimage")
	end

	if not runCode then return end

	local player = getNearestPlayer(PTV3.spawn, followC)
	snick.target = player and player.mo
	if snick.target then
		snick.skindata.behaviour(snick)
		snick.skindata.display_name = PTV3.pizzatime < 0 and snick.skindata.minus_name or snick.skindata.name
	else
		snick.momx,snick.momy,snick.momz = 0,0,0
	end
end, MT_PTV3_SNICK)

local function SnickTouchSpecial(snick, pmo)
	if snick.tracer == pmo then return end
	if (pmo and pmo.player and pmo.player.ptv3 and pmo.player.ptv3.pizzaMobj) then return end

	if (pmo.player.pflags & PF_JUMPED or pmo.player.pflags & PF_SPINNING or pmo.player.pflags & PF_STARTDASH) or pmo.player.powers[pw_invulnerability] then
		local i = 0
		while i < 20 do
			local particle = P_SpawnMobjFromMobj(snick, 0, 0, 0, MT_ARIDDUST)
			particle.momx = P_RandomRange(-10, 10)*FU
			particle.momy = P_RandomRange(-10, 10)*FU
			particle.momz = P_RandomRange(-10, 10)*FU
			particle.scalespeed = FU/TICRATE
			particle.destscale = 0
			i = $+1
		end
		P_KillMobj(snick, pmo, pmo)
		PTV3.snick = nil
		PTV3:snickSpawn()
		return
	elseif (pmo.player.powers[pw_flashing] and pmo.player.panim == PA_PAIN) or pmo.player.ptv3.fake_exit then
		return
	end
	
	P_DamageMobj(pmo, snick, snick)
end

addHook('TouchSpecial', function(snick, pmo)
	SnickTouchSpecial(snick, pmo)
	return true
end, MT_PTV3_SNICK)

local function spawnmobj(s)
	return P_SpawnMobj(s.x, s.y, s.z+(300*FU), MT_PTV3_SNICK)
end

function PTV3:snickSpawn(skin)
	local canSpawnAI = not (self.snick and self.snick.ptv3)

	if canSpawnAI then
		if self.snick and self.snick.valid then return end

		local position = {}
		local clonething = PTV3.pizzatime < 0 and self.spawn or self.endpos

		for _,i in pairs(clonething) do
			position[_] = i
		end
		
		position.z = $+(120*FU)
		self.snick = spawnmobj(position)

		if skin then
			for _,i in pairs(PTV3_SKINS.snick) do
				if skin == string.lower(PTV3_SKINS.snick[_].name) then self.snick.skindata = PTV3_SKINS.snick[_] break end
			end
		else
			self.snick.skindata = PTV3_SKINS.snick[self.skinIndex.snick]
		end

		if not self.snick.skindata then
			error("Skin is null. Picking default skin.")
			self.snick.skindata = PTV3_SKINS.snick[0]
		end
	else
		if self.snick.ptv3
		and self.snick.ptv3.pizzaMobj
		and self.snick.ptv3.pizzaMobj.valid then return end

		local snick = spawnmobj(self.snick.mo)

		if skin then
			for _,i in pairs(PTV3_SKINS.snick) do
				if skin == string.lower(PTV3_SKINS.snick[_].name) then self.snick.skindata = PTV3_SKINS.snick[_] break end
			end
		else
			self.snick.skindata = PTV3_SKINS.snick[self.skinIndex.snick]
		end

		if not self.snick.skindata then
			error("Skin is null. Picking default skin.")
			self.snick.skindata = PTV3_SKINS.snick[0]
		end
		snick.state = self.snick.skindata.states.normal

		snick.tracer = self.snick.mo
		self.snick.ptv3.pizzaMobj = snick
		print("DEBUG - Spawn Player Mask: "..self.snick.skindata.name)
	end

	table.insert(self.currentchasers, self.snick)
end