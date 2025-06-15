return function(p)
	if not PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.endsec
	and not PTV3.pillarJohn then
		PTV3:startPizzaTime(p)
	end

	if not (PTV3.spawnGate and PTV3.spawnGate.valid)
	and not p.ptv3.fake_exit
	and PTV3.spawnsector
	and PTV3.pizzatime
	and p.mo.subsector.sector == PTV3.spawnsector
	and PTV3:canExit(p) then
		PTV3:doPlayerExit(p)
	end
end