return function(v)
	if not PTV3:isPTV3() then return end
	if not (PTV3.pizzatime and PTV3.extreme) then return end
	if not PTV3.pizzaface then return end

	local intensity = FU
	local shakeX = v.RandomRange(-intensity, intensity)
	local shakeY = v.RandomRange(-intensity, intensity)
    local patch = "Pizzaface's Rage: "..PTV3.pizzaface.incremspeed

    customhud.CustomFontString(v,
		(160*FU)+shakeX, (24*FU)+shakeY,
		patch,
		"PTFNT",
		V_SNAPTOTOP,
		"center",
		FU/4,
        SKINCOLOR_RED
	)
end