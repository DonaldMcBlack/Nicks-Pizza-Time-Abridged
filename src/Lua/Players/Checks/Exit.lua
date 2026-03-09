return function(p)
	if not p.PTRound.fake_exit then return false end
	-- if p.PTRound.swapModeFollower and p.PTRound.swapModeFollower.valid then return true end

	p.pflags = $|PF_FULLSTASIS
	local lap_inc = PTV3.pizzatime < 0 and -1 or 1

	if (((p.cmd.buttons & BT_ATTACK) and not (p.PTGlobal.buttons & BT_ATTACK))
	and p.PTRound.canLap) or p.PTRound.extreme
	or gametype == GT_PTV3DM then
		if gametype == GT_PTV3 and p.PTRound.laps == PTV3.max_laps then
			if p.PTRound.extremeNotif < 4*TICRATE then
				PTV3:newLap(p, lap_inc)
			else
				p.PTRound.extremeNotif = 5*TICRATE
				p.PTRound.canLap = 5*TICRATE
			end
		elseif p.PTRound.canLap > TICRATE then
			p.PTRound.canLap = TICRATE
			PTV3:newLap(p, lap_inc)
		end

		return false
	end

	return true
end