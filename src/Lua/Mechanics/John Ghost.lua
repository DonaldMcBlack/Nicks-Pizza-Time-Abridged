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

function PTV3:LoadSkin_JohnGhost(properties)
	if not properties then error("One of John's skins were not found.") return end
	if type(properties) ~= "table" then error("One of John's skins is not a table.") return end

	local default_struct = PTV3_SKINS.johnGhost[0]

	for i,v in pairs(default_struct) do
		if properties[i] == nil or type(properties[i]) ~= type(default_struct[i]) then
			properties[i] = default_struct[i]
		end
	end

	table.insert(PTV3_SKINS.johnGhost, properties)
end

addHook('MobjSpawn', function(john)
	local player = getNearestPlayer(PTV3.spawn, followC)
	if not player then return end

	john.target = player.mo
end, MT_PTV3_JOHNGHOST)

addHook("ShouldDamage", function(t,i,s)
	return false
end, MT_PTV3_JOHNGHOST)

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

	local player = getNearestPlayer(PTV3.spawn, followC)
	john.target = player and player.mo

	if john.target then
		john.skindata.behaviour(john)
	else
		john.momx,john.momy,john.momz = 0,0,0
	end
end, MT_PTV3_JOHNGHOST)

local function JohnTouchSpecial(john, pmo)
	if john.tracer == pmo then return end
	if (pmo and pmo.player and pmo.player.ptv3 and pmo.player.ptv3.chaser) then return end

    local p = pmo.player
	
	if p.ptv3.fake_exit then return end
	john.speed, john.basespeed = 0, 0
    PTV3:queueTeleport(p, p.ptv3.currentTeleportDest, false, john)
	S_StartSound(nil, sfx_jghtct, p)
	P_SetOrigin(john, PTV3.spawn.x, PTV3.spawn.y, PTV3.spawn.z+(200*FU))
end

addHook('TouchSpecial', function(john, pmo)
	JohnTouchSpecial(john, pmo)
	return true
end, MT_PTV3_JOHNGHOST)

local function spawnmobj(s)
	return P_SpawnMobj(s.x, s.y, s.z+(300*FU), MT_PTV3_JOHNGHOST)
end

function PTV3:johnGhostSpawn(skin)
	local canSpawnAI = not (self.johnGhost and self.johnGhost.ptv3)

	if canSpawnAI then
		if self.johnGhost and self.johnGhost.valid then return end

		local position = {}
		local clonething = PTV3.pizzatime < 0 and self.spawn or self.endpos

		for _,i in pairs(clonething) do position[_] = i end
		
		position.z = $+(120*FU)
		self.johnGhost = spawnmobj(position)

		if skin then
			for _,i in pairs(PTV3_SKINS.johnGhost) do
				if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then self.johnGhost.skindata = PTV3_SKINS.johnGhost[_] break end
			end
		else
			self.johnGhost.skindata = PTV3_SKINS.johnGhost[self.skinIndex.johnGhost]
		end

		if not self.johnGhost.skindata then
			warn("Skin is null. Picking default skin.")
			self.johnGhost.skindata = PTV3_SKINS.johnGhost[0]
		end
	else
		if self.johnGhost.ptv3
		and self.johnGhost.ptv3.pizzaMobj
		and self.johnGhost.ptv3.pizzaMobj.valid then return end

		local john = spawnmobj(self.johnGhost.mo)
		john.tracer = self.johnGhost.mo
		self.johnGhost.ptv3.pizzaMobj = john
	end

	table.insert(self.currentchasers, self.johnGhost)
end