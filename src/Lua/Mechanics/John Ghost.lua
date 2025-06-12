freeslot(
    "MT_PTV3_JOHNGHOST",
    "S_PTV3_JOHNGHOST",
	"S_PTV3_JONATHANPHANTOM",
    "SPR_JNGT",
	"SPR_JNPM",
    "sfx_jghtsp",
    "sfx_jghtct"
)
sfxinfo[sfx_jghtsp] = {
    flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
    caption = "John's ghost haunts you..."
}
sfxinfo[sfx_jghtct].caption = "John yells"

mobjinfo[MT_PTV3_JOHNGHOST] = {
	doomednum = -1,
	spawnstate = S_PTV3_JOHNGHOST,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 60*FU,
	height = 100*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_JOHNGHOST] = {
    sprite = SPR_JNGT,
    frame = FF_ANIMATE|A|FF_TRANS30,
    tics = -1,
    action = nil,
    var1 = 7,
    var2 = 2,
    nextstate = S_PTV3_JOHNGHOST
}

states[S_PTV3_JONATHANPHANTOM] = {
	sprite = SPR_JNPM,
	frame = FF_ANIMATE|A|FF_TRANS30|FF_SUBTRACT,
	tics = -1,
	action = nil,
	var1 = 3,
	var2 = 2,
	nextstate = S_PTV3_JONATHANPHANTOM
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

addHook('MobjSpawn', function(john)
	local player = getNearestPlayer(PTV3.spawn, followC)
	if not player then return end
	john.speed = 5*FU
	john.target = player.mo
end, MT_PTV3_JOHNGHOST)

addHook("ShouldDamage", function(t,i,s)
	return false
end, MT_PTV3_JOHNGHOST)

addHook('MobjThinker', function(john)
	if john.tracer then return end

    S_StartSound(john, sfx_jghtsp)

	local player = getNearestPlayer(PTV3.spawn, followC)
	john.target = player and player.mo
	john.momx,john.momy,john.momz = 0,0,0

	if PTV3.minusworld and not PTV3.pizzatime then
		if john.state ~= S_PTV3_JONATHANPHANTOM then john.state = S_PTV3_JONATHANPHANTOM end
	end

	if john.target then
		local dist = P_AproxDistance(john.x - john.target.x, john.y - john.target.y)
		john.angle = R_PointToAngle2(john.x, john.y, john.target.x, john.target.y)

        john.speed = max(FixedMul(FU/32, dist), 5*FU)
		
		P_FlyTo(john, john.target.x, john.target.y, john.target.z, john.speed)
	end
end, MT_PTV3_JOHNGHOST)

local function JohnTouchSpecial(john, pmo)
	if john.tracer == pmo then return end
	if (pmo and pmo.player and pmo.player.ptv3 and pmo.player.ptv3.pizzaface) then return end

    local p = pmo.player
	
	if p.ptv3.fake_exit then return end
    PTV3:queueTeleport(p, PTV3.endpos, false)
end

addHook('TouchSpecial', function(john, pmo)
	JohnTouchSpecial(john, pmo)
	return true
end, MT_PTV3_JOHNGHOST)

local function spawnAIpizza(s)
	return P_SpawnMobj(s.x, s.y, s.z+(300*FU), MT_PTV3_JOHNGHOST)
end

function PTV3:johnSpawn()
	if not self.john then
		local position = {}
		local clonething = self.endpos

		if PTV3.minusworld then clonething = self.spawn end

		for _,i in pairs(clonething) do
			position[_] = i
		end
		
		position.z = $+(120*FU)
		self.john = spawnAIpizza(position)
		self.john.displayname = "JOHN"
	end
end