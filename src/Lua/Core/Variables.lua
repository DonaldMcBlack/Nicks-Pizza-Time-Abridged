-- Command Variables
CV_PTV3['time'] = CV_RegisterVar({
	name = "PTV3_time",
	defaultvalue = 5,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_laps'] = CV_RegisterVar({
	name = "PTV3_laps",
	defaultvalue = 5,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_elaps'] = CV_RegisterVar({
	name = "PTV3_extreme_laps",
	defaultvalue = 7,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_erings'] = CV_RegisterVar({
	name = "PTV3_max_erings",
	defaultvalue = 60,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['ai_pizzaface'] = CV_RegisterVar({
	name = "PTV3_ai_pizzaface",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})
CV_PTV3['time_for_pizzaface_ai'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_ai",
	defaultvalue = 120+30,
	flags = CV_NETVAR,
})
CV_PTV3['time_for_pizzaface_player'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_player",
	defaultvalue = 10,
	flags = CV_NETVAR,
})

-- vars
PTV3.maxTitlecardTime = 3*TICRATE

PTV3.synced_variables = {
	['pizzatime'] = 0,
	['total_laps'] = 1,
	['spawn'] = {x=0,y=0,z=0},
	['endpos'] = {x=0,y=0,z=0,a=0},
	['tplist'] = {mobjteleport = {mo=nil, coords=nil,relative=false}},
	['endsec'] = false,
	['lapPortal'] = false,
	['pillarJohn'] = false,
	['spawnsector'] = false,
	['endtime'] = -1,
	['extreme'] = false,
	['skybox'] = false,
	['shakeintensity'] = 0,
	['currentchasers'] = {},
	['pizzaface'] = false,
	['snick'] = false,
	['johnGhost'] = false,
	['skinIndex'] = { pizzaface = 0, snick = 0, johnGhost = 0 },
	['wartimer'] = false,
	['wartimerStart'] = 0,
	['overtime'] = false,
	['overtimeStart'] = 0,
	['pizzafacetps'] = {},
	['pizzaposts'] = {},
	['time'] = 600*TICRATE,
	['maxtime'] = 600*TICRATE,
	['votetime'] = 5*TICRATE,
	['pftime'] = 30*TICRATE,
	['spawnGate'] = false,
	['__fadedmus'] = false,
	['overtime_time'] = TICRATE,
	['maxottime'] = 60*TICRATE,
	['overtime_elapser'] = 1,
	['secret_count'] = 0,
 	['game_over'] = 0, --- (21*TICRATE)-10 = 200
	['ranktransitiontime'] = 6*TICRATE,
	['maxrankrequirement'] = 1500,
	['starttime_pizzatime'] = -1,
	['highestlap'] = 0,
	['matchLog'] = {},
	['titlecard_bg'] = nil,
	['titlecard_name'] = nil,

	-- not net
	['hud_lap'] = -1,
	['hud_secret'] = -1
}

--- Enemies Pizzaface can spawn go here.
PTV3.enemylist = {
	MT_BLUECRAWLA,
	MT_REDCRAWLA,
	-- MT_GFZFISH,
	MT_GOLDBUZZ,
	MT_REDBUZZ,
	MT_JETTBOMBER,
	MT_JETTGUNNER,
	MT_CRAWLACOMMANDER,
	MT_DETON,
	-- MT_SKIM,
	-- MT_TURRET,
	-- MT_POPUPTURRET,
	MT_SPINCUSHION,
	MT_CRUSHSTACEAN,
	MT_BANPYURA,
	MT_BANPSPRING,
	MT_JETJAW,
	MT_SNAILER,
	MT_VULTURE,
	MT_POINTY,
	MT_ROBOHOOD,
	MT_FACESTABBER,
	MT_EGGGUARD,
	MT_GSNAPPER,
	MT_MINUS,
	MT_SPRINGSHELL,
	MT_YELLOWSHELL,
	MT_UNIDUS,
	MT_CANARIVORE,
	MT_PYREFLY,
	MT_PTERABYTE,
	MT_DRAGONBOMBER,
	MT_PENGUINATOR,
	MT_POPHAT,
	MT_HIVEELEMENTAL,
	MT_BUMBLEBORE,
	MT_SPINBOBERT,
	-- MT_HANGSTER
}

-- hooks
addHook('NetVars', function(n)
	local net = {
		"pizzatime",
		"total_laps",
		"spawn",
		"endpos",
		"tplist",
		"endsec",
		"lapPortal",
		"pillarJohn",
		"spawnsector",
		"endtime",
		"extreme",
		"skybox",
		"shakeintensity",
		"currentchasers",
		"pizzaface",
		"snick",
		"johnGhost",
		"skinIndex",
		"wartimer",
		"wartimerStart",
		"overtime",
		"overtimeStart",
		"pizzafacetps",
		"pizzaposts",
		"time",
		"maxtime",
		"votetime",
		"pftime",
		"maxpftime",
		"spawnGate",
		"max_laps",
		"max_elaps",
		"__fadedmus",
		"overtime_time",
		"maxottime",
		"overtime_elapser",
		"secret_count",
		"game_over",
		"ranktransitiontime",
		"maxrankrequirement",
		"starttime_pizzatime",
		"highestlap",
		"matchLog",
		"titlecard_bg",
		"titlecard_name",

		"time",
		"max_laps",
		"max_elaps",
		"max_erings",
		"ai_pizzaface",
		"time_for_pizzaface_ai",
		"time_for_pizzaface_player",
	}

	for _,i in pairs(net) do
		PTV3[i] = n($)
	end
end)