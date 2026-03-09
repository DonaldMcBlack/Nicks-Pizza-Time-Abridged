local function cAngle(p)
	return p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, p.cmd.forwardmove*FU, -p.cmd.sidemove*FU)
end

local function Move(p, angle, speed)
	if max(abs(p.cmd.forwardmove), abs(p.cmd.sidemove)) > 0 then
		local frac = abs(FixedDiv(FixedHypot(
				abs(p.cmd.sidemove << 16),
				abs(p.cmd.forwardmove << 16)
			), 50*FU
		))
		frac = min($, FU)

		p.mo.momx = P_ReturnThrustX(nil, angle, FixedMul(speed,frac))
		p.mo.momy = P_ReturnThrustY(nil, angle, FixedMul(speed,frac))
	end
end

return function(p, canMove, speed)
	p.powers[pw_shield] = SH_NONE
	p.powers[pw_carry] = 0
	p.mo.scale = FU*5/4
	p.pflags = $|PF_THOKKED|PF_INVIS & ~(PF_SPINNING|PF_JUMPED)

	p.mo.momx = 0
	p.mo.momy = 0
	p.mo.momz = 0

	if canMove then
		local isMoving = false
		local moveAngle
		
		if p.cmd.buttons & BT_JUMP or p.cmd.buttons & BT_SPIN then

			if p.cmd.buttons & BT_JUMP then
				p.mo.momz = speed
			end

			if p.cmd.buttons & BT_SPIN then
				p.mo.momz = -speed
			end
			isMoving = true
		end

		if p.cmd.forwardmove or p.cmd.sidemove then
			moveAngle = cAngle(p)
			p.PTRound.pizzaMobj.angle = moveAngle

			Move(p, moveAngle, speed)
			isMoving = true
		end

		return isMoving
	end
	return false
end