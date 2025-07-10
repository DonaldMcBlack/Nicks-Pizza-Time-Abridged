return function(p)
	if not p.ptv3.fake_exit then return false end
	if p.ptv3.swapModeFollower and p.ptv3.swapModeFollower.valid then return true end

	p.pflags = $|PF_FULLSTASIS
	local lap_inc = nil

	if PTV3.minusworld then lap_inc = -1
	else
		lap_inc = 1
	end

	if (((p.cmd.buttons & BT_ATTACK) and not (p.ptv3.buttons & BT_ATTACK))
	and p.ptv3.canLap) or p.ptv3.extreme
	or gametype == GT_PTV3DM then
		if gametype == GT_PTV3 and p.ptv3.laps == PTV3.max_laps then
			if p.ptv3.extremeNotif < 4*TICRATE then
				PTV3:newLap(p, lap_inc)
			else
				p.ptv3.extremeNotif = 5*TICRATE
				p.ptv3.canLap = 5*TICRATE
			end
		elseif p.ptv3.canLap > TICRATE then
			p.ptv3.canLap = TICRATE
			PTV3:newLap(p, lap_inc)
		end

		return false
	end

	return true
end