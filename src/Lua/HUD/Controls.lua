return function(v,p)
	if not PTV3:isPTV3() then return end
	if not (p and p.ptv3 and p.ptv3.chaser) then return end

	local time = FixedDiv(max(0, min(PTV3.maxpftime-PTV3.pftime, 2*TICRATE)), 2*TICRATE)
	local endtime = FixedDiv(max(0, min(PTV3.pftime, 2*TICRATE)), 2*TICRATE)

	local startTween = ease.linear(time, 200*FU, 180*FU)
	local endTween = ease.linear(FU-endtime, 180*FU, 200*FU)

	local y = max(startTween, endTween)

	v.drawString(160*FU, y, "Fire = Dash", V_SNAPTOBOTTOM, "fixed-center")
end