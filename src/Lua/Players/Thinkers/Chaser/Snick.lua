local movement = dofile "Players/Libs/Chaser Movement"
local anticamp = dofile "Players/Libs/Anticamp"

local snick = function(p)
	local canMove = true
	local isDashing = (p.cmd.buttons & BT_ATTACK)

	if p.ptv3.pizzaMobj
	and p.ptv3.pizzaMobj.valid then
		p.ptv3.pizzaMobj.tracer = p.mo
	end
	if p.ptv3.stun then
		canMove = false
	end

	if p.ptv3.pizzaMobj
	and p.ptv3.pizzaMobj.valid
	and p.ptv3.pizzaMobj.cooldown then
		canMove = false
	end

	local state = S_PTV3_SNICK

	if isDashing
	and FixedHypot(p.mo.momx, p.mo.momy) > 0 then
		state = S_PTV3_SNICK_LUNGE
	end

	if p.ptv3.pizzaMobj.state ~= state then
		p.ptv3.pizzaMobj.state = state
	end

	movement(p, canMove, isDashing and 32*FU or 16*FU)
	anticamp(p, canMove)

	local maxMove = 5

	local HFU = FixedDiv(p.ptv3.chasermovetime, maxMove)
	local VFU = FixedDiv(p.ptv3.chaservertmovetime, maxMove)

	local moving, movingv = movement(p, canMove, isDashing and 60*HFU or 30*HFU, isDashing and 60*VFU or 30*VFU)
	
	if moving then
		p.ptv3.chasermovetime = min(maxMove, $+1)
	else
		p.ptv3.chasermovetime = 0
	end
	if movingv then
		p.ptv3.chaservertmovetime = min(maxMove, $+1)
	else
		p.ptv3.chaservertmovetime = 0
	end
	
	anticamp(p, canMove)
end

return snick