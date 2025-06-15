return function(p, decreaseTimer)
	local area = p.ptv3.camper_area
	local dist = R_PointToDist2(p.mo.x, p.mo.y, area.x, area.y)

	if dist >= p.ptv3.camper_radius then
		p.ptv3.camper_area = {
			x=p.mo.x,
			y=p.mo.y
		}
		p.ptv3.camper_time = 8*TICRATE
		p.ptv3.camper = false
	end

	if decreaseTimer then 
		p.ptv3.camper_time = max(0, $-1)
	end

	if not (p.ptv3.camper_time) then
		p.ptv3.camper = true
	end
end