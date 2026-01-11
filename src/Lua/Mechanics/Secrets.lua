freeslot("sfx_secfou",
	"sfx_secent",
	"sfx_secexi",
	"MT_PTV3_SECRET",
	"SPR_SIDL",
	"SPR_SCRY",
	"SPR_SEHI",
	"S_PTV3_SECRET",
	"S_PTV3_SECRET_CRY",
	"S_PTV3_SECRET_SPAWN"
)

sfxinfo[sfx_secent].caption = "Eye invasion"
sfxinfo[sfx_secexi].caption = "Fat tear"
sfxinfo[sfx_secfou].caption = "Secret found!"

mobjinfo[MT_PTV3_SECRET] = {
	--$Name "Secret Eye"
	--$Sprite SIDLA0
	--$Category "PTV3A"
	--$Color 13
	--$Arg0 Group
	--$Arg1 Type
	--$Arg1Type 11
	--$Arg1Enum { 0="Entry"; 1="EntryDest"; 2="Exit";}
	--$Arg2 Set 2D?
	--$Arg2Type 11
	--$Arg2Enum { 0="No"; 1="Yes";}
	--$Arg3 Distance to Reveal
	--$Arg3Type 0
	--$Arg3Default 0
	--$Arg3RenderStyle Circle
	--$Arg3RenderColor d868a0
    doomednum = 2222,
    spawnstate = S_PTV3_SECRET,
	spawnhealth = 1000,
	deathstate = S_NULL,
    radius = 16*FRACUNIT,
    height = 48*FRACUNIT,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_SECRET_SPAWN] = {
	sprite = SPR_SEHI,
	frame = A|FF_ANIMATE,
	tics = 20,
	action = nil,
	var1 = 10,
	var2 = 2,
	nextstate = S_PTV3_SECRET
}

states[S_PTV3_SECRET] = {
    sprite = SPR_SIDL,
    frame = A|FF_ANIMATE,
    tics = -1,
    action = function(secret)
		if secret.hidden then secret.hidden = false end
	end,
    var1 = 13,
    var2 = 2,
    nextstate = S_PTV3_SECRET
}

states[S_PTV3_SECRET_CRY] = {
    sprite = SPR_SCRY,
    frame = A|FF_ANIMATE,
    tics = -1,
    action = nil,
    var1 = 11,
    var2 = 2,
    nextstate = S_PTV3_SECRET_CRY
}

local saved_sky = 0

addHook('MapLoad', function() saved_sky = 0 end)

addHook('MapThingSpawn', function(secret, thing)
	secret.sgroup = thing.args[0]
	secret.stype = thing.args[1]
	secret.switch_2D = thing.args[2]
	secret.reveal_range = thing.args[3]*FU

	if secret.reveal_range > 0 then
		secret.flags2 = $|MF2_DONTDRAW
		secret.hidden = true
	end

	table.insert(PTV3.secrets, secret)
	print(#PTV3.secrets)
end, MT_PTV3_SECRET)

addHook('MobjSpawn', function(secret)
	secret.teleported = {}
end, MT_PTV3_SECRET)

addHook("MobjThinker", function(secret)
	if not secret.hidden
	or secret.state == S_PTV3_SECRET_SPAWN then return end

	for p in players.iterate() do
		if not (p.mo and p.mo.valid) then continue end

		local pmo = p.mo
		local dist = R_PointToDist2(0, 0, R_PointToDist2(pmo.x, pmo.y, secret.x, secret.y), pmo.z-secret.z)

		if dist < secret.reveal_range then
			secret.state = S_PTV3_SECRET_SPAWN
			secret.flags2 = $ & ~MF2_DONTDRAW
			break
		end
	end
end, MT_PTV3_SECRET)

local function FindSecretEye(entered, group)
	---@type mobj_t
	for _, v in ipairs(PTV3.secrets) do
		if v.sgroup ~= entered.sgroup then continue end

		if (entered.stype == 2 and v.stype == 0)
		or (v.stype < 2 and entered.stype < v.stype) then
			return v
		end
	end
end

-- function PTV3:SetSecrets()
-- 	for mobj in mobjs.iterate() do
-- 		if mobj.type == MT_PTV3_SECRET then
			
-- 		end
-- 	end
-- end

addHook('TouchSpecial', function(secret,mo)
	if secret.stype == 1 or secret.hidden
	or not (mo and mo.valid and mo.player)
	or (PTV3.overtime and not (mo.player and mo.player.ptv3 and mo.player.ptv3.insecret))
	or secret.teleported[mo.player] then return true end

	local p = mo.player
	local next_secret = FindSecretEye(secret)
	local link = { x=next_secret.x, y=next_secret.y, z=next_secret.z, a=next_secret.angle }
	
	if secret.stype == 2 then
		PTV3:exitSecret(p)
		S_StartSound(p.mo, sfx_secexi)
		PTV3.callbacks('ExitSecret', p)
	else
		p.ptv3.insecret = true
		p.ptv3.secretsfound = $+1

		S_StartSound(nil, sfx_secfou, p)
		S_StartSound(p.mo, sfx_secent, p)

		saved_sky = levelskynum
		P_SetupLevelSky(102, p)
		PTV3.callbacks('FoundSecret', p)
	end

	PTV3.hud_secret = leveltime
	PTV3:queueTeleport(p, link, false, secret)
	PTV3:increaseCombo(p, 3)
	
	next_secret.state = S_PTV3_SECRET_CRY
	mo.flags2 = secret.switch_2D and $|MF2_TWOD or $ & ~MF2_TWOD
	secret.teleported[p] = true

	return true
end, MT_PTV3_SECRET)

--- Forces the player to exit the secret they are in.
---@param p player_t
function PTV3:exitSecret(p)
	if not (p and p.ptv3 and p.ptv3.insecret) then return end

	if p.ptv3.secret_tptoend then
		PTV3:queueTeleport(p)
		p.ptv3.secret_tptoend = false
	end
	if p == consoleplayer
	and saved_sky then
		if PTV3.overtime then
			
			P_SetSkyboxMobj(nil, false)
			P_SetupLevelSky(9, p)
		elseif PTV3.extreme then
			P_SetSkyboxMobj(nil, false)
			P_SetupLevelSky(34, p)
		else
			P_SetupLevelSky(saved_sky, p)
		end

		saved_sky = 0
	end
	p.ptv3.insecret = false
end