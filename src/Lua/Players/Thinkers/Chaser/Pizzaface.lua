local movement = dofile "Players/Libs/Chaser Movement"
-- local anticamp = dofile "Players/Libs/Anticamp"

addHook("PostThinkFrame", function()
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

local function PerformAction(p, pizztable, chaser)
	if p.cmd.buttons & BT_CUSTOM1 then
		if pizztable.pizzaface_chasedown then
			if not pizztable.buttons & BT_CUSTOM1 then
				pizztable.pizzaface_chasedown = 0
			end
			pizztable.pizzaface_chasedown = max(0, $-1)
		end

		CONS_Printf(p, "Perform Ability 1")
	end

	if p.cmd.buttons & BT_CUSTOM2 then
		if not (pizztable.buttons & BT_CUSTOM2) then
			if pizztable.pizzaface_teleporting then
				pizztable.pizzaface_teleporting = false
				pizztable.pizzaface_teleportingcool = 40*TICRATE
				pizztable.stun = 4*TICRATE
				S_StartSound(p.mo, chaser.laughsound)
			else
				pizztable.pizzaface_teleporting = true
			end
			
		end
		CONS_Printf(p, "Perform Ability 2")
	end

	if p.cmd.buttons & BT_CUSTOM3 then
		CONS_Printf(p, "Perform Ability 3")
	end
end

local pizzaface = function(p)
	local canMove = true
	local pt_table = p.ptv3
	local chasermo = p.ptv3.pizzaMobj
	local chaserdata = p.ptv3.pizzaMobj_skindata

	if not (chasermo and chasermo.valid) then return end

	chasermo.tracer = p.mo

	-- p.mo.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT

	if canMove and
	not (pt_table.pizzaface_chasedowncool or pt_table.pizzaface_chasedown or pt_table.pizzaface_teleporting) then
		if p.cmd.buttons & BT_CUSTOM1 and not (pt_table.buttons & BT_CUSTOM1) then
			pt_table.pizzaface_chasedown = 5*TICRATE
			pt_table.pizzaface_chasedowncool = 20*TICRATE

			S_StartSound(p.mo, chaserdata.laughsound)
		end
	end

	if p.cmd.buttons & BT_CUSTOM1|BT_CUSTOM2|BT_CUSTOM3 then
		PerformAction(p, pt_table, chaserdata)
	else
		pt_table.pizzaface_chasedowncool = max(0, $-1)
		pt_table.pizzaface_teleportingcool = max(0, $-1)
	end

	if PTV3.pftime or pt_table.stun or chasermo.cooldown then
		pt_table.stun = max(0, $-1)
	end

	if pt_table.pizzaface_teleporting then
		chasermo.flags2 = $|MF2_DONTDRAW
	else
		chasermo.flags2 = $ & ~MF2_DONTDRAW
	end

	if pt_table.pizzaface_chasedown then
		pt_table.chasermovetime = 0
		pt_table.chaservertmovetime = 0
		local player = getNearestPlayer(p.mo, function(p2)
			return p2
			and p2.mo
			and p2.mo.health
			and p2.ptv3
			and not p2.ptv3.chaser
		end)

		if not player then
			pt_table.pizzaface_chasedown = 0
		else
			P_FlyTo(p.mo, player.mo.x, player.mo.y, player.mo.z, 45*FU)
		end
	elseif pt_table.pizzaface_teleporting then
		if abs(p.cmd.sidemove) >= 25
		and abs(pt_table.pizzaface_tpsidemove) < 25 then
			local selIndex = p.cmd.sidemove >= 0 and 1 or -1

			pt_table.pizzaface_tpselection = $+selIndex

			if pt_table.pizzaface_tpselection > #PTV3.pizzafacetps then
				pt_table.pizzaface_tpselection = 1
			elseif pt_table.pizzaface_tpselection < 1 then
				pt_table.pizzaface_tpselection = #PTV3.pizzafacetps
			end
		end
		pt_table.pizzaface_tpsidemove = p.cmd.sidemove

		local sel = PTV3.pizzafacetps[pt_table.pizzaface_tpselection]

		P_SetOrigin(p.mo, sel.x, sel.y, sel.z)
		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
	else
		movement(p, canMove, chaserdata.intspeed*chaserdata.incremspeed, chaserdata.intspeed*chaserdata.incremspeed, "PF Afterimage")
		
		-- anticamp(p, canMove)
	end
end

return pizzaface