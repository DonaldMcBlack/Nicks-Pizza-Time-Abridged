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

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	if displayplayer
	and displayplayer.ptv3 
	and displayplayer.ptv3.insecret 
	and not playPizzaTimeMusic()
	and mapmusname ~= "SECRET" then
		mapmusname = "SECRET"
		S_ChangeMusic(mapmusname, true)
	end

	if displayplayer
	and displayplayer.ptv3
	and not displayplayer.ptv3.insecret
	and not playPizzaTimeMusic()
	and mapmusname == "SECRET" then
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
	if gametype == GT_PTV3DM then
		if not PTV3.titlecards[gamemap]
		or leveltime > PTV3.maxTitlecardTime then
			song = "AOTKPS"
		end
	end
	if PTV3.overtime then
		song = "OVRTIM"
		loop = false
	elseif p.ptv3.extreme then
		song = "ACFTQ"
	end

	if mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end
end)