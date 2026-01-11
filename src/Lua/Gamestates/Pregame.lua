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
	for _,i in pairs(PTV3.synced_variables) do
		self[_] = cloneTable(i)
	end

	for _,i in pairs(CV_PTV3) do
		self[_] = i.value
	end

	for p in players.iterate do
		p.ptv3 = nil
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
		a = t.angle*ANG1
	}

	local a = PTV3.spawn.a

	PTV3.spawnGate = R_PointInSubsectorOrNil(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a))) and P_SpawnMobj(PTV3.spawn.x+(-230*cos(a)), PTV3.spawn.y+(-230*sin(a)), PTV3.spawn.z, MT_PTV3_SPAWNGATE) or
												P_SpawnMobj(PTV3.spawn.x, PTV3.spawn.y, PTV3.spawn.z, MT_PTV3_SPAWNGATE)
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
		a = t.angle*ANG1
	}
	PTV3.endsec = sec

	local john = P_SpawnMobj(PTV3.endpos.x, PTV3.endpos.y, PTV3.endpos.z, MT_PTV3_PILLARJOHN)

	john.angle = PTV3.endpos.a
end

local function PreparePizzaTimer(minutes, seconds)
	if not seconds then return end

	PTV3.time = seconds*TICRATE

	if not minutes then return end

	PTV3.time = $+minutes*TICRATE*60
end

addHook('MapLoad', function(map)
	PTV3:init()
	
	for p in players.iterate do
		p.ptv3 = nil
	end

	if not PTV3:isPTV3() then
		hud.enable('lives')
		return
	end

	if gamemap ~= M_MapNumber("PT") then
		hud.enable('time')
	else
		hud.disable('time')
	end
	hud.disable('lives')

	for thing in mapthings.iterate do
		spawnSector(thing)
		endSector(thing)
	end

	PTV3.setJohnBlocks()

	for i, v in ipairs(PTV3.secrets) do
		print(i)
		if PTV3.secrets[i-1] ~= nil and PTV3.secrets[i-1].sgroup == v.sgroup then continue
		else
			PTV3.secret_count = $+1
		end
	end

	print(#PTV3.secrets)
	print(PTV3.secret_count)

	local alive, pizzafaces, total = PTV3.playerCount and PTV3:playerCount()

	PreparePizzaTimer(mapheaderinfo[map].ptv3_pt_mins ~= nil and tonumber(mapheaderinfo[map].ptv3_pt_mins) or CV_PTV3['time'].value, mapheaderinfo[map].ptv3_pt_secs ~= nil and tonumber(mapheaderinfo[map].ptv3_pt_secs) or 1)

	PTV3.overtime_time = multiplayer and (120+29)*TICRATE or TICRATE*60
	PTV3.maxtime = PTV3.time
	PTV3.pftime = 30*TICRATE
	PTV3.maxpftime = PTV3.pftime

	if not titlemapinaction then
		PTV3.skinIndex.pizzaface = P_RandomRange(0, #PTV3_SKINS.pizzaface)
		PTV3.skinIndex.snick = P_RandomRange(0, #PTV3_SKINS.snick)
		PTV3.skinIndex.johnGhost = P_RandomRange(0, #PTV3_SKINS.johnGhost)

		CONS_Printf(consoleplayer, "Pizzaface is... "..PTV3_SKINS.pizzaface[PTV3.skinIndex.pizzaface].name)
		CONS_Printf(consoleplayer, "Snick is... "..PTV3_SKINS.snick[PTV3.skinIndex.snick].name)
		CONS_Printf(consoleplayer, "John is... "..PTV3_SKINS.johnGhost[PTV3.skinIndex.johnGhost].name)
	end
	
	if gametype == GT_PTV3DM
	and not PTV3.has_titlecard then
		PTV3:pizzafaceSpawn()
	end
end)

addHook('MapChange', function()
	PTV3:init()
end)