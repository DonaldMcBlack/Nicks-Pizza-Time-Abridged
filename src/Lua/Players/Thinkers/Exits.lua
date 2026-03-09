return function(p)
	if not PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.endsec
	and not PTV3.pillarJohn then
		PTV3:startPizzaTime(p, 1)
	end

	if not (PTV3.spawnGate and PTV3.spawnGate.valid)
	and not p.PTRound.fake_exit
	and PTV3.spawnsector
	and PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.spawnsector
	and PTV3:canExit(p) then
		PTV3:doPlayerExit(p)
	end
end