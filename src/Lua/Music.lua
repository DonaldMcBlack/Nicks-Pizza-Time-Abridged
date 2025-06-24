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

local function playPizzaTimeMusic()
	if not PTV3:isPTV3() then return end
	if not (displayplayer and displayplayer.ptv3) then return end
	if gametype ~= GT_PTV3DM and not (PTV3.pizzatime or PTV3.minusworld) then return end
	if PTV3.titlecards[gamemap] and leveltime < PTV3.maxTitlecardTime then return end

	return true
end

local usesongs = CV_RegisterVar({
	name = "PTV3_customsongs",
	defaultvalue = "Yes",
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

	if displayplayer and displayplayer.ptv3 and not playPizzaTimeMusic() then
		if displayplayer.ptv3.insecret and mapmusname ~= secretmusic then
			mapmusname = secretmusic
			S_ChangeMusic(mapmusname, true)
		end

		if not displayplayer.ptv3.insecret and mapmusname == secretmusic then
			mapmusname = mapheaderinfo[gamemap].musname
			S_ChangeMusic(mapmusname, true)
		end

		if PTV3.titlecards[gamemap] then
			if leveltime < PTV3.maxTitlecardTime
			and mapmusname ~= PTV3.titlecards[gamemap].m then
				mapmusname = PTV3.titlecards[gamemap].m
				S_ChangeMusic(mapmusname, false)
			end
		
			if leveltime >= PTV3.maxTitlecardTime
			and mapmusname == PTV3.titlecards[gamemap].m then
				mapmusname = mapheaderinfo[gamemap].musname
				S_ChangeMusic(mapmusname, true)
			end
		end
	end

	if not playPizzaTimeMusic() then return end
	local loop = true

	if not (displayplayer and displayplayer.ptv3) then return end
	local p = displayplayer
	
	local song = nil


	if #modsongs > 0 and usesongs.value then
		song = SwitchLapMusic(p.ptv3.laps, modsongs)
	else
		song = SwitchLapMusic(p.ptv3.laps, music)
	end

	if gametype == GT_PTV3DM then
		if not PTV3.titlecards[gamemap]
		or leveltime > PTV3.maxTitlecardTime then
			song = "AOTKPS"
		end
	end

	if PTV3.extreme then
		song = "POTMAC"
	end

	if PTV3.overtime then
		song = modsongs["Overtime"] or "ACFTQ"
	end

	if song and mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end
end)