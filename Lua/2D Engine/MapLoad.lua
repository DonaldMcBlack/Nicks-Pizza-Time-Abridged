local maps = {
	lobby = dofile "2D Engine/Maps/Lobby"
}

local tiles = {Placeholder = {}}
for y = 0,(640/32)-1 do
	for x = 0,(640/32)-1 do
		tiles.Placeholder[#tiles.Placeholder+1] = {
			x = x*32,
			y = y*32,
			w = 32,
			h = 32
		}
	end
end
print(#tiles.Placeholder)

function PTV3_2D:returnTilePos(y, x)
	if not (self.map.tiles[y] and self.map.tiles[y][x]) then return end
	
	local tile = self.map.tiles[y][x]

	local x = x*(32*FU)
	local y = y*(32*FU)
	local w = tile.w*FU
	local h = tile.h*FU

	return x,y,w,h
end

local loadTypes = {}

function loadTypes:tilelayer(loadedMap, l)
	local width = loadedMap.width
	for k,i in ipairs(l.data) do
		if i == 0 then continue end

		local x = k-1
		local y = 0

		while x >= width do
			x = $-width
			y = $+1
		end

		self.map.tiles[y] = $ or {}
		self.map.tiles[y][x] = tiles.Placeholder[i]
	end
end

local objectTypes = {}
objectTypes["playerSpawn"] = function(self, obj)
	self.map.spawn = {
		x = obj.x*FU,
		y = (obj.y-64)*FU,
		w = obj.width*FU,
		h = obj.height*FU
	}
end
objectTypes["gateSpawn"] = function(self, obj)
	PTV3_2D:newObject("voteGate", obj.x*FU, obj.y*FU)
end
objectTypes["collision"] = function(self, obj)
	table.insert(self.map.blocks, {
		x = obj.x*FU,
		y = obj.y*FU,
		width = obj.width*FU,
		height = obj.height*FU
	})
end

function loadTypes:objectgroup(loadedMap, l)
	for _,obj in pairs(l.objects) do
		objectTypes[obj.name](self, obj)
	end
end

function PTV3_2D:loadMap(mapName)
	if not maps[mapName] then return end

	self.map = {
		tiles = {},
		blocks = {}
	}

	local loadedMap = maps[mapName]

	local width = loadedMap.width

	for _,l in pairs(loadedMap.layers) do
		loadTypes[l.type](self, loadedMap, l)
	end
end