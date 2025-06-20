-- TODO: Make Snick respawn at random parts of the map during Minus World

freeslot("MT_PTV3_SNICK",
	"SPR_SNOR",
	"SPR_SLUN",
	"S_PTV3_SNICK",
	"S_PTV3_SNICK_LUNGE"
)

mobjinfo[MT_PTV3_SNICK] = {
	doomednum = -1,
	spawnstate = S_PTV3_SNICK,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_SNICK] = {
    sprite = SPR_SNOR,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 2,
    var2 = 1,
    nextstate = S_PTV3_SNICK
}

states[S_PTV3_SNICK_LUNGE] = {
    sprite = SPR_SLUN,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 3,
    var2 = 1,
    nextstate = S_PTV3_SNICK_LUNGE
}

local function followC(p)
	return p.mo.health and p.ptv3 and not p.ptv3.pizzaface and not (p.ptv3.fake_exit)
end

local function P_FlyTo(mo, fx, fy, fz, sped, addques)
	local z = mo.z+(mo.height/2)
    if mo.valid then
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - z)
        if flyto < 1 then
            flyto = 1
        end
		
        if addques then
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - z, flyto), sped)
        end    
    end    
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

addHook('MobjSpawn', function(snick)
	local player = getNearestPlayer(PTV3.spawn, followC)
	if not player then return end

	snick.speed = 10*FU
	snick.target = player.mo
	snick.shadowscale = snick.scale
end, MT_PTV3_SNICK)

addHook("ShouldDamage", function(t,i,s)
	return false
end, MT_PTV3_SNICK)

addHook('MobjThinker', function(snick)
	if snick.tracer then return end

	if not (leveltime % 8)
	and (snick.momx ~= 0 or snick.momy ~= 0 or snick.momz ~= 0) then
		PTV3:doEffect(snick, "Snick Afterimage")
	end

	local player = getNearestPlayer(PTV3.spawn, followC)
	snick.target = player and player.mo
	snick.momx,snick.momy,snick.momz = 0,0,0
	if snick.target then
		local dist = P_AproxDistance(snick.x - snick.target.x, snick.y - snick.target.y)
		local speedup = 650*FU
		snick.angle = R_PointToAngle2(snick.x, snick.y, snick.target.x, snick.target.y)
		
		if dist > speedup then
			snick.speed = min(FixedMul(FU/20, dist), 300*FU)
			if snick.state ~= S_PTV3_SNICK_LUNGE then
				snick.state = S_PTV3_SNICK_LUNGE
			end
		else
			snick.speed = ease.linear(FU/32, snick.speed, 10*FU)
			if snick.state ~= S_PTV3_SNICK then
				snick.state = S_PTV3_SNICK
			end
		end
		
		P_FlyTo(snick, snick.target.x, snick.target.y, snick.target.z+8*FU, snick.speed)
	end
end, MT_PTV3_SNICK)

local function SnickTouchSpecial(snick, pmo)
	if snick.tracer == pmo then return end
	if (pmo and pmo.player and pmo.player.ptv3 and pmo.player.ptv3.pizzaface) then return end

	if (pmo.player.pflags & PF_JUMPED or pmo.player.pflags & PF_SPINNING or pmo.player.pflags & PF_STARTDASH) or pmo.player.powers[pw_invulnerability] then
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

local function spawnAIpizza(s)
	return P_SpawnMobj(s.x, s.y, s.z+(300*FU), MT_PTV3_SNICK)
end

function PTV3:snickSpawn()
	if not self.snick then
		local position = {}
		local clonething = self.endpos

		if PTV3.minusworld then
			clonething = self.spawn
		end

		for _,i in pairs(clonething) do
			position[_] = i
		end
		
		position.z = $+(120*FU)
		self.snick = spawnAIpizza(position)
		self.snick.displayname = "SNICK"
	end
end