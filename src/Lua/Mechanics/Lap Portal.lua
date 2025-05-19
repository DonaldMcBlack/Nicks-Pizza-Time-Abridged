freeslot("MT_PTV3_LAPPORTAL", "MT_PTV3_MINUSLAPPORTAL", "S_PTV3_LAPPORTAL", "S_PTV3_MINUSLAPPORTAL", "SPR_LAPR")

mobjinfo[MT_PTV3_LAPPORTAL] = {
	--$Name "Lap Portal"
    --$Sprite LAPRA1
    --$Category "PTV3A"
	--$Color 14
	--$Angled
    doomednum = 2048,
    spawnstate = S_PTV3_LAPPORTAL,
    radius = 50*FRACUNIT,
    height = 140*FRACUNIT,
    flags = MF_SPECIAL|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_PTV3_MINUSLAPPORTAL] = {
	--$Name "Minus Lap Portal"
    --$Sprite LAPRA1
    --$Category "PTV3A"
	--$Color 9
	--$Angled
	doomednum = 2049,
    spawnstate = S_PTV3_MINUSLAPPORTAL,
    radius = 50*FRACUNIT,
    height = 140*FRACUNIT,
    flags = MF_SPECIAL|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

states[S_PTV3_LAPPORTAL] = {
	sprite = SPR_LAPR,
	frame = A|FF_ANIMATE,
	tics = -1,
	var1 = 2,
	var2 = 2
}

states[S_PTV3_MINUSLAPPORTAL] = {
	sprite = SPR_LAPR,
	frame = A|FF_ANIMATE|FF_SUBTRACT|FF_TRANS90,
	tics = -1,
	var1 = 2,
	var2 = 2
}


local tplist = {}

addHook("NetVars", function(n)
	tplist = n($)
end)


-- local function StoreTeleported(mo)
-- 	mo.teleported = {}
-- end

addHook("MobjSpawn", function(mo)
	mo.teleported = {}
end, MT_PTV3_LAPPORTAL)

addHook("MobjSpawn", function(mo)
end, MT_PTV3_MINUSLAPPORTAL)

addHook("ThinkFrame", do
	local rmvlist = {}
	
	for pmo,_ in pairs(tplist) do
		if not (pmo and pmo.valid and pmo.player) then
			table.insert(rmvlist, _)
			continue
		end

		if PTV3.minusworld then 
			PTV3:newLap(pmo.player, -1)
		else PTV3:newLap(pmo.player) end

		table.insert(rmvlist, pmo)
	end

	for _,i in pairs(rmvlist) do
		tplist[i] = nil
	end
end)

addHook("TouchSpecial", function(mo, pmo)
	if PTV3.minusworld and not PTV3.pizzatime then return true end
	if not (mo and mo.valid) then return true end
	if not (pmo and pmo.player and pmo.player.ptv3) then return true end
	if tplist[pmo] then return true end
	if not (PTV3:canLap(pmo.player)) then return true end

	tplist[pmo] = true
	-- print "Lapped."
	return true
end, MT_PTV3_LAPPORTAL)

addHook("TouchSpecial", function(mo, pmo)
	if PTV3.pizzatime and not PTV3.minusworld then return true end
	if not (mo and mo.valid) then return true end
	if not (pmo and pmo.player and pmo.player.ptv3) then return true end
	if tplist[pmo] then return true end
	if not (PTV3:canLap(pmo.player)) then return true end

	if not PTV3.pizzatime and not PTV3.minusworld then PTV3:startMinusWorld(pmo.player) end

	tplist[pmo] = true
	-- print "Lapped?"
	return true
end, MT_PTV3_MINUSLAPPORTAL)