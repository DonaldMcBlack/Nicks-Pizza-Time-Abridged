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
end, MT_STARPOST)

local function PerformAction(p, pizztable, chaser)
	if chaser.abilities[1] ~= nil and (p.cmd.buttons & BT_CUSTOM1) and not (pizztable.buttons & BT_CUSTOM1)
		and not chaser.abilities[1].cooldown then
		chaser.abilities[1].action_start(p, chaser)
		return 1
	end

	if chaser.abilities[2] ~= nil and (p.cmd.buttons & BT_CUSTOM2) and not (pizztable.buttons & BT_CUSTOM2)
		and not chaser.abilities[2].cooldown then
		chaser.abilities[2].action_start(p, chaser)
		return 2
	end

	if chaser.abilities[3] ~= nil and p.cmd.buttons & BT_CUSTOM3 and not (pizztable.buttons & BT_CUSTOM3)
		and not chaser.abilities[3].cooldown then
		chaser.abilities[3].action_start(p, chaser)
		return 3
	end

	return 0
end

local chaser = function(p)
	local canMove = true
	local pt_table = p.ptv3
	local chasermo = p.ptv3.pizzaMobj
	local chaserdata = p.ptv3.pizzaMobj_skindata

	if not (chasermo and chasermo.valid) then return end

	chasermo.tracer = p.mo

	-- p.mo.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT

	if PTV3.pftime or pt_table.stun then
		pt_table.stun = max(0, $-1)
	end

	local speed = 0
	if (chaserdata.intspeed and chaserdata.incremspeed) then
		speed = chaserdata.intspeed*chaserdata.incremspeed
	else
		print(chaserdata.basespeed)
		speed = chaserdata.basespeed
	end

	movement(p, canMove, speed)
	-- anticamp(p, canMove)

	if not chaserdata.abilities then return end

	if p.cmd.buttons & BT_CUSTOM1|BT_CUSTOM2|BT_CUSTOM3 and not chaserdata.active_ability then
		chaserdata.active_ability = PerformAction(p, pt_table, chaserdata)
	end

	for i, v in ipairs(chaserdata.abilities) do
		if not v.cooldown then continue end
		if v.cooldown then v.cooldown = max($-1, 0) end
		CONS_Printf(p, v.name..": "..v.cooldown.."/"..v.cooldown_maxduration)
	end

	if chaserdata.active_ability then
		if chaserdata.abilities[chaserdata.active_ability].actiontime <= 0 then
			chaserdata.abilities[chaserdata.active_ability].action_end(p, chaserdata)
			chaserdata.abilities[chaserdata.active_ability].cooldown = chaserdata.abilities[chaserdata.active_ability].cooldown_maxduration
			chaserdata.active_ability = 0
		else
			chaserdata.abilities[chaserdata.active_ability].action_behaviour(p, chaserdata)
			chaserdata.abilities[chaserdata.active_ability].actiontime = max($-1, 0)
		end
	end
end

return chaser