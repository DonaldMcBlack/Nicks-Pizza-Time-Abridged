return function(v,p)
	if not PTV3:isPTV3() or not (p and p.ptv3 and p.ptv3.chaser) then return end

	local chaser = p.ptv3.pizzaMobj_skindata

	local screenWidth = (v.width()/v.dupx())*FU
	local screenHeight = (v.height()/v.dupy())*FU

	local ability_2 = v.cachePatch("ACTION_NULL")
	local ability_3 = v.cachePatch("ACTION_NULL")

	-- v.drawScaled(12*FU, screenHeight-42*FU, FU/4, v.cachePatch("ACTION_NULL"), V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	-- v.drawScaled(36*FU, screenHeight-42*FU, FU/4, v.cachePatch("ACTION_NULL"), V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	-- v.drawScaled(60*FU, screenHeight-42*FU, FU/4, v.cachePatch("ACTION_NULL"), V_SNAPTOLEFT|V_SNAPTOBOTTOM)

	-- local time = FixedDiv(max(0, min(PTV3.maxpftime-PTV3.pftime, 2*TICRATE)), 2*TICRATE)
	-- local endtime = FixedDiv(max(0, min(PTV3.pftime, 2*TICRATE)), 2*TICRATE)

	-- local startTween = ease.linear(time, 200*FU, 180*FU)
	-- local endTween = ease.linear(FU-endtime, 180*FU, 200*FU)

	-- local y = max(startTween, endTween)

	if not chaser.abilities then return end

	for i = 1, #chaser.abilities do

		local ability = v.patchExists(chaser.abilities[i].icon) and v.cachePatch(chaser.abilities[i].icon) or v.cachePatch("ACTION_NULL")
		local x_frame = 12*FU
		local x_text = 11*FU

		if i > 1 then
			local last_ability = v.patchExists(chaser.abilities[i-1].icon) and v.cachePatch(chaser.abilities[i-1].icon) or v.cachePatch("ACTION_NULL")

			x_frame = ($*i)+(last_ability.width*(i-1)*FU)
			x_text  = ($*i)+((last_ability.width/2)*(i-1)*(FU-(FU/5)))
		end

		v.drawScaled(x_frame/2, screenHeight-56*FU, FU/3, ability, V_SNAPTOLEFT|V_SNAPTOBOTTOM)

		customhud.CustomFontString(v,
			x_text, screenHeight-30*FU,
			chaser.abilities[i].button,
			"PTFNT",
			V_SNAPTOBOTTOM|V_SNAPTOLEFT,
			"fixed-center",
			FU/4,
			SKINCOLOR_WHITE
		)
	end
	
end