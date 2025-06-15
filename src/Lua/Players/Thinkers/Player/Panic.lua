PTV3.panicSpriteBlacklist = {
	['takisthefox'] = true
}

return function(p)
	if PTV3.pizzatime
	and not PTV3.panicSpriteBlacklist[p.mo.skin] then
		local speed = FixedHypot(p.rmomx, p.rmomy)

		if speed == 0
		and P_IsObjectOnGround(p.mo) 
		and not (p.pflags & (PF_SPINNING|PF_STARTDASH))then
			if p.mo.state == S_PLAY_STND then
				p.mo.state = S_PTV3_PANIC
			end
		elseif p.mo.state == S_PTV3_PANIC then
			if speed >= 0
			and P_IsObjectOnGround(p.mo) then
				p.mo.state = S_PLAY_WALK
			end
			if p.pflags & PF_STARTDASH then
				p.mo.state = S_PLAY_SPINDASH
			end
			if p.pflags & PF_SPINNING then
				p.mo.state = S_PLAY_ROLL
			end
		end
	end
end