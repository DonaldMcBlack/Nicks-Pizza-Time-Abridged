local movement = dofile "Players/Libs/Chaser Movement"
-- local anticamp = dofile "Players/Libs/Anticamp"

local johnGhost = function(p)
    local canMove = true

	if p.ptv3.pizzaMobj and p.ptv3.pizzaMobj.valid then
		p.ptv3.pizzaMobj.tracer = p.mo

	end

	local maxMove = 5

	local HFU = FixedDiv(p.ptv3.chasermovetime, maxMove)
	local VFU = FixedDiv(p.ptv3.chaservertmovetime, maxMove)

	local moving, movingv = movement(p, canMove, 25*HFU, 25*VFU)
	
	if moving or movingv then
		p.ptv3.chasermovetime = min(maxMove, $+1)
	else
		p.ptv3.chasermovetime = 0
	end
end

return johnGhost