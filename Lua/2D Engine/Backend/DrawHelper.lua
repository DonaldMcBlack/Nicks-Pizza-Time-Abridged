local dh = {}

local function _returnOffset(v, x, y, scale)
	if not (displayplayer
	and displayplayer.ptv3_2d) then return end

	local p = displayplayer
	local p2d = p.ptv3_2d

	local cx = FixedMul(p2d.camera.x, p2d.camera.scale)
	local cy = FixedMul(p2d.camera.y, p2d.camera.scale)


	local screenWidth = (v.width()/v.dupx())*FU
	local screenHeight = (v.height()/v.dupy())*FU

	scale = FixedMul($, p2d.camera.scale)

	x = FixedMul($, scale)-(cx-(screenWidth/2))
	y = FixedMul($, scale)-(cy-(screenHeight/2))

	return x,y,scale
end

function dh:drawScaled(v, x, y, scale, patch, flags, color)
	if not (displayplayer
	and displayplayer.ptv3_2d) then return end

	local p = displayplayer
	local p2d = p.ptv3_2d

	x, y, scale = _returnOffset(v, $1,$2,$3)

	local screenWidth = FixedDiv((v.width()/v.dupx())*FU, p2d.camera.scale)
	local screenHeight = FixedDiv((v.height()/v.dupy())*FU, p2d.camera.scale)

	local width = patch.width*scale
	local height = patch.height*scale

	if flags == nil then
		flags = 0
	end
	flags = $|V_SNAPTOLEFT|V_SNAPTOTOP

	if x >= screenWidth
	or x+width <= 0
	or y >= screenHeight
	or y+height <= 0 then
		return
	end

	v.drawScaled(x, y, scale, patch, flags, color)
end

function dh:drawStretched(v, x, y, hscale, vscale, patch, flags, color)
	if not (displayplayer
	and displayplayer.ptv3_2d) then return end

	local p = displayplayer
	local p2d = p.ptv3_2d

	local scale = FU
	x, y, scale = _returnOffset(v, $1,$2,$3)
	hscale = FixedMul($, scale)
	vscale = FixedMul($, scale)

	local screenWidth = FixedDiv((v.width()/v.dupx())*FU, p2d.camera.scale)
	local screenHeight = FixedDiv((v.height()/v.dupy())*FU, p2d.camera.scale)

	local width = patch.width*hscale
	local height = patch.height*vscale

	if flags == nil then
		flags = 0
	end
	flags = $|V_SNAPTOLEFT|V_SNAPTOTOP

	if x >= screenWidth
	or x+width <= 0
	or y >= screenHeight
	or y+height <= 0 then
		return
	end

	v.drawStretched(x, y, hscale, vscale, patch, flags, color)
end

function dh:drawCropped(v, x, y, hscale, vscale, patch, flags, c, sx, sy, w, h)
	if not (displayplayer
	and displayplayer.ptv3_2d) then return end

	local p = displayplayer
	local p2d = p.ptv3_2d

	local scale = FU
	x, y, scale = _returnOffset(v, $1,$2,$3)
	hscale = FixedMul($, scale)
	vscale = FixedMul($, scale)

	local screenWidth = FixedDiv((v.width()/v.dupx())*FU, p2d.camera.scale)
	local screenHeight = FixedDiv((v.height()/v.dupy())*FU, p2d.camera.scale)

	local width = patch.width*hscale
	local height = patch.height*vscale

	if flags == nil then
		flags = 0
	end
	flags = $|V_SNAPTOLEFT|V_SNAPTOTOP

	if x >= screenWidth
	or x+width <= 0
	or y >= screenHeight
	or y+height <= 0 then
		return
	end

	v.drawCropped(x, y, hscale, vscale, patch, flags, c, sx, sy, w, h)
end

function dh:drawString(v, x, y, scale, text, align, font, flags)
	if not (displayplayer
	and displayplayer.ptv3_2d) then return end

	local p = displayplayer
	local p2d = p.ptv3_2d

	x, y, scale = _returnOffset(v, $1,$2,$3)

	local screenWidth = FixedDiv((v.width()/v.dupx())*FU, p2d.camera.scale)
	local screenHeight = FixedDiv((v.height()/v.dupy())*FU, p2d.camera.scale)

	if flags == nil then
		flags = 0
	end
	flags = $|V_SNAPTOLEFT|V_SNAPTOTOP

	--[[if x >= screenWidth
	or x+width <= 0
	or y >= screenHeight
	or y+height <= 0 then
		return
	end]]
	
	customhud.CustomFontString(v,
		x,y,
		text,
		font or "PTFNT",
		flags,
		align,
		scale)
end

return dh