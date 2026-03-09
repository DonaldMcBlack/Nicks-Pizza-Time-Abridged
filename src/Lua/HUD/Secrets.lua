local function drawTransString(v,x,y,text,flags,alpha,align)
	if alpha ~= nil and alpha == 10 then return end

	local dflags = flags
	if alpha ~= nil and alpha > 0 then
		dflags = alpha<<V_ALPHASHIFT|flags
	end

	return customhud.CustomFontString(v,
		x*FU, y*FU, text, "PTFNT",
		dflags,
		align,
		FU/5,
		SKINCOLOR_WHITE
	)
end

return function(v)
	if PTV3.hud_secret < 0 then return end
	local time = PTV3.HUD_returnTime(PTV3.hud_secret, 5*FU)
	if time > FU then return end

	local flashTime = PTV3.HUD_returnTime(PTV3.hud_secret, TICRATE, nil, true)
	v.fadeScreen(0xFF00, ease.linear(flashTime, 31, 0))
	
	local first_visible = min(time * 30 / FU, 10)
	local second_visible = min((FU-time) * 30 / FU, 10)
	
	first_visible = 10-$
	second_visible = 10-$
	
	local visible = max(first_visible, second_visible)

	local text = string.format('You found %d secret%s out of %d',
		consoleplayer.PTRound.secretsfound,
		consoleplayer.PTRound.secretsfound > 1 and "s" or "",
		PTV3.secret_count,
		"!"
	)

	local flags = V_SNAPTOBOTTOM
	
	drawTransString(v,160,160,text,flags,visible,"center")
end