local function ManageItemPos(p, mo, set)
    local rawitem = PTV3.items[p.PTGlobal.curItem]

    local tpfunc = set and P_SetOrigin or P_MoveOrigin

	if rawitem.animation then
		local t = FixedDiv(rawitem.anim, rawitem.max_anim)

		rawitem.pos = {
			x = ease.incubic(t, rawitem.default_pos.x, rawitem.anim_pos.x),
			y = ease.incubic(t, rawitem.default_pos.y, rawitem.anim_pos.y),
			z = ease.incubic(t, rawitem.default_pos.z, rawitem.anim_pos.z),
		}
	else
		rawitem.pos = {
			x = rawitem.default_pos.x,
			y = rawitem.default_pos.y,
			z = rawitem.default_pos.z
		}
	end

	local radius = p.mo.radius

	local ox = FixedMul(radius*3/2, rawitem.pos.y)
	local oy = FixedMul(radius*3/2, -rawitem.pos.x)

	local xx = FixedMul(ox, cos(p.mo.angle))
	local xy = FixedMul(ox, sin(p.mo.angle))
	local yx = FixedMul(oy, sin(p.mo.angle))
	local yy = FixedMul(oy, cos(p.mo.angle))

	local x = xx-yx
	local y = yy+xy
	local h = p.mo.height/2
	local z = FixedMul(h, rawitem.pos.z)

	mo.angle = p.mo.angle
	mo.scale = p.mo.scale
	mo.fuse = 1
	tpfunc(mo,
		p.mo.x + x,
		p.mo.y + y,
		p.mo.z+h+z
	)
	
	if (P_MobjFlip(p.mo) == -1) then
		mo.z = $ - mo.height
		mo.eflags = $|MFE_VERTICALFLIP
	else
		mo.eflags = $ &~MFE_VERTICALFLIP
	end
	
	do
		local slope = InvAngle(p.aiming)
		mo.roll = FixedMul(slope, sin(p.mo.angle))
		mo.pitch = FixedMul(slope, cos(p.mo.angle))
	end
	
	--Hide in 1st person
	if rawitem.showinfirstperson then
		mo.dontdrawforviewmobj = nil
	else
		mo.dontdrawforviewmobj = p.mo
	end
end

return function(p)
    local item = p.PTGlobal.curItem
    if not item then return end

    if PTV3.items[item].equipable and not p.PTRound.curItem_mobj then
        p.PTRound.curItem_mobj = PTV3:MakeItemMobj(p.mo, item)
    end

    local item_mobj = p.PTRound.curItem_mobj

    if item_mobj and item_mobj.valid then
        ManageItemPos(p, p.PTRound.curItem_mobj)

        if p.PTRound.curItem_equipped then
            p.PTRound.curItem_mobj.flags2 = $ & ~MF2_DONTDRAW
        else
            p.PTRound.curItem_mobj.flags2 = $|MF2_DONTDRAW
        end
    end

    if item then
        if (p.PTGlobal.buttons & BT_CUSTOM1) and not (p.PTGlobal.lastbuttons & BT_CUSTOM1) then
            if PTV3.items[item].equipable then
                p.PTRound.curItem_equipped = not p.PTRound.curItem_equipped
                if p.PTRound.curItem_equipped then S_StartSound(p.mo, PTV3.items[item].equip_sfx) end
            else
                PTV3:InstantUseItem(p)
            end
        end

        if p.PTRound.curItem_equipped and (p.PTGlobal.buttons & BT_FIRENORMAL) and not (p.PTGlobal.lastbuttons & BT_FIRENORMAL) then
            PTV3:UseEquipableItem(p)
        end
    end
end