return function(p, decreaseTimer)
	local area = p.PTRound.camper_area
	local dist = R_PointToDist2(p.mo.x, p.mo.y, area.x, area.y)

	if dist >= p.PTRound.camper_radius then
		p.PTRound.camper_area = {
			x=p.mo.x,
			y=p.mo.y
		}
		p.PTRound.camper_time = 8*TICRATE
		p.PTRound.camper = false
	end

	if decreaseTimer then 
		p.PTRound.camper_time = max(0, $-1)
	end

	if not (p.PTRound.camper_time) then
		p.PTRound.camper = true
	end
end