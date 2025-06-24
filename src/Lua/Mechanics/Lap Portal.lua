freeslot("MT_PTV3_LAPPORTAL", "MT_PTV3_MINUSLAPPORTAL", "S_PTV3_LAPPORTAL", "S_PTV3_MINUSLAPPORTAL", "SPR_LAPR", "SPR_LAPM", "sfx_yuck34")

mobjinfo[MT_PTV3_LAPPORTAL] = {
	--$Name "Lap Portal"
    --$Sprite LAPRA1
    --$Category "PTV3A"
	--$Color 14
	--$Angled
    doomednum = 1417,
    spawnstate = S_PTV3_LAPPORTAL,
    radius = 50*FRACUNIT,
    height = 140*FRACUNIT,
    flags = MF_SPECIAL|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_PTV3_MINUSLAPPORTAL] = {
	--$Name "Minus Lap Portal"
    --$Sprite LAPMA1
    --$Category "PTV3A"
	--$Color 9
	--$Angled
	doomednum = 1418,
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
	sprite = SPR_LAPM,
	frame = A|FF_ANIMATE|FF_SUBTRACT,
	tics = -1,
	var1 = 2,
	var2 = 2
}

addHook("MobjSpawn", function(mo)
	mo.shadowscale = mo.scale
	PTV3.lapPortal = true
end, MT_PTV3_LAPPORTAL)

addHook("MobjSpawn", function(mo)
	mo.shadowscale = mo.scale
end, MT_PTV3_MINUSLAPPORTAL)

addHook("MobjThinker", function(mo)
	if displayplayer and displayplayer.valid then
		local p = displayplayer

		if not (PTV3.pizzatime or PTV3.minusworld) or not PTV3:canLap(p) then
			mo.frame = $|TR_TRANS50
		else
			mo.frame = $ & ~TR_TRANS50
		end
	end
end, MT_PTV3_LAPPORTAL)

local function CanEnterPortal(mo, pmo)
	if not (mo and mo.valid) then return false end
	if not (pmo and pmo.player and pmo.player.ptv3) then return false end
	if pmo.player.ptv3.lap_in then return false end
	if not (PTV3:canLap(pmo.player)) then return false end

	pmo.player.ptv3.lap_in = true
	S_StartSound(nil, sfx_yuck34, pmo.player)
	return true
end

addHook("TouchSpecial", function(mo, pmo)
	if not PTV3.pizzatime then return true end
	if not CanEnterPortal(mo, pmo) then return true end

	PTV3:newLap(pmo.player, 1)
	return true
end, MT_PTV3_LAPPORTAL)

addHook("TouchSpecial", function(mo, pmo)
	if PTV3.pizzatime and not PTV3.minusworld then return true end
	if not CanEnterPortal(mo, pmo) then return true end

	if not PTV3.pizzatime and not PTV3.minusworld then
		PTV3:startMinusWorld(pmo.player)
		return true
	end

	PTV3:newLap(pmo.player, -1)
	return true
end, MT_PTV3_MINUSLAPPORTAL)