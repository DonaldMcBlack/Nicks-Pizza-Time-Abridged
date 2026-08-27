local function cloneTable(table)
	if type(table) ~= "table" then
		return table
	end

	local clone = {}

	for k,v in pairs(table) do
		if type(table) == "table" then
			clone[k] = cloneTable(v)
			continue
		end

		clone[k] = v
	end

	return clone
end

function PTV3:init()
	-- if not PTV3:isPTV3() then return end
	
	hud.disable("stagetitle")
	
	for _,i in pairs(PTV3.synced_variables) do
		self[_] = cloneTable(i)
	end

	for _,i in pairs(CV_PTV3) do
		self[_] = i.value
	end
	
	if PTV3.callbacks then
		PTV3.callbacks('VariableInit')
	end
end

local function spawnSector(t)
	if t.type ~= 1 then return end

	local sec = R_PointInSubsector(t.x*FU, t.y*FU).sector

	PTV3.spawn = {
		x = t.x*FU,
		y = t.y*FU,
		z = sec.floorheight + (t.z*FU),
		angle = t.angle*ANG1
	}

	local a = PTV3.spawn.angle

	PTV3.spawnGate = R_PointInSubsectorOrNil(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a))) and 
					 P_SpawnMobj(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a)), PTV3.spawn.z, MT_PTV3_SPAWNGATE) or P_SpawnMobj(PTV3.spawn.x, PTV3.spawn.y, PTV3.spawn.z, MT_PTV3_SPAWNGATE)
	PTV3.spawnGate.angle = a

	PTV3.spawnsector = sec
end
local function endSector(t)
	if t.type ~= 501 then return end

	local sec = R_PointInSubsector(t.x*FU, t.y*FU).sector

	PTV3.endpos = {
		x = t.x*FU,
		y = t.y*FU,
		z = sec.floorheight + (t.z*FU),
		angle = t.angle*ANG1
	}
	PTV3.endsec = sec

	local john = P_SpawnMobj(PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z, MT_PTV3_PILLARJOHN)

	john.angle = PTV3.endpos.angle
end

local function PrepareTimer(minutes, seconds)

	local timer = 0

	timer = seconds and seconds*TICRATE or 0

	timer = minutes and $+minutes*TICRATE*60 or 0

	return timer
end

addHook('MapLoad', function(map)
	if titlemapinaction then return end
	PTV3:init()

	for thing in mapthings.iterate do
		spawnSector(thing)
		endSector(thing)
	end

	PTV3.setJohnBlocks()

	for i, v in ipairs(PTV3.secrets) do
		if not v.valid or PTV3.secrets[i-1] ~= nil and PTV3.secrets[i-1].sgroup == v.sgroup then continue
		else
			PTV3.secret_count = $+1
		end
	end
	print("There are... "..PTV3.secret_count.." secrets.")
	print("Level Gates: "..#PTV3_HUB.gates)

	for player in players.iterate do
		PTV3:InitPlayerChecks(player, true)
	end

	local minutes = mapheaderinfo[map].ptv3_pt_mins ~= nil and tonumber(mapheaderinfo[map].ptv3_pt_mins) or CV_PTV3['time'].value
	local seconds = mapheaderinfo[map].ptv3_pt_secs ~= nil and tonumber(mapheaderinfo[map].ptv3_pt_secs) or 1
	PTV3.time = PrepareTimer(minutes, seconds)

	minutes = mapheaderinfo[map].ptv3_ot_mins ~= nil and tonumber(mapheaderinfo[map].ptv3_ot_mins) or 1
	seconds = mapheaderinfo[map].ptv3_ot_secs ~= nil and tonumber(mapheaderinfo[map].ptv3_ot_secs) or 0
	PTV3.overtime_time = PrepareTimer(minutes, seconds)

	PTV3.maxtime = PTV3.time
	PTV3.maxottime = PTV3.overtime_time
	PTV3.pftime = 30*TICRATE
	PTV3.maxpftime = PTV3.pftime
	
	-- PTV3.skinIndex.pizzaface = P_RandomRange(0, #PTV3_SKINS.pizzaface)
	-- PTV3.skinIndex.snick = P_RandomRange(0, #PTV3_SKINS.snick)
	-- PTV3.skinIndex.johnGhost = P_RandomRange(0, #PTV3_SKINS.johnGhost)

	-- print("Pizzaface is... "..PTV3_SKINS.pizzaface[PTV3.skinIndex.pizzaface].name)
	-- print("Snick is... "..PTV3_SKINS.snick[PTV3.skinIndex.snick].name)
	-- print("John is... "..PTV3_SKINS.johnGhost[PTV3.skinIndex.johnGhost].name)
end)

addHook('MapChange', function()
	PTV3:init()
	
	for _, v in ipairs(PTV3.secrets) do
		PTV3.secrets[_] = nil
	end
end)