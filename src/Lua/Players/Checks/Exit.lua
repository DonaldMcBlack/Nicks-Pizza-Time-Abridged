return function(p)
	if not p.ptv3.fake_exit then return false end

	p.pflags = $|PF_FULLSTASIS

	if ((p.cmd.buttons & BT_ATTACK
	and not (p.ptv3.buttons & BT_ATTACK))
	and p.ptv3.canLap)
	or gametype == GT_PTV3DM then
		if p.ptv3.canLap > TICRATE
		and gametype ~= GT_PTV3DM then
			p.ptv3.canLap = TICRATE
		end

		PTV3:newLap(p)
		return false
	end

	return true
end