local syncedVars = {
	timeLeft = 90*TICRATE,
	waitTime = 2*TICRATE,
	map = {},
	objects = {},
	gates = {},
	selectedMap = 0,
}

function PTV3_2D:playerInit(p)
	p.ptv3_2d = {
		x = self.map.spawn and self.map.spawn.x or 0,
		y = self.map.spawn and self.map.spawn.y or 0,

		width = 32*FU,
		height = 64*FU,

		momx = 0,
		momy = 0,

		dir = 1,
		-- we are gonna be focusing on the physics for the 2d engine that happens during the lobby map
		jumped = false,

		grounded = false,

		running = false,
		machspeed = 0,

		acceltime = 0,

		prevbuttons = 0,
		buttons = 0,
		voted = false,

		display = {
			spr2 = SPR2_STND,
			frame = A,
		},

		camera = {
			x = 0,
			y = 0,
			scale = FU/3
		}
	}
end
local function deepClone(value)
	if type(value) ~= "table" then
		return value
	end

	local newValue = {}
	for k,v in pairs(value) do
		newValue[k] = deepClone(v)
	end

	return newValue
end
function PTV3_2D:init()
	for k,v in pairs(syncedVars) do
		self[k] = deepClone(v)
	end
	if self.loadMap then
		self:loadMap("lobby")
	end
	for p in players.iterate do
		PTV3_2D:playerInit(p)
	end
end

addHook("NetVars", function(n)
	local net = {
		"timeLeft",
		"waitTime",
		"map",
		"objects",
		"gates",
		"selectedMap"
	}
	for k,v in pairs(net) do
		PTV3_2D[v] = n($)
	end
end)

PTV3_2D:init()

addHook("MapChange", do
	PTV3_2D:init()
end)