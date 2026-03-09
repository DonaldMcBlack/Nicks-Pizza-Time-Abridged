addHook('PlayerSpawn', function(p)
	if not PTV3:isPTV3() then return end
	if not (p and p.mo) then return end
	
	PTV3:InitPlayerChecks(p)

	if PTV3.pizzatime then PTV3:queueTeleport(p, PTV3.pizzatime < 0 and PTV3.spawn or PTV3.endpos) end
	
	if p.PTRound.insecret then
		local link = PTV3.secrets[p.PTRound.insecret][0]
		PTV3:queueTeleport(p, {x=link.x,y=link.y,z=link.z,a=p.mo.angle})
		return
	end
end)