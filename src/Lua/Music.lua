local music = {
	"PIZTIM",
	"DEAOLI",
	"LAP3LO",
	"FUNFRE"
}

local function playPizzaTimeMusic()
	if not PTV3:isPTV3() then return end
	if not (displayplayer and displayplayer.ptv3) then return end
	if gametype ~= GT_PTV3DM and not PTV3.pizzatime then return end
	if PTV3.titlecards[gamemap] and leveltime < PTV3.maxTitlecardTime then return end

	return true
end

local usesongs = CV_RegisterVar({
	name = "PTV3_customsongs",
	defaultvalue = "Yes",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	local data = PTV3:__getsongdata()
	local modsongs = data[skins[displayplayer and displayplayer.skin or "sonic"].name] or data["Default"]
	local secretmusic = modsongs["Secret"] or "SECRET"

	if displayplayer
	and displayplayer.ptv3 
	and displayplayer.ptv3.insecret 
	and not playPizzaTimeMusic()
	and mapmusname ~= secretmusic then
		mapmusname = secretmusic
		S_ChangeMusic(mapmusname, true)
	end

	if displayplayer
	and displayplayer.ptv3
	and not displayplayer.ptv3.insecret
	and not playPizzaTimeMusic()
	and mapmusname == secretmusic then
		mapmusname = mapheaderinfo[gamemap].musname
		S_ChangeMusic(mapmusname, true)
	end

	if PTV3.titlecards[gamemap] then
		if displayplayer
		and displayplayer.ptv3
		and not playPizzaTimeMusic()
		and leveltime < PTV3.maxTitlecardTime
		and mapmusname ~= PTV3.titlecards[gamemap].m then
			mapmusname = PTV3.titlecards[gamemap].m
			S_ChangeMusic(mapmusname, false)
		end
	
		if displayplayer
		and displayplayer.ptv3
		and not playPizzaTimeMusic()
		and leveltime >= PTV3.maxTitlecardTime
		and mapmusname == PTV3.titlecards[gamemap].m then
			mapmusname = mapheaderinfo[gamemap].musname
			S_ChangeMusic(mapmusname, true)
		end
	end

	if not playPizzaTimeMusic() then return end
	local loop = true

	if not (displayplayer
	and displayplayer.ptv3) then return end
	local p = displayplayer
	
	local song = music[max(1, min(p.ptv3.laps, #music))]

	if #modsongs > 0
	and usesongs.value
	and modsongs[min(p.ptv3.laps, #modsongs)] then
		song = modsongs[min(p.ptv3.laps, #modsongs)]
	end
	if gametype == GT_PTV3DM then
		if not PTV3.titlecards[gamemap]
		or leveltime > PTV3.maxTitlecardTime then
			song = "AOTKPS"
		end
	end
	if PTV3.overtime then
		song = modsongs["Overtime"] or "ACFTQ"
	end

	if mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end
end)