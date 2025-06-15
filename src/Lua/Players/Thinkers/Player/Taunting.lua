states[freeslot "S_PTV3_TAUNTSTATE"] = {
	sprite = SPR_PLAY,
	frame = SPR2_WALK,
	tics = (8*2)+2,
	nextstate = S_PLAY_STND
}

PTV3.tauntData = {
	Default = {
		{SPR2_DEAD, A},
		{SPR2_WALK, A},
		{SPR2_FALL, A},
		{SPR2_PAIN, A},
		
		canTaunt = true
	}
}

local function taunt(p)
	if p.ptv3.isTaunting then
		p.ptv3.tauntTime = max(0, $-1)

		p.mo.state = S_PTV3_TAUNTSTATE
		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		p.mo.state = S_PLAY_ROLL
		p.mo.sprite2 = p.ptv3.tauntsprite
		p.mo.frame = p.ptv3.tauntframe

		if not (p.ptv3.tauntTime) then
			p.mo.momx = p.ptv3.tauntmomx
			p.mo.momy = p.ptv3.tauntmomy
			p.mo.momz = p.ptv3.tauntmomz
			p.mo.state = p.ptv3.tauntlaststate
			p.ptv3.isTaunting = false
			P_MovePlayer(p)
			PTV3.callbacks("TauntEnd", p)
		end
	end

	if p.cmd.buttons & BT_TOSSFLAG
	and not (p.ptv3.buttons & BT_TOSSFLAG)
	and not p.ptv3.isTaunting then
		local tauntData = PTV3.tauntData[p.mo.skin] or PTV3.tauntData["Default"]

		if tauntData.canTaunt then
			local spriteData = tauntData[P_RandomRange(1,#tauntData)]
			local sprite = spriteData[1]
			local frame = spriteData[2]
			
			p.ptv3.isTaunting = true
			p.ptv3.tauntmomx = p.mo.momx
			p.ptv3.tauntmomy = p.mo.momy
			p.ptv3.tauntmomz = p.mo.momz
			p.ptv3.tauntlaststate = p.mo.state
			p.ptv3.tauntsprite = sprite
			p.ptv3.tauntframe = frame

			p.ptv3.tauntTime = 8*2
			if not PTV3.callbacks("TauntStart", p) then
				PTV3:doEffect(p.mo, "Taunt")
			end
		end
	end
end

local function pretaunt(p)
	if p.ptv3.isTaunting then
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		if p.cmd.buttons & BT_TOSSFLAG then
			p.cmd.buttons = BT_TOSSFLAG
		else
			p.cmd.buttons = 0
		end
	end
end

return taunt,pretaunt