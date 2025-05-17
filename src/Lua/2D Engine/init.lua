local _dofile = dofile
local function dofile(file)
	return _dofile("2D Engine/"..file)
end

dofile "Variables"
dofile "Objects/init"
dofile "MapLoad"
dofile "Ingame"
dofile "Renderer"