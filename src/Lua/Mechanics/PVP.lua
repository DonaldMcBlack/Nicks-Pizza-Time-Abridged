local function canPVP(p1, p2)
	if not PTV3:isPTV3() then return 0 end

	if p2.powers[pw_flashing]
	or p2.powers[pw_invulnerability]
	or p2.pflags & PF_CANCARRY
	or P_PlayerInPain(p2)
	or (p2.ptv3 and p2.ptv3.fake_exit) then
		return 0
	end
	
	if (p1.ptv3 and p1.ptv3.swapModeFollower)
	or (p2.ptv3 and p2.ptv3.swapModeFollower) then
		return 0
	end
	
	-- Return values:
	-- 0 = None
	-- 1 = Normal pain animation
	-- 2 = Sent flying forwards
	-- 3 = Sent upwards

	local canPVP = PTV3.callbacks("CanPVP", p1.mo, p2.mo)

	if canPVP and type(canPVP) == "number" then return canPVP end

	if p1.pflags & PF_JUMPED then
		if p1.speed > 30*FU then
			return 2
		end
		return 1
	end

	if p1.pflags & PF_SPINNING then
		return 3
	end

	return 0
end

local function hurtPlayer(p1, p2, value)
	if value == 0 then return end

	local scoreAdd = min(p2.score, 250)
	p1.score = $+scoreAdd
	p1.ptv3.pvpCooldown = 5
	p2.score = $-scoreAdd
	p2.ptv3.pvpCooldown = 5

	local p1mo, p2mo = p1.mo, p2.mo

	if value == 1 then
		p2.drawangle = R_PointToAngle2(p2mo.x, p2mo.y, p1mo.x, p1mo.y)
		P_DoPlayerPain(p2)
	elseif value == 2 then
		p2.drawangle = R_PointToAngle2(p2mo.x, p2mo.y, p1mo.x, p1mo.y)+ANGLE_180
		P_InstaThrust(p2mo, p2.drawangle, p1.speed)
		p2mo.momz = $+((2*FU)*P_MobjFlip(p2mo))
		p2.pflags = $|PF_JUMPED & ~(PF_SPINNING|PF_THOKKED)
		p2mo.state = S_PLAY_JUMP
	elseif value == 3 then
		p2.drawangle = R_PointToAngle2(p2mo.x, p2mo.y, p1mo.x, p1mo.y)+ANGLE_180
		P_InstaThrust(p2mo, p2.drawangle, p1.speed)
		p2mo.momz = $+((16*FU)*P_MobjFlip(p2mo))
		p2.pflags = $|PF_JUMPED & ~(PF_SPINNING|PF_THOKKED)
		p2mo.state = S_PLAY_JUMP
	end
end

local function choose(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end

addHook('MobjMoveCollide', function(pmo, mo2)
	if mo2.type ~= MT_PLAYER then return end
	if (mo2 and mo2.player and mo2.player.ptv3 and (mo2.player.ptv3.pizzaMobj or mo2.player.ptv3.pvpCooldown)) then return end
	if (pmo and pmo.player and pmo.player.ptv3 and (pmo.player.ptv3.pizzaMobj or mo2.player.ptv3.pvpCooldown)) then return end
	if pmo.z > mo2.z+mo2.height then return end
	if mo2.z > pmo.z+pmo.height then return end

	local p1, p2 = pmo.player, mo2.player

	local value = canPVP(p1, p2)
	local value_2 = canPVP(p2, p1)
	if value and value_2 then
		local winner = choose(pmo, mo2)
		local loser = (winner == pmo) and mo2 or pmo
		local val = (winner == pmo) and value or value_2

		hurtPlayer(winner.player, loser.player, val)
	elseif value then
		hurtPlayer(p1, p2, value)
	end
end, MT_PLAYER)