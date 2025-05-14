local function _makeState(stateName, spriteName, frame, endFrame, tics, length, ns)
	local state = freeslot(stateName)

	states[state] = {
		sprite = freeslot(spriteName),
		frame = frame|FF_ANIMATE,
		tics = length or -1,
		var1 = endFrame,
		var2 = tics,
		nextstate = ns or state
	}

	return state
end

local toppins = {
	["mushroom"] = {};
	["cheese"] = {};
	["tomato"] = {};
	["sausage"] = {};
	["pineapple"] = {};
}

toppins["mushroom"].idle  = _makeState("S_PTV3_TIDLE_MUSHROOM", "SPR_MTPI", A, 11, 2);
toppins["mushroom"].walk  = _makeState("S_PTV3_TWALK_MUSHROOM", "SPR_MTPR", A, 11, 2);
toppins["mushroom"].panic = _makeState("S_PTV3_TPANIC_MUSHROOM", "SPR_MTPP", A, 5, 2);
toppins["mushroom"].intro = _makeState("S_PTV3_TINTRO_MUSHROOM", "SPR_MTPH", A, 10, 2, 10*2, S_PTV3_TIDLE_MUSHROOM);

toppins["cheese"].idle  = _makeState("S_PTV3_TIDLE_CHEESE", "SPR_CTPI", A, 12, 2);
toppins["cheese"].walk  = _makeState("S_PTV3_TWALK_CHEESE", "SPR_CTPR", A, 13, 2);
toppins["cheese"].panic = _makeState("S_PTV3_TPANIC_CHEESE", "SPR_CTPP", A, 8, 2);
toppins["cheese"].intro = _makeState("S_PTV3_TINTRO_CHEESE", "SPR_CTPH", A, 10, 2, 10*2, S_PTV3_TIDLE_CHEESE);

toppins["tomato"].idle  = _makeState("S_PTV3_TIDLE_TOMATO", "SPR_TTPI", A, 15, 2);
toppins["tomato"].walk  = _makeState("S_PTV3_TWALK_TOMATO", "SPR_TTPR", A, 15, 2);
toppins["tomato"].panic = _makeState("S_PTV3_TPANIC_TOMATO", "SPR_TTPP", A, 6, 2);
toppins["tomato"].intro = _makeState("S_PTV3_TINTRO_TOMATO", "SPR_TTPH", A, 10, 2, 10*2, S_PTV3_TIDLE_TOMATO);

toppins["sausage"].idle  = _makeState("S_PTV3_TIDLE_SAUSAGE", "SPR_STPI", A, 17, 2);
toppins["sausage"].walk  = _makeState("S_PTV3_TWALK_SAUSAGE", "SPR_STPR", A, 11, 2);
toppins["sausage"].panic = _makeState("S_PTV3_TPANIC_SAUSAGE", "SPR_STPP", A, 7, 2);
toppins["sausage"].intro = _makeState("S_PTV3_TINTRO_SAUSAGE", "SPR_STPH", A, 10, 2, 10*2, S_PTV3_TIDLE_SAUSAGE);

toppins["pineapple"].idle  = _makeState("S_PTV3_TIDLE_PINEAPPLE", "SPR_PTPI", A, 19, 2);
toppins["pineapple"].walk  = _makeState("S_PTV3_TWALK_PINEAPPLE", "SPR_PTPR", A, 15, 2);
toppins["pineapple"].panic = _makeState("S_PTV3_TPANIC_PINEAPPLE", "SPR_PTPP", A, 11, 2);
toppins["pineapple"].intro = _makeState("S_PTV3_TINTRO_PINEAPPLE", "SPR_PTPH", A, 10, 2, 10*2, S_PTV3_TIDLE_PINEAPPLE);

states[freeslot "S_PTV3_TOPPINCAGE"] = {
	sprite = freeslot "SPR_CAGE",
	frame = A
}
mobjinfo[freeslot "MT_PTV3_TOPPINCAGE"] = {
	spawnstate = S_PTV3_TOPPINCAGE,
	radius = 16*FU,
	height = 16*FU,
	flags = MF_SPECIAL
}

sfxinfo[freeslot "sfx_gottpn"].caption = "Got a toppin!"

local function changeToppinState(tpn, state)
	if tpn.toppinState == state then return end

	local data = toppins[tpn.toppinType]

	tpn.toppinState = state
	tpn.state = data[state]
end

mobjinfo[freeslot "MT_PTV3_TOPPIN"] = {
	radius = 8*FU,
	height = 8*FU,
	spawnstate = S_PTV3_TINTRO_MUSHROOM,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

addHook("MobjSpawn", function(tpn)
	tpn.setx = 0
	tpn.sety = 0
	tpn.setz = 0
	tpn.offx = 0
	tpn.offy = 0
	tpn.offMult = FU/8
	tpn.t_offx = 0
	tpn.t_offy = 0
	tpn.toppinType = "mushroom"
	tpn.toppinState = "intro"
	tpn.chaseOffset = 3
	tpn.collectOffset = 1
end, MT_PTV3_TOPPIN)

local function __think(tpn)
	if tpn.toppinState == "intro" then return end

	if not (tpn.target and tpn.target.valid) then
		changeToppinState(tpn, "idle")
		tpn.t_offx = 0
		tpn.t_offy = 0
		return
	else
		local trgt = tpn.target

		if not (trgt
		and trgt.player
		and trgt.player.ptv3) then
			tpn.target = nil
			return
		end

		local p = trgt.player

		local sData = p.ptv3.savedData
		local data = sData[min(#sData, tpn.chaseOffset*(5-(tpn.collectOffset-1)))]

		local angle = R_PointToAngle2(0,0, data.momx, data.momy)
		if FixedHypot(data.momx,data.momy) then
			 tpn.angle = angle
		end

		tpn.t_offx = FixedMul(FixedMul(-trgt.radius, (FU*5/4)*tpn.collectOffset), cos(tpn.angle))
		tpn.t_offy = FixedMul(FixedMul(-trgt.radius, (FU*5/4)*tpn.collectOffset), sin(tpn.angle))

		if (data.x == tpn.setx and data.y == tpn.sety)
		and (abs(tpn.t_offx-tpn.offx) < FU and abs(tpn.t_offy-tpn.offy) < FU) then
			if not PTV3.pizzatime
				changeToppinState(tpn, "idle")
			else
				changeToppinState(tpn, "panic")
			end
		else
			changeToppinState(tpn, "walk")
		end
		tpn.setx = data.x
		tpn.sety = data.y
		tpn.setz = data.z
	end
end

addHook("MobjThinker", function(tpn)
	if not (tpn.target
	and tpn.target.valid) then
		P_RemoveMobj(tpn)
		return
	end
	if tpn.state ~= toppins[tpn.toppinType].intro
	and tpn.toppinState == "intro" then
		changeToppinState(tpn, "idle")
	end

	__think(tpn)

	if tpn.target.flags2 & MF2_DONTDRAW then
		tpn.flags2 = $|MF2_DONTDRAW
	else
		tpn.flags2 = $ & ~MF2_DONTDRAW
	end
	tpn.offx = $+FixedMul(tpn.t_offx-$, tpn.offMult)
	tpn.offy = $+FixedMul(tpn.t_offy-$, tpn.offMult)

	P_MoveOrigin(tpn,
		tpn.setx+tpn.offx,
		tpn.sety+tpn.offy,
		tpn.setz
	)
end, MT_PTV3_TOPPIN)

local toppinAmount = 1
local toppinTypes = {
	"mushroom",
	"cheese",
	"tomato",
	"sausage",
	"pineapple"
}
addHook("NetVars", function(n) toppinAmount = net($) end)
addHook("MapChange", do toppinAmount = 1 end)

addHook("MapThingSpawn", function(mo)
	if not PTV3:isPTV3() then return end

	local tpn = P_SpawnMobj(mo.x,mo.y,mo.z, MT_PTV3_TOPPINCAGE)
	tpn.angle = mo.angle
	tpn.toppinType = toppinTypes[toppinAmount]
	
	toppinAmount = $+1
	if toppinAmount > 5 then
		toppinAmount = 1
	end
	
	P_RemoveMobj(mo)
end, MT_EMBLEM)

addHook("TouchSpecial", function(gate, mo)
	if not (mo and mo.player and mo.player.ptv3) then return true end

	local p = mo.player

	for i = 0,5 do
		local angle = (360*(ANG1/6))*i

		local effect = PTV3:doEffect(gate, "Debris")
		effect.momx = 7*cos(angle)
		effect.momy = 7*sin(angle)
		effect.momz = 5*FU
	end

	local tpn = P_SpawnMobjFromMobj(gate, 0,0,0, MT_PTV3_TOPPIN)
	tpn.target = mo
	tpn.setx = mo.x
	tpn.sety = mo.y
	tpn.setz = mo.z
	tpn.toppinType = gate.toppinType
	tpn.state = toppins[tpn.toppinType].intro

	table.insert(p.ptv3.toppins, tpn)

	tpn.collectOffset = #p.ptv3.toppins

	p.score = $+300
	if p.ptv3.combo then
		p.ptv3.combo_pos = PTV3.MAX_COMBO_TIME
	end

	S_StartSound(tpn, sfx_gottpn)
end, MT_PTV3_TOPPINCAGE)