freeslot("MT_PT_ESCAPECLOCK", "S_PT_ESCAPECLOCK", "SPR_ESCK")
freeslot("sfx_escl01", "sfx_escl02", "sfx_escl03", "sfx_escl04", "sfx_escl05")

freeslot("MT_PT_ESCAPEBELL", "S_PT_ESCAPEBELL", "SPR_BELL")
freeslot("sfx_esbl01", "sfx_esbl02", "sfx_esbl03")

local clocksoundlist = {
	sfx_escl01,
	sfx_escl02,
	sfx_escl03,
	sfx_escl04,
	sfx_escl05,
}

local bellsoundlist = {
	sfx_esbl01,
	sfx_esbl02,
	sfx_esbl03
}

for _,i in pairs(clocksoundlist) do
	sfxinfo[i].flags = SF_TOTALLYSINGLE
	sfxinfo[i].caption = "Clonk!"
end

for _,i in pairs(bellsoundlist) do
	sfxinfo[i].flags = SF_TOTALLYSINGLE
	sfxinfo[i].caption = "Ding!"
end

mobjinfo[MT_PT_ESCAPECLOCK] = {
	--$Name Escape Clock
	--$Sprite ESCKA0
	--$Category "PTV3A"
	--$Color 12
	--$NotAngled
	doomednum = 2114,
	spawnstate = S_PT_ESCAPECLOCK,
	radius = 16*FU,
	height = 24*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

mobjinfo[MT_PT_ESCAPEBELL] = {
	--$Name Escape Bell
	--$Sprite BELLA0
	--$Category "PTV3A"
	--$Color 14
	--$NotAngled
	doomednum = 2115,
	spawnstate = S_PT_ESCAPEBELL,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}


states[S_PT_ESCAPECLOCK] = {
	sprite = SPR_ESCK,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = J,
	var2 = 2,
}

states[S_PT_ESCAPEBELL] = {
	sprite = SPR_BELL,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = W,
	var2 = 2,
}

local function GivePoints(esc_mo, pmo)
	if not (PTV3.pizzatime or PTV3.minusworld) then return true end

	local player = pmo.player
	
	if esc_mo and esc_mo.valid and pmo and pmo.valid then
		if esc_mo.collect_list then
			if esc_mo.collect_list[player] == nil
			or esc_mo.collect_list[player] ~= player.ptv3.laps then
				if player and player.valid and not player.ptv3.pizzaface then
					esc_mo.collect_list[player] = player.ptv3.laps

					if esc_mo.type == MT_PT_ESCAPECLOCK then
						S_StartSound(pmo, clocksoundlist[P_RandomRange(1,#clocksoundlist)])
						P_AddPlayerScore(player, 10)
						PTV3:increaseCombo(player, 2, PTV3.MAX_COMBO_TIME/5)
					end

					if esc_mo.type == MT_PT_ESCAPEBELL then
						S_StartSound(pmo, bellsoundlist[P_RandomRange(1,#bellsoundlist)])
						P_AddPlayerScore(player, 100)
						PTV3:increaseCombo(player, 3)
					end
				end
			end
		end
	end

	return true
end

addHook("TouchSpecial", GivePoints, MT_PT_ESCAPECLOCK)
addHook("TouchSpecial", GivePoints, MT_PT_ESCAPEBELL)

local function Transparency(mo)
	if displayplayer and displayplayer.valid then
		if not (PTV3.pizzatime or PTV3.minusworld)
		or (mo.collect_list[displayplayer]
		and mo.collect_list[displayplayer] == displayplayer.ptv3.laps) then
			mo.frame = $ | FF_TRANS50
		else
			mo.frame = $ & ~FF_TRANS50
		end
	end
end

addHook("MobjThinker", Transparency, MT_PT_ESCAPECLOCK)
addHook("MobjThinker", Transparency, MT_PT_ESCAPEBELL)

local function SetupCollectList(mo)
	mo.collect_list = {}
	mo.shadowscale = mo.scale
end

addHook("MobjSpawn", SetupCollectList, MT_PT_ESCAPECLOCK)
addHook("MobjSpawn", SetupCollectList, MT_PT_ESCAPEBELL)