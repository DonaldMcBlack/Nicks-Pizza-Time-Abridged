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

local x = -35*FU

return function(v)
	if not PTV3:isPTV3() then return end
	if not (PTV3.pizzaface and PTV3.pizzaface.valid) then return end

	local skindata = PTV3.pizzaface.PTRound and PTV3.pizzaface.PTRound.pizzaMobj_skindata or PTV3.pizzaface.skindata
	if not skindata.enraged then return end

	x = ease.outcubic(5*FU, -50*FU, 15*FU)
	local y = 150*FU

	local intensity = FU
	local shakeX = v.RandomRange(-intensity, intensity)
	local shakeY = v.RandomRange(-intensity, intensity)

	local dec = L_FixedDecimal(PTV3.pizzaface.speed or 0, 2)

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