return function(p)
	if PTV3.game_over then
		p.pflags = $|PF_FULLSTASIS
		p.deadtimer = 130
		return
	end
end