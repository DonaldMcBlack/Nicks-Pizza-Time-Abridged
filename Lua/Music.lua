local music = {
	minus = { "ANTIPI", "ILOAED", "LAMAER", "UNKOWN", "INSTNC" },
	plus = { "PIZTIM", "DEAOLI", "LAP3LO", "FORTHC", "MANIAC"},
	"POTMAC"
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

	-- For Secrets
	if displayplayer and displayplayer.ptv3 then

		if displayplayer.ptv3.insecret and not playPizzaTimeMusic()
		and mapmusname ~= "SECRET" then -- Secret music should play in a secret
			mapmusname = "SECRET"
			S_ChangeMusic(mapmusname, true)
		end

		if not displayplayer.ptv3.insecret and not playPizzaTimeMusic()
		and mapmusname == "SECRET" then -- Normal music should play outside a secret
			mapmusname = mapheaderinfo[gamemap].musname
			S_ChangeMusic(mapmusname, true)
		end
		
	end

	-- For titlecards
	if PTV3.titlecards[gamemap] then
		if displayplayer and displayplayer.ptv3 and not playPizzaTimeMusic() then
			if leveltime < PTV3.maxTitlecardTime and mapmusname ~= PTV3.titlecards[gamemap].m then -- Start titlecard jingle
				mapmusname = PTV3.titlecards[gamemap].m
				S_ChangeMusic(mapmusname, false)
			end

			if leveltime >= PTV3.maxTitlecardTime and mapmusname == PTV3.titlecards[gamemap].m then -- Start map music
				mapmusname = mapheaderinfo[gamemap].musname
				S_ChangeMusic(mapmusname, true)
			end
		end
	end

	if not playPizzaTimeMusic() then return end
	local loop = true

	if not (displayplayer and displayplayer.ptv3) then return end
	local p = displayplayer

	local song

	if p.ptv3.laps < 0 then
		song = music.minus[max(1, min(abs(p.ptv3.laps), #music.minus))]
	else
		song = music.plus[max(1, min(p.ptv3.laps, #music.plus))]
	end
	
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
		song = "POTMAC"
	end

	if mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end
end)