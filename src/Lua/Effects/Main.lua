freeslot("MT_PTV3_EFFECT")
freeslot("SKINCOLOR_PURERED")

skincolors[SKINCOLOR_PURERED] = {
    name = "Pure Red",
    ramp = {35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35},
    invcolor = SKINCOLOR_WHITE,
    invshade = 0,
    chatcolor = V_SKYMAP,
    accessible = false
}

mobjinfo[MT_PTV3_EFFECT] = {
	doomednum = -1,
	spawnstate = S_THOK,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = FU,
	height = FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

local files = {
	"Taunt",
	"PF Afterimage",
	"Snick Afterimage",
	"Debris",
	"Treasure Effect"
}

PTV3.effects = {}
for _,i in ipairs(files) do
	PTV3.effects[i] = dofile("Effects/"..i)
end

function PTV3:doEffect(mo, effect)
	effect = self.effects[effect]

	if type(effect.state) == "string"
	and effect.state == "ghost" then
		local mobj = P_SpawnGhostMobj(mo)

		mobj.fuse = effect.fuse
		mobj.tics = effect.tics
		mobj.color = effect.color
		mobj.colorized = true
		mobj.target = mo
		
		if effect.flags then
			mobj.frame = effect.flags
		end

		if effect.follow then
			mobj.follow = true
		end

		return mobj
	end

	local mobj = P_SpawnMobjFromMobj(mo, 0,0,0, MT_PTV3_EFFECT)

	mobj.target = mo
	mobj.scale = mo.scale
	mobj.destscale = mo.destscale
	if effect.follow then
		mobj.follow = true
	end
	if effect.gravity then
		mobj.flags = ($|MF_NOCLIPHEIGHT|MF_NOCLIP) & ~(MF_NOGRAVITY)
		mobj.kafc = true --kill after floor or ceiling
	end
	mobj.state = effect.state
	if effect.randomframe then
		mobj.frame = P_RandomKey(effect.randomframe)
	end

	if effect.func then
		effect.func(mo, mobj)
	end

	return mobj
end

addHook('MobjThinker', function(mobj)
	if not (mobj.target
	and mobj.target.valid)
	and mobj.follow then
		P_RemoveMobj(mobj)
		return
	end

	if mobj.target
	and mobj.target.valid
	and mobj.follow then

		P_SetOrigin(mobj,
			mobj.target.x-mobj.target.momx,
			mobj.target.y-mobj.target.momy,
			mobj.target.z-mobj.target.momz
		)
		mobj.momx = mobj.target.momx
		mobj.momy = mobj.target.momy
		mobj.momz = mobj.target.momz
		mobj.dispoffset = -1
	end
	if mobj.target
	and mobj.target.valid
	and mobj.target.tracer
	and mobj.target.tracer.valid then
		-- cheap pf first person fix lmao
		local pmo = mobj.target.tracer
		
		if displayplayer
		and displayplayer == pmo.player
		and camera
		and not camera.chase then
			mobj.flags2 = $|MF2_DONTDRAW
		else
			mobj.flags2 = $ & ~MF2_DONTDRAW
		end
	end
	if mobj.kafc then
		if mobj.z+mobj.height < mobj.floorz
		or mobj.z > mobj.ceilingz then
			P_RemoveMobj(mobj)
			return
		end
	end
end, MT_PTV3_EFFECT)