return function(v,p)
	if not PTV3:isPTV3() or not (p and p.PTRound and p.PTRound.chaser) then return end

	local chaser = p.PTRound.pizzaMobj_skindata

	local screenWidth = (v.width()/v.dupx())*FU
	local screenHeight = (v.height()/v.dupy())*FU

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