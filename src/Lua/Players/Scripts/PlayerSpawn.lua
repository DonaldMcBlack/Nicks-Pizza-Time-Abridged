addHook('PlayerSpawn', function(p)
	if not PTV3:isPTV3() then return end
	if not (p and p.mo) then return end
	if not p.ptv3 then PTV3:player(p) end

	if PTV3.pizzatime or PTV3.minusworld then
		PTV3:queueTeleport(p)
	end
	if p.ptv3.insecret then
		local link = PTV3.secrets[p.ptv3.insecret][0]
		PTV3:queueTeleport(p, {x=link.x,y=link.y,z=link.z,a=p.mo.angle})
		return
	end
end)