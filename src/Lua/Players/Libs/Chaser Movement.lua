local function cAngle(p)
	return p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, p.cmd.forwardmove*FU, -p.cmd.sidemove*FU)
end

return function(p, canMove, speedx, speedy)
	p.powers[pw_shield] = SH_NONE
	p.powers[pw_carry] = 0
	p.mo.scale = FU*5/4
	p.pflags = $|PF_THOKKED|PF_JUMPED & ~PF_SPINNING
	p.mo.momx = 0
	p.mo.momy = 0
	p.mo.momz = 0

	if not (speedy) then
		speedy = speedx
	end

	-- CONS_Printf(p, canMove)

	if canMove then
		local isMoving = false
		local isMovingV = false
		local moveAngle
		
		if p.cmd.buttons & BT_JUMP or p.cmd.buttons & BT_SPIN then
			isMovingV = true

			if p.cmd.buttons & BT_JUMP then
				p.mo.momz = speedy
			end

			if p.cmd.buttons & BT_SPIN then
				p.mo.momz = -speedy
			end
		end

		if p.cmd.forwardmove or p.cmd.sidemove then
			moveAngle = cAngle(p)
			p.mo.momx = FixedMul(speedx, cos(moveAngle))
			p.mo.momy = FixedMul(speedx, sin(moveAngle))
			isMoving = true
		else
			isMoving = false
		end

		return isMoving,isMovingV
	end
	return false,false
end