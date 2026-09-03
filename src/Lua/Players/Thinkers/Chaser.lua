local movement = dofile "Players/Libs/Chaser Movement"
-- local anticamp = dofile "Players/Libs/Anticamp"

addHook("PostThinkFrame", function()
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if not (p and p.mo and p.PTRound and p.PTRound.pizzaMobj and p.PTRound.pizzaMobj.valid) then continue end

		P_MoveOrigin(p.PTRound.pizzaMobj,
			p.mo.x,
			p.mo.y,
			p.mo.z
		)
	end
end)

local function PerformAction(p, chaser)
	if chaser.abilities[1] ~= nil and (p.cmd.buttons & BT_CUSTOM1) and not (p.PTGlobal.buttons & BT_CUSTOM1)
		and not chaser.abilities[1].cooldown then
		chaser.abilities[1].action_start(p, p.PTRound.pizzaMobj, chaser)
		return 1
	end

	if chaser.abilities[2] ~= nil and (p.cmd.buttons & BT_CUSTOM2) and not (p.PTGlobal.buttons & BT_CUSTOM2)
		and not chaser.abilities[2].cooldown then
		chaser.abilities[2].action_start(p, p.PTRound.pizzaMobj, chaser)
		return 2
	end

	if chaser.abilities[3] ~= nil and p.cmd.buttons & BT_CUSTOM3 and not (p.PTGlobal.buttons & BT_CUSTOM3)
		and not chaser.abilities[3].cooldown then
		chaser.abilities[3].action_start(p, p.PTRound.pizzaMobj, chaser)
		return 3
	end

	return 0
end

local chaser = function(p)
	local canMove = true
	local chasermo = p.PTRound.pizzaMobj
	local chaserdata = p.PTRound.pizzaMobj_skindata

	if not (chasermo and chasermo.valid) then return end

	chasermo.tracer = p.mo

	-- p.mo.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT

	if PTV3.pftime or p.PTRound.stun then
		p.PTRound.stun = max(0, $-1)
	end

	p.PTRound.stun = (PTV3.pftime or p.PTRound.stun) and max(0, $-1) or 0

	local speed = chaserdata.basespeed
	movement(p, canMove, speed)
	-- anticamp(p, canMove)

	if not chaserdata.abilities then return end

	if p.cmd.buttons & BT_CUSTOM1|BT_CUSTOM2|BT_CUSTOM3 and not chaserdata.active_ability then
		chaserdata.active_ability = PerformAction(p, chaserdata)
	end

	for i, v in ipairs(chaserdata.abilities) do
		if not v.cooldown then continue end
		if v.cooldown then v.cooldown = max($-1, 0) end
		CONS_Printf(p, v.name..": "..v.cooldown.."/"..v.cooldown_maxduration)
	end

	if chaserdata.active_ability then
		if chaserdata.abilities[chaserdata.active_ability].actiontime == 0 then
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