freeslot("MT_PIZZATOWER_EXITSIGN_SPAWN")
freeslot("MT_PIZZATOWER_EXITSIGN")
freeslot("SPR_GSSE")
freeslot("S_EXITSPAWN_PLACEHOLDER")

mobjinfo[MT_PIZZATOWER_EXITSIGN_SPAWN] = {
	--$Name "Exit Sign Spawn"
    --$Category "PTV3A"
	--$Sprite GSSEA0
	--$Color 17
	--$Angled
	doomednum = 1263, //1-26-[202]3
	spawnstate = S_EXITSPAWN_PLACEHOLDER,
	spawnhealth = 1000,
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

mobjinfo[MT_PIZZATOWER_EXITSIGN] = {
	doomednum = -1,
	spawnstate = S_EXITSPAWN_PLACEHOLDER,
	spawnhealth = 1000,
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

states[S_EXITSPAWN_PLACEHOLDER] = {
	sprite = SPR_GSSE,
	frame = A,
	tics = -1,
}

freeslot("S_GUSTAVO_EXIT_WAIT")
freeslot("S_GUSTAVO_EXIT_FALL")
freeslot("SPR_GESF")
freeslot("S_GUSTAVO_EXIT_RALLY")
freeslot("SPR_GESR")
freeslot("S_GUSTAVO_ICE_RALLY")
freeslot("SPR_GESI")
freeslot("S_GUSTAVO_RAT_FALL")
freeslot("SPR_GERF")
freeslot("S_GUSTAVO_RAT_RALLY")
freeslot("SPR_GERR")

states[S_GUSTAVO_EXIT_WAIT] = {
	sprite = SPR_RING,
	frame = A,
	tics = -1,
}
states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_EXIT_RALLY] = {
	sprite = SPR_GESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

states[S_GUSTAVO_ICE_RALLY] = {
	sprite = SPR_GESI,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 1,
	tics = -1,
}

states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_RAT_FALL] = {
	sprite = SPR_GERF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	tics = -1,
}
states[S_GUSTAVO_RAT_RALLY] = {
	sprite = SPR_GERR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

freeslot("S_STICK_EXIT_WAIT")
freeslot("S_STICK_EXIT_FALL")
freeslot("SPR_SESF")
freeslot("S_STICK_EXIT_RALLY")
freeslot("SPR_SESR")

states[S_STICK_EXIT_WAIT] = {
	sprite = SPR_THOK,
	frame = A,
	tics = -1,
}
states[S_STICK_EXIT_FALL] = {
	sprite = SPR_SESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_STICK_EXIT_RALLY] = {
	sprite = SPR_SESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 6-1,
	var2 = 2,
	tics = -1,
}

local isIcy = false
local dist = 1500

-- Insert skins here. (CURRENTLY BETA)
PTV3.exitSigns = {
	{
		name = 'Gustavo',
		radius = 14*FU,
		height = 26*FU,
		skins = {
			['Default'] = { waitstate = S_GUSTAVO_EXIT_WAIT, fallstate = S_GUSTAVO_EXIT_FALL, rallystate = S_GUSTAVO_EXIT_RALLY },
			['Freezy'] = { waitstate = S_GUSTAVO_EXIT_WAIT, fallstate = S_GUSTAVO_ICE_RALLY, rallystate = S_GUSTAVO_ICE_RALLY },
			['Hardoween'] = { waitstate = S_GUSTAVO_EXIT_WAIT, fallstate = S_GUSTAVO_RAT_FALL, rallystate = S_GUSTAVO_RAT_RALLY }
		}
	},
	{
		name = "Mr Stick",
		radius = 10*FU,
		height = 32*FU,
		skins = {
			['Default'] = { waitstate = S_STICK_EXIT_WAIT, fallstate = S_STICK_EXIT_FALL, rallystate = S_STICK_EXIT_RALLY }
		}
	}
}

addHook("NetVars",function(n)
	isIcy = n($)
	PTV3.exitSigns = n($)
end)

local function isIcyF(map)
	if (mapheaderinfo[map] == nil) then
		return false;
	end
	
	// https://wiki.srb2.org/wiki/Flats_and_textures/Skies
	if (mapheaderinfo[map].skynum == 17
	or mapheaderinfo[map].skynum == 29
	or mapheaderinfo[map].skynum == 30
	or mapheaderinfo[map].skynum == 107
	or mapheaderinfo[map].skynum == 55) then
		return true;
	end

	if (mapheaderinfo[map].musname == "MP_ICE"
	or mapheaderinfo[map].musname == "FHZ"
	or mapheaderinfo[map].musname == "CCZ") then
		// ice music
		return true;
	end
	
	//time to bust out the thesaurus!
	local icywords = {
		"frozen",
		"christmas",
		"ice",
		"icy",
		"icicle",
		"blizzard",
		"snow",
		"snowstorm",
		"frost",
		"winter",
		"chilly",
		"frigid",
		"artic",
		"polar",
		"glacial",
		"glacier",
		"wintery",
		"subzero",
		"tundra",
		"snowcap",
		"icecap",
	};

	local stageName = string.lower(mapheaderinfo[map].lvlttl);
	for i = 1,#icywords do
		if (string.find(stageName, icywords[i]) ~= nil) then
			-- Has a very distinctly desert word in its title
			return true;
		end
	end

	return false;

end

-- Change states without the change overlapping the state being used.
local function SwitchState(mo, oldstate, newstate)
	if oldstate == newstate then return end
	mo.state = newstate
end

addHook("MapLoad",function(mapid)
	isIcy = isIcyF(mapid)
end)
addHook("MapThingSpawn",function(mo,mt)
	//we dont wanna see EXIT pop up from no where
	//looks like an ERROR in a source game!
	mo.flags2 = $|MF2_DONTDRAW

	-- local sector = mo.subsector.sector
	-- local fof = mo.ceilingrover

	-- if fof then
	-- 	for s in sector.ffloors() do
	-- 		if s.bottomheight > mo.floorz then 
	-- 			sector = s.sector

	-- 			break
	-- 		end
	-- 	end
	-- else

	-- end
	
	if PTV3:isPTV3() then
		local mul = 14
		
		local exitsign = PTV3.exitSigns[P_RandomRange(1, #PTV3.exitSigns)]

		if exitsign and exitsign.name ~= nil then
			local sign = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul), MT_PIZZATOWER_EXITSIGN)
			if isIcy and exitsign.skins['Freezy'] then
				sign.costume = exitsign.skins['Freezy']
			elseif gamemap == A5 and exitsign.skins['Hardoween'] then
				sign.costume = exitsign.skins['Hardoween']
			else
				sign.costume = exitsign.skins['Default']
			end

			sign.radius = exitsign.radius
			sign.height = exitsign.height
			sign.state = sign.costume.waitstate
			sign.angle = mo.angle
			sign.tracer = mo
			return true
		end
	end
	return true
end, MT_PIZZATOWER_EXITSIGN_SPAWN)

local function ExitSignThinker(mo)
	if not mo or not mo.valid then return end
	if not PTV3 then return end

	local grounded = P_IsObjectOnGround(mo)
	mo.angle = mo.tracer.angle

	if mo.state == mo.costume.waitstate
	and not mo.alreadyfell then
		mo.flags2 = $|MF2_DONTDRAW
		mo.flags = $|MF_NOGRAVITY

		if PTV3.pizzatime or PTV3.minusworld then
			local px = mo.x
			local py = mo.y
			local br = dist*mo.scale

			searchBlockmap("objects", function(mo, found)
				if found and found.valid
				and found.health
				and found.player
				and (P_CheckSight(mo,found)) then
					mo.state = mo.costume.fallstate
					mo.alreadyfell = true
				end
			end, mo, px-br, px+br, py-br, py+br)
		end
	else
		mo.flags2 = $ &~MF2_DONTDRAW
		mo.flags = $ &~MF_NOGRAVITY
		if grounded then
			SwitchState(mo, mo.state, mo.costume.rallystate)
		else
			SwitchState(mo, mo.state, mo.costume.fallstate)
		end
	end
end

addHook("MobjThinker", ExitSignThinker, MT_PIZZATOWER_EXITSIGN)