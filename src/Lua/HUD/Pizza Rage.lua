rawset(_G, "L_FixedDecimal", function(str,maxdecimal)
	if str == nil or tostring(str) == nil then
		return "<invalid FixedDecimal>"
	end
	local number = tonumber(str)
	maxdecimal = ($ ~= nil) and $ or 3
	if tonumber(str) == 0 then return '0' end
	local polarity = abs(number)/number
	local str_polarity = (polarity < 0) and '-' or ''
	local str_whole = tostring(abs(number/FRACUNIT))
	if maxdecimal == 0 then
		return str_polarity..str_whole
	end
	local decimal = number%FRACUNIT
	decimal = FRACUNIT + $
	decimal = FixedMul($,FRACUNIT*10^maxdecimal)
	decimal = $>>FRACBITS
	local str_decimal = string.sub(decimal,2)
	return str_polarity..str_whole..'.'..str_decimal
end)

return function(v)
	if not PTV3:isPTV3() then return end
	if not (PTV3.pizzatime and PTV3.extreme) then return end
	if not PTV3.pizzaface then return end

	local x = ease.linear(FU, -15*FU, 15*FU)
	local y = 150*FU

	-- CONS_Printf(consoleplayer, "Pizza Rage: "..x)

	local intensity = FU
	local shakeX = v.RandomRange(-intensity, intensity)
	local shakeY = v.RandomRange(-intensity, intensity)

	local dec = L_FixedDecimal(PTV3.pizzaface.incremspeed, 2)

	local patch = v.cachePatch("PIZZARAGE")

	v.drawScaled(x, y, FU/2, patch, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
    patch = dec

    customhud.CustomFontString(v,
		(x+(30*FU))+shakeX, (y+(5*FU))+shakeY,
		patch,
		"PTFNT",
		V_SNAPTOBOTTOM|V_SNAPTOLEFT,
		"center",
		FU/4,
        SKINCOLOR_RED
	)
end