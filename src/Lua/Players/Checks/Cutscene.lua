states[freeslot "S_PTV3_WALKANIM"] = {
	sprite = SPR_PLAY,
	frame = SPR2_WALK,
	tics = 3,
	nextstate = S_PTV3_WALKANIM
}



local function cutscene(p)
	local cutsceneTime = PTV3.maxTitlecardTime+(2*TICRATE)

	if leveltime < cutsceneTime
	and PTV3.spawnGate
	and PTV3.spawnGate.valid
	and leveltime >= PTV3.maxTitlecardTime then
		local time = leveltime - PTV3.maxTitlecardTime
		local remain = cutsceneTime - leveltime

		local tweenTime = min(FixedDiv(time, TICRATE), FU)

		local spawn = PTV3.spawnGate.spawnPoints[#p+1] or PTV3.spawnGate.spawnPoints[1]
		local sg = PTV3.spawnGate

		p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
		p.drawangle = sg.angle

		local tweenX = ease.outcubic(tweenTime, sg.x, spawn.x)
		local tweenY = ease.outcubic(tweenTime, sg.y, spawn.y)
		local tweenZ = ease.outcubic(tweenTime, sg.z, spawn.z)

		P_SetOrigin(p.mo,
			tweenX,
			tweenY,
			tweenZ)

		if remain > 1 then
			local state = S_PTV3_WALKANIM
			if remain < TICRATE then
				state = S_PLAY_PAIN
			end
			if p.mo.state ~= state then
				p.mo.state = state
			end
			p.mo.angle = PTV3.spawnGate.angle+ANGLE_180
		else
			p.mo.state = S_PLAY_STND
			p.mo.angle = PTV3.spawnGate.angle
		end

		return true
	end

	return false
end

local function precutscene(p)
	local cutsceneTime = PTV3.maxTitlecardTime+(2*TICRATE)

	if leveltime < cutsceneTime
	and PTV3.spawnGate
	and PTV3.spawnGate.valid then
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = 0
	end
end

return cutscene,precutscene