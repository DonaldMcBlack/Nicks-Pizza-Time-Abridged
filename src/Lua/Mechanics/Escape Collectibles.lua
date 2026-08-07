freeslot("MT_PT_ESCAPECLOCK", "S_PT_ESCAPECLOCK", "SPR_ESCK")
freeslot("sfx_escl01", "sfx_escl02", "sfx_escl03", "sfx_escl04", "sfx_escl05")

local clocksoundlist = {
	sfx_escl01,
	sfx_escl02,
	sfx_escl03,
	sfx_escl04,
	sfx_escl05,
}

for _,i in pairs(clocksoundlist) do
	sfxinfo[i].flags = SF_TOTALLYSINGLE
	sfxinfo[i].caption = "Clonk!"
end

mobjinfo[MT_PT_ESCAPECLOCK] = {
	--$Name Escape Clock
	--$Sprite ESCKA0
	--$Category "PTV3A"
	--$Color 12
	--$NotAngled
	--$Arg0 Float?
	--$Arg0Tooltip Makes the collectible float 24*FRACUNITS from the ground. On by default.
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 2114,
	spawnstate = S_PT_ESCAPECLOCK,
	radius = 16*FU,
	height = 24*FU,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

freeslot("MT_PT_ESCAPEBELL", "S_PT_ESCAPEBELL", "SPR_BELL")
freeslot("sfx_esbl01", "sfx_esbl02", "sfx_esbl03")

local bellsoundlist = {
	sfx_esbl01,
	sfx_esbl02,
	sfx_esbl03
}

for _,i in pairs(bellsoundlist) do
	sfxinfo[i].flags = SF_TOTALLYSINGLE
	sfxinfo[i].caption = "Ding!"
end

mobjinfo[MT_PT_ESCAPEBELL] = {
	--$Name Escape Bell
	--$Sprite BELLA0
	--$Category "PTV3A"
	--$Color 14
	--$NotAngled
	--$Arg0 Float?
	--$Arg0Tooltip Makes the collectible float 24*FRACUNITS from the ground. On by default.
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 2115,
	spawnstate = S_PT_ESCAPEBELL,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
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

freeslot("MT_PT_DEATHWATCH", "S_PT_DEATHWATCH", "SPR_DMW1")

mobjinfo[MT_PT_DEATHWATCH] = {
	--$Name Death Watch
	--$Sprite DMW1A0
	--$Category "PTV3A"
	--$Color 13
	--$NotAngled
	doomednum = 2116,
	spawnstate = S_PT_DEATHWATCH,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_PT_DEATHWATCH] = {
	sprite = SPR_DMW1,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = 16,
	var2 = 2,
}

freeslot("MT_PT_ESCAPEDEATHWATCH", "S_PT_ESCAPEDEATHWATCH", "SPR_DMW2")

mobjinfo[MT_PT_ESCAPEDEATHWATCH] = {
	--$Name Death Watch
	--$Sprite DMW2A0
	--$Category "PTV3A"
	--$Color 13
	--$NotAngled
	doomednum = 2117,
	spawnstate = S_PT_ESCAPEDEATHWATCH,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_PT_ESCAPEDEATHWATCH] = {
	sprite = SPR_DMW2,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = 16,
	var2 = 2,
}

--- Gives combo points to the player.
---@param esc_mo mobj_t
---@param pmo mobj_t
local function GivePoints(esc_mo, pmo)
	if not (esc_mo and esc_mo.valid) or not (pmo and pmo.valid) then return true end
	if not esc_mo.collect_list then return true end

	local player = pmo.player

	if not (player and player.valid) or player.PTRound.pizzaface then return true end

	if esc_mo.collect_list[player] == nil or esc_mo.collect_list[player] ~= player.PTRound.laps then
		esc_mo.collect_list[player] = player.PTRound.laps

		if not PTV3.pizzatime then return true end
		
		if esc_mo.type == MT_PT_ESCAPECLOCK then
			S_StartSound(pmo, clocksoundlist[P_RandomRange(1,#clocksoundlist)])
			P_AddPlayerScore(player, 10)
			PTV3:increaseCombo(player, 2, PTV3.MAX_COMBO_TIME/5)

			player.rings = player.powers[pw_super] > 0 and $+1 or $
		end

		if esc_mo.type == MT_PT_ESCAPEBELL then
			S_StartSound(pmo, bellsoundlist[P_RandomRange(1,#bellsoundlist)])
			P_AddPlayerScore(player, 100)
			PTV3:increaseCombo(player, 3)

			player.rings = player.powers[pw_super] > 0 and $+5 or $
		end
	end
	return true
end

addHook("TouchSpecial", GivePoints, MT_PT_ESCAPECLOCK)
addHook("TouchSpecial", GivePoints, MT_PT_ESCAPEBELL)

local function Transparency(mo)
	if not (displayplayer and displayplayer.valid) then return end

	local p = displayplayer
	mo.frame = (not PTV3.pizzatime or (mo.collect_list[p] and mo.collect_list[p] == p.PTRound.laps)) and $|FF_TRANS50 or $ & ~FF_TRANS50
end

addHook("MobjThinker", Transparency, MT_PT_ESCAPECLOCK)
addHook("MobjThinker", Transparency, MT_PT_ESCAPEBELL)

local function SetupCollectList(mo, mt)
	mo.collect_list = {}
	mo.shadowscale = mo.scale

	if mt.args[0] == 0 and mo.type == (MT_PT_ESCAPECLOCK or MT_PT_ESCAPEBELL) then
		local z = P_MobjFlip(mo) == -1 and mo.ceilingz or mo.floorz
		local amount = P_MobjFlip(mo) == -1 and -24*FU or 24*FU
		P_SetOrigin(mo, mo.x, mo.y, z+amount)
	end
end

addHook("MapThingSpawn", SetupCollectList, MT_PT_ESCAPECLOCK)
addHook("MapThingSpawn", SetupCollectList, MT_PT_ESCAPEBELL)

local function DeathModeCheck(mo) if gametype ~= GT_PTV3DM then P_RemoveMobj(mo) end end

addHook("MobjSpawn", DeathModeCheck, MT_PT_DEATHWATCH)
addHook("MobjSpawn", DeathModeCheck, MT_PT_ESCAPEDEATHWATCH)

local function PizzafaceTimerAdd(watch, mo, dontdestroy)
	local player_laps = mo.player.PTRound.laps

	if dontdestroy then
		if watch.highestlap < player_laps then
			watch.highestlap = player_laps
		else
			return dontdestroy
		end
	end

	S_StartSound(mo, sfx_secfou)
	PTV3.pftime = $ + 10*TICRATE
	PTV3.maxpftime = PTV3.maxpftime < PTV3.pftime and PTV3.pftime or $
	return dontdestroy
end

addHook("TouchSpecial", function(watch, mo) return PizzafaceTimerAdd(watch, mo, false) end, MT_PT_DEATHWATCH)

addHook("MapThingSpawn", function(mo)
	mo.highestlap = 0
	mo.shadowscale = mo.scale
end, MT_PT_ESCAPEDEATHWATCH)

addHook("MobjThinker", function(mo)
	if not (displayplayer and displayplayer.valid) then return end

	local p = displayplayer

	mo.flags2 = (not PTV3.pizzatime) and $|MF2_DONTDRAW or $ & ~MF2_DONTDRAW
	mo.frame = p.PTRound.laps <= mo.highestlap and $|FF_TRANS50 or $ & ~FF_TRANS50
end, MT_PT_ESCAPEDEATHWATCH)

addHook("TouchSpecial", function(watch, mo) return PizzafaceTimerAdd(watch, mo, true) end, MT_PT_ESCAPEDEATHWATCH)