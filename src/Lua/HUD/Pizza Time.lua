return function(v)
	if not PTV3.pizzatime then return end
	if PTV3.starttime_pizzatime < 0 then return end
	local time = PTV3.HUD_returnTime(PTV3.starttime_pizzatime, 3*FU)
	
	local flashTime = PTV3.HUD_returnTime(PTV3.starttime_pizzatime, PTV3.pizzatime > 0 and TICRATE/4 or TICRATE/2, nil, true)
	v.fadeScreen(SKINCOLOR_WHITE, ease.linear(flashTime, 10, 0))

	local patch1 = PTV3.pizzatime < 0 and v.cachePatch('MINUS1') or v.cachePatch('PITIM1')
	local patch2 = PTV3.pizzatime < 0 and v.cachePatch('MINUS2') or v.cachePatch('PITIM2')
	
	local patch = (leveltime % 4) / 2 and patch1 or patch2
	local scale = FU/3
	local x = (160*FU) - ((patch.width/2)*scale)
	local y = PTV3.pizzatime < 0 and ease.linear(time, -(patch.height*scale), (v.height()/v.dupx())*FU) or ease.linear(time, (v.height()/v.dupx())*FU, -(patch.height*scale))

	v.drawScaled(x,y,scale,patch,V_SNAPTOTOP)
end