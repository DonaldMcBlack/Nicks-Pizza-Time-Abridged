local music = {
	[-5] = "INSTNC",
	[-4] = "UNKOWN",
	[-3] = "LAMAER",
	[-2] = "ILOAED",
	[-1] = "ANTIPI",
	[1] = "PIZTIM", -- 6
	[2] = "DEAOLI",
	[3] = "LAP3LO",
	[4] = "FORTHC",
	[5] = "MANIAC", -- 10
}

local muspos = 0

local jingle_blacklist = {
	"_shoes",
	"_inv",
	"_1up",
	"_super"
}

local function playPizzaTimeMusic()
	if gametype ~= GT_PTV3DM and not PTV3.pizzatime then return end
	if leveltime < PTV3.maxTitlecardTime then return end

	return true
end

local usesongs = CV_RegisterVar({
	name = "PTV3_customsongs",
	defaultvalue = "Off",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = CV_OnOff,
	func = function(cv)
		local string = cv.value == 0 and "off" or "on"
		print("Custom lap songs are now "..string..".")
	end
})

local function SwitchLapMusic(lap, list)
	if lap == 0 then return end
	if lap < -6 or lap > 6 then return end
	return list[lap]
end

-- For Titlecards
addHook("PreThinkFrame", function()
	if not PTV3:isPTV3() then return end

	if leveltime > PTV3.maxTitlecardTime or gamemap == M_MapNumber("PT") then return end

	local loop = false
	local mapTM = (mapheaderinfo[gamemap].keywords.."TM")
	mapTM = S_MusicExists($) and $ or "PLACTM"

	loop = leveltime == PTV3.maxTitlecardTime and true or false
	local tune = leveltime < PTV3.maxTitlecardTime and mapTM or mapheaderinfo[gamemap].musname

	S_ChangeMusic(tune, loop)
end)

-- For everything past the titlecards
addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	local p = (displayplayer and displayplayer.valid) and displayplayer or nil

	if not p then return end

	local data = PTV3:__getsongdata()
	local modsongs = data[skins[p and p.skin or "sonic"].name] or data["Default"]
	local secretmusic = modsongs["Secret"] or "SECRET"
	local loop = true

	if PTV3.game_over > PTV3.ranktransitiontime then
		S_ChangeMusic(p.PTRound.specforce and "ERANK" or PTV3.ranks[p.PTRound.rank].music, false, p, nil, 0)
		return
	end

	if PTV3.game_over then
		if PTV3.extreme then S_ChangeMusic("POTEND", false, p)
		else S_StopMusic(p) end
	end

	if leveltime <= PTV3.maxTitlecardTime then return end

	if (PTV3.pillarJohn and PTV3.pillarJohn.valid) and (p.mo and p.mo.valid) then
		local dist_from_john = R_PointToDist2(0, 0, R_PointToDist2(p.mo.x, p.mo.y, PTV3.pillarJohn.x, PTV3.pillarJohn.y), p.mo.z-PTV3.pillarJohn.z)
		mapmusname = dist_from_john < 4000*FU and "MEATO" or mapheaderinfo[gamemap].musname
	end

	if not playPizzaTimeMusic() then
		mapmusname = (p.PTRound.insecret and mapmusname ~= secretmusic) and secretmusic or (not p.PTRound.insecret and mapmusname == secretmusic) and mapheaderinfo[gamemap].musname or $
		S_ChangeMusic(mapmusname, loop)
		return
	end

	local song = nil

	if gametype == GT_PTV3DM then
		if leveltime > PTV3.maxTitlecardTime then
			song = "AOTKPS"
		end
	else
		song = SwitchLapMusic(p.PTRound.laps, (#modsongs > 0 and usesongs.value) and modsongs or music)
	end

	if PTV3.extreme then
		song = PTV3.pizzaface and PTV3.pizzaface.skindata.extreme_theme or "POTMAC"
	end

	if PTV3.overtime then
		local default = PTV3.overtime_time > 15*TICRATE and "OVRTIA" or "OVRTIB"
		song = modsongs["Overtime"] or default
	end

	for _, jing in pairs(jingle_blacklist) do
		if jing == S_MusicName(p) then S_ChangeMusic(mapmusname, loop, p, 0, muspos) break end
	end

	if song and mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end

	muspos = S_GetMusicPosition()
end)