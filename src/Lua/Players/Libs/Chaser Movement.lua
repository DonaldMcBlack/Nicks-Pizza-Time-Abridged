local function cAngle(p)
	return p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, p.cmd.forwardmove*FRACUNIT, -p.cmd.sidemove*FRACUNIT)
end

return function(p, canMove, speedx, speedy)
	p.powers[pw_shield] = SH_NONE
	p.mo.scale = FU*5/4
	p.pflags = $|PF_THOKKED & ~PF_SPINNING
	p.mo.momx = 0
	p.mo.momy = 0
	p.mo.momz = 0

	if not (speedy) then
		speedy = speedx
	end

	if canMove then
		local isMoving = false
		local isMovingV = false
		local moveAngle
		local airDir = 0
		local increaseTime = 0
		
		if p.cmd.buttons & BT_JUMP then
			isMovingV = true
			airDir = 1
		end

		if p.cmd.buttons & BT_SPIN then
			isMovingV = true
			airDir = -1
		end

		if abs(abs(p.cmd.sidemove) > 10 and p.cmd.sidemove or 0)
		or abs(abs(p.cmd.forwardmove) > 10 and p.cmd.forwardmove or 0) then
			moveAngle = cAngle(p)
			isMoving = true
		end

		if isMoving then
			if moveAngle ~= nil then
				p.mo.momx = FixedMul(speedx, cos(moveAngle))
				p.mo.momy = FixedMul(speedx, sin(moveAngle))
			end
		end
		if isMovingV then
			p.mo.momz = speedy*airDir
		end

		P_MovePlayer(p)
		return isMoving,isMovingV
	end
	return false,false
end