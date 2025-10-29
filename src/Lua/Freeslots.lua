sfxinfo[freeslot("sfx_winer")].caption = "You won!"

sfxinfo[freeslot "sfx_wartim"].caption = "Beep!"
sfxinfo[freeslot "sfx_timexp"].caption = "BOOM!"
sfxinfo[freeslot "sfx_doorsh"].caption = "SLAM!"

--- PIZZAFACE /// -----------------------------------------------
freeslot("MT_PTV3_PIZZAFACE",
	"SPR_PZAT",
	"SPR_PZTL",
	"SPR_PZAR",
	"SPR_PZHY",
	"SPR_PZLH",
	"SPR_PZHW",
	"SPR_PZAK",
	"S_PTV3_PIZZAFACE",
	"S_PTV3_PIZZAMAD",
	"S_PTV3_PIZZATROLL",
	"S_PTV3_PIZZAHAPPY",
	"S_PTV3_PIZZALAUGHING",
	"S_PTV3_PIZZAHAYWIRE",
	"S_PTV3_PIZZAFACE_SUMMON1", "S_PTV3_PIZZAFACE_SUMMON2", "S_PTV3_PIZZAFACE_SUMMON3",
	"S_PTV3_PIZZARAM",
	"sfx_pflgh",
	"sfx_fplgh",
	"sfx_pizmov",
	"sfx_promov"
)

sfxinfo[sfx_pflgh].caption = "Pizzaface is coming..."
sfxinfo[sfx_fplgh].caption = "Is that the...Pizzaface?"
sfxinfo[sfx_pizmov] = {
	flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
	caption = "Pizzaface is near..."
}

sfxinfo[sfx_promov] = {
	flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
	caption = "Protoface is near..."
}

mobjinfo[MT_PTV3_PIZZAFACE] = {
	doomednum = -1,
	spawnstate = S_PTV3_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 60*FU,
	height = 60*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_PIZZAFACE] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = P,
    var2 = 2,
    nextstate = S_PTV3_PIZZAFACE
}

states[S_PTV3_PIZZALAUGHING] = {
	sprite = SPR_PZLH,
	frame = FF_ANIMATE|A,
	tics = -1,
	action = nil,
	var1 = 3,
	var2 = 2,
	nextstate = S_PTV3_PIZZALAUGHING
}

states[S_PTV3_PIZZAMAD] = {
	sprite = SPR_PZAR,
	frame = FF_ANIMATE|A,
	tics = -1,
	action = nil,
	var1 = 10,
	var2 = 2,
	nextstate = S_PTV3_PIZZAMAD
}

states[S_PTV3_PIZZATROLL] = {
	sprite = SPR_PZTL,
	frame = A,
	action = nil,
	tics = -1,
	nextstate = S_PTV3_PIZZATROLL
}

states[S_PTV3_PIZZAHAPPY] = {
	sprite = SPR_PZHY,
	frame = FF_ANIMATE|A,
	action = nil,
	tics = -1,
	var1 = 17,
	var2 = 2,
	nextstate = S_PTV3_PIZZAHAPPY
}

states[S_PTV3_PIZZAHAYWIRE] = {
	sprite = SPR_PZHW,
	frame = FF_ANIMATE|A,
	action = nil,
	tics = -1,
	var1 = 7,
	var2 = 2,
	nextstate = S_PTV3_PIZZAHAYWIRE
}

states[S_PTV3_PIZZAFACE_SUMMON1] = {
	sprite = SPR_PZSN,
	frame = FF_ANIMATE|A,
	action = nil,
	tics = TICRATE,
	var1 = 7,
	var2 = 2,
	nextstate = S_PTV3_PIZZAFACE_SUMMON2
}

states[S_PTV3_PIZZAFACE_SUMMON2] = {
	sprite = SPR_PZSN,
	frame = H,
	action = function(pf) P_SpawnMobjFromMobj(pf, 0, 0, 0, PTV3.enemylist[P_RandomRange(0, #PTV3.enemylist)]) end,
	tics = 1,
	var1 = 0,
	var2 = 0,
	nextstate = S_PTV3_PIZZAFACE_SUMMON3
}

states[S_PTV3_PIZZAFACE_SUMMON3] = {
	sprite = SPR_PZSN,
	frame = FF_ANIMATE|I,
	action = nil,
	tics = TICRATE,
	var1 = 4,
	var2 = 2,
	nextstate = S_PTV3_PIZZAFACE
}

--- SNICK /// -----------------------------------------------
freeslot("MT_PTV3_SNICK",
	"SPR_SNOR",
	"SPR_SLUN",
	"S_PTV3_SNICK",
	"S_PTV3_SNICK_LUNGE"
)

mobjinfo[MT_PTV3_SNICK] = {
	doomednum = -1,
	spawnstate = S_PTV3_SNICK,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_SNICK] = {
    sprite = SPR_SNOR,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 2,
    var2 = 2,
    nextstate = S_PTV3_SNICK
}

states[S_PTV3_SNICK_LUNGE] = {
    sprite = SPR_SLUN,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 3,
    var2 = 2,
    nextstate = S_PTV3_SNICK_LUNGE
}

--- JOHN GHOST /// -----------------------------------------------
freeslot(
    "MT_PTV3_JOHNGHOST",
    "S_PTV3_JOHNGHOST",
	"S_PTV3_JONATHANPHANTOM",
    "SPR_JNGT",
	"SPR_JNPM",
    "sfx_jghtsp",
    "sfx_jghtct",
	"sfx_jphmsp"
)
sfxinfo[sfx_jghtsp] = {
    flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
    caption = "John's ghost haunts you..."
}

sfxinfo[sfx_jphmsp] = {
	flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND,
	caption = "Something is wrong with John..."
}

sfxinfo[sfx_jghtct].caption = "John yells"

mobjinfo[MT_PTV3_JOHNGHOST] = {
	doomednum = -1,
	spawnstate = S_PTV3_JOHNGHOST,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 60*FU,
	height = 100*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_JOHNGHOST] = {
    sprite = SPR_JNGT,
    frame = FF_ANIMATE|A|FF_TRANS30,
    tics = -1,
    action = nil,
    var1 = 7,
    var2 = 2,
    nextstate = S_PTV3_JOHNGHOST
}

states[S_PTV3_JONATHANPHANTOM] = {
	sprite = SPR_JNPM,
	frame = FF_ANIMATE|A|FF_TRANS30|FF_SUBTRACT,
	tics = -1,
	action = nil,
	var1 = 7,
	var2 = 2,
	nextstate = S_PTV3_JONATHANPHANTOM
}