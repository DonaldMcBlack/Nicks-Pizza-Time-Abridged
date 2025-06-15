local gate = {}

local function isColliding(x,y,w,h, x2,y2,w2,h2)
	return (x < x2+w2
	and x2 < x+w
	and y < y2+h2
	and y2 < y+h)
end

function gate:spawn(x, y)
	self.width = 125*FU
	self.height = 180*FU
	self.x = x-(self.width/2)
	self.y = y-self.height
	self.sprite = SPR_EXGA
	self.frame = B
	self.votes = 0

	self.map = 0

	local mapsChosen = {}
	local foundMaps = {}
	local hasChosenMap = false


	for map = 1,1035 do
		local data = mapheaderinfo[map]
	
		if data
		and data.typeoflevel & TOL_COOP
		and data.bonustype <= 0 then
			table.insert(foundMaps, map)
		end
	end

	for _,gate in pairs(PTV3_2D.gates) do
		mapsChosen[gate.map] = true
	end

	while not hasChosenMap do
		local map = foundMaps[P_RandomRange(1,#foundMaps)]
		if not mapsChosen[map] then
			hasChosenMap = true
			self.map = map
		end
	end

	table.insert(PTV3_2D.gates, self)
end

function gate:think()
	for p in players.iterate do
		if not (p and p.ptv3_2d) then continue end

		local p2d = p.ptv3_2d

		if not isColliding(p2d.x,p2d.y,p2d.width,p2d.height, self.x,self.y,self.width,self.height) then
			continue
		end

		if p2d.forwardmove > 30
		and p2d.voted ~= self then
			self.votes = $+1
			if p2d.voted then
				p2d.voted.votes = $-1
			end
			p2d.voted = self
			S_StartSound(nil, sfx_itemup, p)
		end
	end
end

function gate:draw(v, dh)
	local sprite = v.getSpritePatch(self.sprite, self.frame, 0)
	local sx = self.x+(self.width/2)
	dh:drawScaled(v, sx, self.y+self.height, FU, sprite)
	dh:drawString(v,
		self.x+(self.width/2),
		self.y-(32*FU),
		FU,
		G_BuildMapTitle(self.map),
		"center",
		"PTFNT"
	)
	dh:drawString(v,
		self.x+(self.width/2),
		self.y-(70*FU),
		FU,
		tostring(self.votes),
		"center",
		"PTFNT"
	)
end

return gate