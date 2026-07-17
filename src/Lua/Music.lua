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
	if not PTV3:isPTV3() then return end
	if not (displayplayer and displayplayer.PTRound) then return end
	if gametype ~= GT_PTV3DM and not PTV3.pizzatime then return end
	if PTV3.has_titlecard and leveltime < PTV3.maxTitlecardTime then return end

	return true
end

local usesongs = CV_RegisterVar({
	name = "PTV3_customsongs",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})

local function SwitchLapMusic(lap, list)
	if lap == 0 then return end
	if lap < -6 or lap > 6 then return end
	return list[lap]
end

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	local data = PTV3:__getsongdata()
	local modsongs = data[skins[displayplayer and displayplayer.skin or "sonic"].name] or data["Default"]
	local secretmusic = modsongs["Secret"] or "SECRET"

	if PTV3.game_over <= PTV3.ranktransitiontime then
		S_ChangeMusic(displayplayer.PTRound.specforce and "ERANK" or PTV3.ranks[displayplayer.PTRound.rank].music, false, displayplayer)
		return
	end

	if displayplayer and displayplayer.PTRound and not playPizzaTimeMusic() then
		if PTV3.has_titlecard and leveltime <= PTV3.maxTitlecardTime then

			local mapTM = mapheaderinfo[gamemap].keywords.."TM"

			if leveltime < PTV3.maxTitlecardTime
			and mapmusname ~= mapTM then
				mapmusname = mapTM
				S_ChangeMusic(mapmusname, false)
			end
		
			if leveltime == PTV3.maxTitlecardTime
			and mapmusname == mapTM then
				mapmusname = mapheaderinfo[gamemap].musname
				S_ChangeMusic(mapmusname, true)
			end
		end

		if displayplayer.PTRound.insecret and mapmusname ~= secretmusic then
			mapmusname = secretmusic
			S_ChangeMusic(mapmusname, true)
		end

		if not displayplayer.PTRound.insecret and mapmusname == secretmusic then
			mapmusname = mapheaderinfo[gamemap].musname
			S_ChangeMusic(mapmusname, true)
		end
	end

	if not playPizzaTimeMusic() then return end
	local loop = true

	if not (displayplayer and displayplayer.PTRound) then return end
	local p = displayplayer
	
	local song = nil


	if #modsongs > 0 and usesongs.value then
		song = SwitchLapMusic(p.PTRound.laps, modsongs)
	else
		song = SwitchLapMusic(p.PTRound.laps, music)
	end

	if gametype == GT_PTV3DM then
		if not PTV3.has_titlecard
		or leveltime > PTV3.maxTitlecardTime then
			song = "AOTKPS"
		end
	end

	if PTV3.extreme then
		if PTV3.pizzaface and PTV3.pizzaface.skindata.extreme_theme then
			song = PTV3.pizzaface.skindata.extreme_theme
		else
			song = "POTMAC"
		end
	end

	if PTV3.overtime then
		local default
		if PTV3.overtime_time > 15*TICRATE then default = "OVRTIA"
		else default = "OVRTIB" end
		
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