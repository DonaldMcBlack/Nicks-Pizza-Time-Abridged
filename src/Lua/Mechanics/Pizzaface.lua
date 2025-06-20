freeslot("MT_PTV3_PIZZAFACE",
	"SPR_PZAT",
	"SPR_PZTL",
	"SPR_PZAR",
	"S_PTV3_PIZZAFACE",
	"S_PTV3_PIZZAMAD",
	"S_PTV3_PIZZATROLL",
	"sfx_pflgh",
	"sfx_fplgh",
	"sfx_pizmov"
)
sfxinfo[sfx_pflgh].caption = "Pizzaface is coming..."
sfxinfo[sfx_fplgh].caption = "Is that the...Pizzaface?"
sfxinfo[sfx_pizmov] = {
	flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
	caption = "Pizzaface is near..."
}

mobjinfo[MT_PTV3_PIZZAFACE] = {
	doomednum = -1,
	spawnstate = S_PTV3_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 60*FU,
	height = 60*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_PIZZAFACE] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = P,
    var2 = 2,
    nextstate = S_PTV3_PIZZAFACE
}

states[S_PTV3_PIZZAMAD] = {
	sprite = SPR_PZAR,
	frame = FF_ANIMATE|A,
	tics = -1,
	action = nil,
	var1 = 10,
	var2 = 2,
	nextstate = S_PTV3_PIZZAMAD
}

states[S_PTV3_PIZZATROLL] = {
	sprite = SPR_PZTL,
	frame = A,
	action = nil,
	tics = -1,
	nextstate = S_PTV3_PIZZATROLL
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

addHook('MobjSpawn', function(pf)
	pf.speed = 23
	pf.incremspeed = FU
	pf.incremspeedthreshold = 16
	pf.destscale = (FU/2)*5/4
	pf.scale = (FU/2)*5/4
	pf.spritexscale = $*2
	pf.spriteyscale = $*2
	pf.shadowscale = pf.scale*3

	if PTV3.minusworld then S_StartSound(nil, sfx_fplgh)
	else S_StartSound(nil, sfx_pflgh) end

	pf.cooldown = 3*TICRATE
end, MT_PTV3_PIZZAFACE)

addHook('ShouldDamage', function(t,i,s)
	return false
end, MT_PTV3_PIZZAFACE)

rawset(_G,'L_DoBrakes', function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end)

rawset(_G, "L_SpeedCap", function(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd, ang =
		R_PointToDist2(0,0,spd_xy,mo.momz),
		R_PointToAngle2(0,0,mo.momx,mo.momy)
	if spd > limit then
		if factor == nil then
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakes(mo,factor)
		return factor
	end
end)

addHook('MobjThinker', function(pf)
	local runCode = true

	if pf.cooldown then
		pf.cooldown = $-1
		pf.frame = ($ & ~FF_TRANSMASK)|((pf.cooldown)/16<<FF_TRANSSHIFT)
		runCode = false
	end

	if pf.tracer
	and pf.tracer.valid then
		local t = pf.tracer
		P_SetOrigin(pf,
			t.x-t.momx,
			t.y-t.momy,
			t.z-t.momz)
		pf.momx,pf.momy,pf.momz = t.momx,t.momy,t.momz
		runCode = false
	end

	if not (leveltime % 8) then
		if (pf.momx ~= 0 or pf.momy ~= 0 or pf.momz ~= 0) then PTV3:doEffect(pf, "PF Afterimage") end
		S_StartSound(pf, sfx_pizmov)
	end

	if (PTV3.extreme or PTV3.overtime) and not PTV3.minusworld then pf.angry = true
	else pf.angry = false end

	if not runCode then
		pf.target = nil
		return
	end

	local player = getNearestPlayer(pf, followC)
	pf.target = player and player.mo

	if pf.target then
		local gap = P_AproxDistance(pf.x - pf.target.x, pf.y - pf.target.y)
		pf.angle = R_PointToAngle2(pf.x, pf.y, pf.target.x, pf.target.y)
		if gametype == GT_PTV3DM then
			-- a bit of yoink from FlyTo
			local sped = 3*pf.speed/2
			local flyto = P_AproxDistance(P_AproxDistance(pf.target.x - pf.x, pf.target.y - pf.y), pf.target.z - pf.z)
			if flyto < 1 then
				flyto = 1
			end
            local tmomx = FixedMul(FixedDiv(pf.target.x - pf.x, flyto), sped)
            local tmomy = FixedMul(FixedDiv(pf.target.y - pf.y, flyto), sped)
            local tmomz = FixedMul(FixedDiv(pf.target.z - pf.z, flyto), sped)
			-- and again
			local sped2 = pf.speed/15
			local flyto2 = P_AproxDistance(P_AproxDistance(tmomx - pf.momx, tmomy - pf.momy), tmomz - pf.momz)
			if flyto2 < 1 then
				flyto2 = 1
			end
            pf.momx = $ + FixedMul(FixedDiv(tmomx - pf.momx, flyto2), sped2)
            pf.momy = $ + FixedMul(FixedDiv(tmomy - pf.momy, flyto2), sped2)
            pf.momz = $ + FixedMul(FixedDiv(tmomz - pf.momz, flyto2), sped2)
			L_SpeedCap(pf, sped)
		else
			-- Behaviour changes ---------------------
			if pf.angry then -- Enraged Pizzaface
				if pf.state ~= S_PTV3_PIZZAMAD then pf.state = S_PTV3_PIZZAMAD end
				if gap > FU*2000 then
					pf.speed = max(FixedMul(FU/pf.incremspeedthreshold, gap-(FU*500)), 23*pf.incremspeed)
				else
					pf.speed = ease.linear(FU/pf.incremspeedthreshold, pf.speed, 23*pf.incremspeed)
				end

				if pf.eflags & MFE_UNDERWATER then
					pf.speed = FixedDiv($, 2*FU)
				end
				P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.speed)
				
			else -- Normal Pizzaface
				if PTV3.minusworld and not PTV3.pizzatime then
					if gap < FU*300 and pf.state ~= S_PTV3_PIZZATROLL then pf.state = S_PTV3_PIZZATROLL
					elseif gap > FU*300 and pf.state ~= S_PTV3_PIZZAFACE then pf.state = S_PTV3_PIZZAFACE end

					pf.speed = max(FixedMul(FU/8, gap-(FU*250)), 23*FU)
				else
					pf.speed = 23*FU
				end

				if pf.eflags & MFE_UNDERWATER then
					pf.speed = FixedDiv($, 2*FU)
				end
				P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.speed)
			end
		end
	else
		if not pf.target then
			pf.momx, pf.momy, pf.momz = 0, 0, 0
		end
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
	or (pmo.player.ptv3 and pmo.player.ptv3.fake_exit) then
		return
	end
	
	if pf.tracer
	and pf.tracer.valid then
		local p = pf.tracer.player
		if p.ptv3
		and p.ptv3.pfcamper then
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

local function spawnAIpizza(s)
	return P_SpawnMobj(s.x, s.y, s.z, MT_PTV3_PIZZAFACE)
end

-- Spawns Pizzaface.
function PTV3:pizzafaceSpawn()
	if not self.pizzaface then
		local position = {}
		local clonething = nil
		
		if gametype == GT_PTV3DM or PTV3.minusworld then
			clonething = self.spawn
		else
			clonething = self.endpos
		end

		for _,i in pairs(clonething) do
			position[_] = i
		end

		self.pizzaface = spawnAIpizza(clonething)
		self.pizzaface.angry = false
		self.pizzaface.displayname = "PIZZAFACE"
	end
end