return function(v,p)
    if not p.ptv3 then return end
    if not p.ptv3.menumode.inmenu or p.ptv3.menumode.menutype ~= "dresser" then return end

    v.drawFill(nil, nil, nil, nil, 0)
end