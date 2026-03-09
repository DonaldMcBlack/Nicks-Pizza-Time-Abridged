return function(p)
	if PTV3.pizzatime
	and not (leveltime % TICRATE)
	and not p.PTRound.chaser
	and not p.PTRound.fake_exit
	and p.score > 0 then
		local reduceBy = 10
		if PTV3.overtime then
			reduceBy = 40
		end
		p.score = max(0, $-reduceBy)
		p.PTRound.scoreReduce.by = reduceBy
		p.PTRound.scoreReduce.time = leveltime
	end
end