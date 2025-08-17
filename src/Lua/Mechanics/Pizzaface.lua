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

function PTV3:LoadSkin_Pizzaface(properties)
	if not properties then error("One of Pizzaface's skins were not found.") return end
	if type(properties) ~= "table" then error("One of Pizzaface's skins is not a table.") return end

	local default_struct = PTV3_SKINS.pizzaface[0]

	for i,v in pairs(default_struct) do
		if properties[i] == nil or type(properties[i]) ~= type(default_struct[i]) then
			properties[i] = default_struct[i]
		end
	end

	table.insert(PTV3_SKINS.pizzaface, properties)
end

addHook('MobjSpawn', function(pf)
	pf.incremspeedthreshold = 16
	pf.destscale = (FU/2)*5/4
	pf.scale = (FU/2)*5/4
	pf.spritexscale = $*2
	pf.spriteyscale = $*2
	pf.shadowscale = pf.scale*3

	-- if PTV3.minusworld then S_StartSound(nil, sfx_fplgh)
	-- else S_StartSound(nil, laughsound) end

	pf.cooldown = 3*TICRATE
end, MT_PTV3_PIZZAFACE)

addHook('ShouldDamage', function(t,i,s) return false end, MT_PTV3_PIZZAFACE)
addHook('MobjDamage', function(t,i,s)   return true end, MT_PTV3_PIZZAFACE)
addHook('MobjRemoved', function(t,i,s)  return true end, MT_PTV3_PIZZAFACE)
addHook('MobjDeath', function(t,i,s)    return true end, MT_PTV3_PIZZAFACE)

addHook('MobjThinker', function(pf)
	local runCode = true

	if pf.cooldown then
		pf.cooldown = max($-1, 0)
		pf.frame = ($ & ~FF_TRANSMASK)|((pf.cooldown)/16<<FF_TRANSSHIFT)
		runCode = false
	end

	if pf.tracer and pf.tracer.valid then
		local t = pf.tracer

		pf.momx,pf.momy,pf.momz = t.momx,t.momy,t.momz
		runCode = false
	elseif not (PTV3.pizzaface and PTV3.pizzaface.valid) then
		PTV3.pizzaface = pf
	end

	if not (leveltime % 8) then
		if (pf.momx ~= 0 or pf.momy ~= 0 or pf.momz ~= 0) and not PTV3.pizzaface.ptv3 then
			PTV3:doEffect(pf, "PF Afterimage")
		end
		if not S_SoundPlaying(pf, sfx_pizmov) then S_StartSound(pf, sfx_pizmov) end
	end

	pf.angry = (PTV3.extreme or PTV3.overtime) and not PTV3.minusworld or false

	if not runCode then return end

	local player = getNearestPlayer(pf, followC)
	pf.target = player and player.mo
	
	if pf.target then
		pf.skindata.behaviour(pf)
	else
		pf.momx, pf.momy, pf.momz = 0, 0, 0
	end
end, MT_PTV3_PIZZAFACE)

local function PFTouchSpecial(pf, pmo)
	if pf.cooldown then return end
	if pf.tracer == pmo then return end
	local src = pf
	if pf.tracer
	and pf.tracer.valid then
		src = pf.tracer
	end
	
	if pmo.player.powers[pw_invulnerability]
	or (pmo.player.ptv3
	and (pmo.player.ptv3.fake_exit
	or pmo.player.ptv3.chaser)) then
		return
	end
	
	if pf.tracer
	and pf.tracer.valid then
		local p = pf.tracer.player
		if p.ptv3
		and (p.ptv3.camper or p.ptv3.pizzaface_teleporting or p.ptv3.stun) then
			return
		end
	end
	
	local canKill = PTV3.callbacks("PizzafaceKill", pf, pmo)
	if canKill then
		return
	end
	
	P_DamageMobj(pmo, src, src, 999, DMG_INSTAKILL)
end

addHook('TouchSpecial', function(pf, pmo)
	PFTouchSpecial(pf, pmo)
	return true
end, MT_PTV3_PIZZAFACE)

local function spawnmobj(s)
	return P_SpawnMobj(s.x, s.y, s.z, MT_PTV3_PIZZAFACE)
end

-- Spawns Pizzaface.
function PTV3:pizzafaceSpawn(skin)
	local canSpawnAI = not (self.pizzaface and self.pizzaface.ptv3)

	if canSpawnAI then
		if self.pizzaface and self.pizzaface.valid then return end

		local position = {}
		local clonething

		if gametype == GT_PTV3DM or PTV3.minusworld then
			clonething = self.spawn
		else
			clonething = self.endpos
		end

		for _,i in pairs(clonething) do
			position[_] = i
		end

		self.pizzaface = spawnmobj(position)

		if skin then
			for _,i in pairs(PTV3_SKINS.pizzaface) do
				if skin == string.lower(PTV3_SKINS.pizzaface[_].name) then self.pizzaface.skindata = PTV3_SKINS.pizzaface[_] break end
			end
		else
			self.pizzaface.skindata = PTV3_SKINS.pizzaface[self.skinIndex.pizzaface]
		end

		if not self.pizzaface.skindata then
			error("Skin is null. Picking default skin.")
			self.pizzaface.skindata = PTV3_SKINS.pizzaface[0]
		end

		self.pizzaface.state = gametype == GT_PTV3DM and self.pizzaface.skindata.states.happy or self.pizzaface.skindata.states.laughing
		self.pizzaface.angry = false
		S_StartSound(nil, self.pizzaface.skindata.laughsound)
		print("DEBUG - Spawn "..self.pizzaface.skindata.name.." AI")
	else
		if self.pizzaface.ptv3
		and self.pizzaface.ptv3.pizzaMobj
		and self.pizzaface.ptv3.pizzaMobj.valid then return end

		local pf = spawnmobj(self.pizzaface.mo)

		if skin then
			for _,i in pairs(PTV3_SKINS.pizzaface) do
				if skin == string.lower(PTV3_SKINS.pizzaface[_].name) then self.pizzaface.skindata = PTV3_SKINS.pizzaface[_] break end
			end
		else
			self.pizzaface.skindata = PTV3_SKINS.pizzaface[self.skinIndex.pizzaface]
		end

		if not self.pizzaface.skindata then
			error("Skin is null. Picking default skin.")
			self.pizzaface.skindata = PTV3_SKINS.pizzaface[0]
		end

		pf.state = self.pizzaface.skindata.states.normal

		pf.tracer = self.pizzaface.mo
		self.pizzaface.ptv3.pizzaMobj = pf
		S_StartSound(nil, self.pizzaface.skindata.laughsound)
		print("DEBUG - Spawn Player Mask: "..self.pizzaface.skindata.name)
	end

	table.insert(self.currentchasers, self.pizzaface)
end