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

local function ApplySkin(john_skindata, selectedskin)
	local default_struct = PTV3_SKINS.johnGhost[0]

	for i, v in pairs(default_struct) do
		if john_skindata[i] ~= selectedskin[i] then john_skindata[i] = selectedskin[i] end
	end
end

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

	local player = getNearestPlayer(PTV3.spawn, followC)
	john.target = player and player.mo

	if john.target then
		john.skindata.behaviour(john)
	else
		john.momx,john.momy,john.momz = 0,0,0
	end
end, MT_PTV3_JOHNGHOST)

addHook('TouchSpecial', function(john, pmo)
	if (pmo and pmo.player and pmo.player.ptv3 and pmo.player.ptv3.chaser) then return end
	
	local skindata = john.tracer and john.tracer.player.ptv3.pizzaMobj_skindata or john.skindata
	if skindata.touch then skindata.touch(john, pmo) end
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
		local clonething = PTV3.pizzatime > 0 and PTV3.endpos or {x = 0, y = 0, z = 0, a = 0}

		for _,i in pairs(clonething) do position[_] = i end
		
		position.z = PTV3.pizzatime > 0 and $+(120*FU) or 0
		self.johnGhost = spawnmobj(position)

		if skin then
			for _,i in pairs(PTV3_SKINS.johnGhost) do
				if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then ApplySkin(self.johnGhost.skindata, PTV3_SKINS.johnGhost[_]) break end
			end
		else
			ApplySkin(self.johnGhost.skindata, PTV3_SKINS.johnGhost[self.skinIndex.johnGhost])
		end

		if not self.johnGhost.skindata then
			error("Skin is null. Picking default skin.")
			self.johnGhost.skindata = PTV3_SKINS.johnGhost[0]
		end
	else
		if self.johnGhost.ptv3
		and self.johnGhost.ptv3.pizzaMobj and self.johnGhost.ptv3.pizzaMobj.valid then return end

		local john = spawnmobj(self.johnGhost.mo)

		if skin then
			for _,i in pairs(PTV3_SKINS.johnGhost) do
				if skin == string.lower(PTV3_SKINS.johnGhost[_].name) then ApplySkin(self.johnGhost.ptv3.pizzaMobj_skindata, PTV3_SKINS.johnGhost[_]) break end
			end
		else
			error("Skin is null. Picking default skin.")
			self.johnGhost.ptv3.pizzaMobj_skindata = PTV3_SKINS.johnGhost[0]
		end

		print(self.johnGhost.ptv3.pizzaMobj_skindata.name)
		john.state = self.johnGhost.ptv3.pizzaMobj_skindata.states.normal
		john.tracer = self.johnGhost.mo
		
		self.johnGhost.ptv3.pizzaMobj = john
	end

	table.insert(self.currentchasers, self.johnGhost)
end