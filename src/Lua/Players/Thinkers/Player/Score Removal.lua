return function(p)
	if PTV3.pizzatime
	and not (leveltime % TICRATE) 
	and not p.ptv3.chaser
	and not p.ptv3.fake_exit
	and p.score > 0 then
		local reduceBy = 10
		if PTV3.overtime then
			reduceBy = 40
		end
		p.score = max(0, $-reduceBy)
		p.ptv3.scoreReduce = leveltime
	end
end