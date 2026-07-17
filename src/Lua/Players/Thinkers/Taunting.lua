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

PTV3.tauntData["npeppino"] = {canTaunt = false}
PTV3.tauntData["nthe_noise"] = {canTaunt = false}

local function taunt(p)
	if p.PTRound.isTaunting then
		p.PTRound.tauntTime = max(0, $-1)

		p.mo.state = S_PTV3_TAUNTSTATE
		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		p.mo.state = S_PLAY_ROLL
		p.mo.sprite2 = p.PTRound.tauntsprite
		p.mo.frame = p.PTRound.tauntframe

		if not (p.PTRound.tauntTime) then
			p.mo.momx = p.PTRound.tauntmomx
			p.mo.momy = p.PTRound.tauntmomy
			p.mo.momz = p.PTRound.tauntmomz
			p.mo.state = p.PTRound.tauntlaststate
			p.PTRound.isTaunting = false
			P_MovePlayer(p)
			PTV3.callbacks("TauntEnd", p)
		end
	end

	if p.PTGlobal.buttons & BT_TOSSFLAG
	and not (p.PTGlobal.lastbuttons & BT_TOSSFLAG)
	and not (p.pflags & PF_STARTDASH or p.pflags & PF_SPINNING or p.panim == PA_PAIN)
	and not p.PTRound.isTaunting then
		local tauntData = PTV3.tauntData[p.mo.skin] or PTV3.tauntData["Default"]

		if tauntData.canTaunt then
			local spriteData = tauntData[P_RandomRange(1,#tauntData)]
			local sprite = spriteData[1]
			local frame = spriteData[2]
			
			p.PTRound.isTaunting = true
			p.PTRound.tauntmomx = p.mo.momx
			p.PTRound.tauntmomy = p.mo.momy
			p.PTRound.tauntmomz = p.mo.momz
			p.PTRound.tauntlaststate = p.mo.state
			p.PTRound.tauntsprite = sprite
			p.PTRound.tauntframe = frame

			p.PTRound.tauntTime = 8*2
			if not PTV3.callbacks("TauntStart", p) then
				PTV3:doEffect(p.mo, "Taunt")
			end
		end
	end
end

local function pretaunt(p)
	if p.PTRound.isTaunting then
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = p.PTGlobal.lastbuttons
	end
end

return taunt,pretaunt