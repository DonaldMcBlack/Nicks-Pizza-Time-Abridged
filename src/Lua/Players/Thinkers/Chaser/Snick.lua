local movement = dofile "Players/Libs/Chaser Movement"
-- local anticamp = dofile "Players/Libs/Anticamp"

local snick = function(p)
	local canMove = true
	local isDashing = (p.cmd.buttons & BT_ATTACK)

	if p.ptv3.pizzaMobj and p.ptv3.pizzaMobj.valid then
		p.ptv3.pizzaMobj.tracer = p.mo

		if p.ptv3.stun or p.ptv3.pizzaMobj.cooldown then
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

		movement(p, canMove, isDashing and 32*FU or 16*FU, isDashing and 32*FU or 16*FU, "Snick Afterimage")
		-- anticamp(p, canMove)
	end
end

return snick