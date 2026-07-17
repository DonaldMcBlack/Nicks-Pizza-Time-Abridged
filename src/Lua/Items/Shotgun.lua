freeslot("SPR_SHGN", "S_PTV3_SHOTGUN")
freeslot("sfx_stgng", "sfx_stgnf")

states[S_PTV3_SHOTGUN] = {
    sprite = SPR_SHGN,
    frame = A,
    tics = -1,
    action = nil,
    var1 = 0,
    var2 = 0,
    nextstate = S_PTV3_SHOTGUN
}

sfxinfo[sfx_stgng].caption = "Locked and loaded!"
sfxinfo[sfx_stgnf].caption = "GUN SHOT"

-- TODO: Make a visualiser of where the gun shot is aimed towards.
-- TODO: Don't use searchBlockmap for release build.
local function shotgunUse(p, shotgun)
	S_StartSound(shotgun, sfx_stgnf)
	local i = 0
	local dist = 0
	local z_dist = 0
	local angle_limit = 0
	local vertical = false

	if P_IsObjectOnGround(p.mo) then
		p.mo.momx, p.mo.momy = $/8, $/8

		dist = 80*FU
		angle_limit = 20
	else
		P_SetObjectMomZ(p.mo, 15*FU, false)

		dist = 20*FU
		angle_limit = 180
		vertical = true
	end

	z_dist = vertical == true and -40*FU or P_RandomRange(-5, 5)*FU

	searchBlockmap("objects", function(refmobj, foundmobj)
        if foundmobj and foundmobj.valid then
			if PTV3.pizzaface or PTV3.johnGhost then return end
			if not foundmobj.valid or foundmobj == p.mo then return end
			if vertical and shotgun.z-z_dist < foundmobj.z then return end


			local angletotarget = R_PointToAngle2(shotgun.x, shotgun.y, foundmobj.x, foundmobj.y) - shotgun.angle

			print(angletotarget)
			if foundmobj.flags & MF_ENEMY and vertical then
				P_DamageMobj(foundmobj, shotgun, p.mo)
			elseif foundmobj.flags & MF_ENEMY and not vertical then
				if (angletotarget < ANGLE_45) or (angletotarget > -ANGLE_45) then
					P_DamageMobj(foundmobj, shotgun, p.mo)
				end
			end
        end
    end, shotgun,
    shotgun.x-dist*4, shotgun.x+dist*4,
    shotgun.y-dist*4, shotgun.y+dist*4)

	while i < 20 do
		local particle = P_SpawnMobjFromMobj(shotgun, 0, 0, 0, MT_DUST)
		particle.momx = P_ReturnThrustX(nil, shotgun.angle, dist)+(P_RandomRange(-angle_limit, angle_limit)*FU)
		particle.momy = P_ReturnThrustY(nil, shotgun.angle, dist)+(P_RandomRange(-angle_limit, angle_limit)*FU)
		particle.momz = z_dist
		particle.scalespeed = FU/TICRATE
		particle.destscale = 10*FU
		i = $+1
	end


end

local item = {}

item.id = "shotgun"
item.displayname = "Shotgun"
item.state = S_PTV3_SHOTGUN
item.graphic = { name = "SHOTGUNNY", offset_x = 6*FU, offset_y = 3*FU, scale = FU/2, }
item.equipable = true
item.use = shotgunUse
item.equip_sfx = sfx_stgng
item.ammo = -1

item.default_pos = { x = FU, y = 0, z = 0 }
item.anim_pos = { x = 0, y = (FU/10)*8, z = FU/3}

return item