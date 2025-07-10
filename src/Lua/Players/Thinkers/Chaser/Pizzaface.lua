local movement = dofile "Players/Libs/Chaser Movement"
-- local anticamp = dofile "Players/Libs/Anticamp"

addHook("PostThinkFrame", do
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if not (p and p.mo and p.ptv3 and p.ptv3.pizzaMobj and p.ptv3.pizzaMobj.valid) then continue end

		P_MoveOrigin(p.ptv3.pizzaMobj,
			p.mo.x,
			p.mo.y,
			p.mo.z
		)
	end
end)

addHook("MapThingSpawn", function(mo)
	if not PTV3:isPTV3() then return end

	table.insert(PTV3.pizzafacetps, {x=mo.x, y=mo.y, z=mo.z})

	if mo and mo.valid then
		P_RemoveMobj(mo)
	end
end, MT_STARPOST)

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

local pizzaface = function(p)
	local canMove = true

	if p.ptv3.pizzaMobj and p.ptv3.pizzaMobj.valid then
		p.ptv3.pizzaMobj.tracer = p.mo

		-- p.mo.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT

		if p.ptv3.pizzaface_chasedown then
			if p.cmd.buttons & BT_CUSTOM1
			and not (p.ptv3.buttons & BT_CUSTOM1) then
				p.ptv3.pizzaface_chasedown = 0
			end
			p.ptv3.pizzaface_chasedown = max(0, $-1)
		else
			p.ptv3.pizzaface_chasedowncool = max(0, $-1)
		end

		if PTV3.pftime or p.ptv3.stun or p.ptv3.pizzaMobj.cooldown then
			p.ptv3.stun = max(0, $-1)
		end

		if p.ptv3.pizzaface_teleportingcool then
			p.ptv3.pizzaface_teleportingcool = max(0, $-1)
		end

		if p.ptv3.pizzaface_teleporting then
			p.ptv3.pizzaMobj.flags2 = $|MF2_DONTDRAW
		else
			p.ptv3.pizzaMobj.flags2 = $ & ~MF2_DONTDRAW
		end

		if canMove then
			if not (p.ptv3.pizzaface_chasedowncool)
			and not (p.ptv3.pizzaface_chasedown)
			and not p.ptv3.pizzaface_teleporting then

				if p.cmd.buttons & BT_CUSTOM1 and not (p.ptv3.buttons & BT_CUSTOM1) then
					p.ptv3.pizzaface_chasedown = 5*TICRATE
					p.ptv3.pizzaface_chasedowncool = 20*TICRATE

					S_StartSound(p.mo, sfx_pflgh)
				end

				if p.cmd.buttons & BT_CUSTOM2 and not (p.ptv3.buttons & BT_CUSTOM2) then
					p.ptv3.pizzaface_teleporting = true
				end
			end
		end

		if p.ptv3.pizzaface_teleporting
		and p.cmd.buttons & BT_CUSTOM2
		and not (p.ptv3.buttons & BT_CUSTOM2) then
			p.ptv3.pizzaface_teleporting = false
			p.ptv3.pizzaface_teleportingcool = 40*TICRATE
			p.ptv3.stun = 4*TICRATE
			S_StartSound(p.mo, sfx_pflgh)
		end

		if p.ptv3.pizzaface_chasedown then
			p.ptv3.chasermovetime = 0
			p.ptv3.chaservertmovetime = 0
			local player = getNearestPlayer(p.mo, function(p2)
				return p2
				and p2.mo
				and p2.mo.health
				and p2.ptv3
				and not p2.ptv3.chaser
			end)

			if not player then
				p.ptv3.pizzaface_chasedown = 0
			else
				P_FlyTo(p.mo, player.mo.x, player.mo.y, player.mo.z, 45*FU)
			end
		elseif p.ptv3.pizzaface_teleporting then
			if abs(p.cmd.sidemove) >= 25
			and abs(p.ptv3.pizzaface_tpsidemove) < 25 then
				local selIndex = p.cmd.sidemove >= 0 and 1 or -1

				p.ptv3.pizzaface_tpselection = $+selIndex

				if p.ptv3.pizzaface_tpselection > #PTV3.pizzafacetps then
					p.ptv3.pizzaface_tpselection = 1
				elseif p.ptv3.pizzaface_tpselection < 1 then
					p.ptv3.pizzaface_tpselection = #PTV3.pizzafacetps
				end
			end
			p.ptv3.pizzaface_tpsidemove = p.cmd.sidemove

			local sel = PTV3.pizzafacetps[p.ptv3.pizzaface_tpselection]

			P_SetOrigin(p.mo, sel.x, sel.y, sel.z)
			p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		else
			local maxMove = 5

			local HFU = FixedDiv(p.ptv3.chasermovetime, maxMove)
			local VFU = FixedDiv(p.ptv3.chaservertmovetime, maxMove)

			local moving, movingv = movement(p, canMove, 25*HFU, 25*VFU)
			
			if moving or movingv then
				p.ptv3.chasermovetime = min(maxMove, $+1)
			else
				p.ptv3.chasermovetime = 0
			end
			
			-- anticamp(p, canMove)
		end
	end
end

return pizzaface