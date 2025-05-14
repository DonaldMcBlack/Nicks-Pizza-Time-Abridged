freeslot("SPR_TEFF", "S_PTV3_TREASUREEFFECT")

states[S_PTV3_TREASUREEFFECT] = {
	sprite = SPR_TEFF,
	frame = FF_ANIMATE|A,
	tics = -1,
	action = nil,
	var1 = 2,
	var2 = 2,
	dispoffset = -1,
	nextstate = S_NULL
}

return {
	state = S_PTV3_TREASUREEFFECT,
	follow = true
}