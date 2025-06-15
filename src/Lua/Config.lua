local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local data = {Default = {}}
local modtoload
local modloaded = false
local waittime = 5 -- safety

local f = io.openlocal("client/NicksPT/SongData.txt", "r")
if f then
	local forskin = "Default"
	for line in f:lines() do
		local songs = mysplit(line, " ")

		if line:find("^# ") then
			forskin = line:sub(3,#line)
			data[forskin] = {}
		elseif songs[1] == "LapMusic" then
			data[forskin][tonumber(songs[2] or 1)] = songs[3] or "PIZTIM"
			print(forskin)
		elseif songs[1] == "Overtime" then
			data[forskin]["Overtime"] = songs[2]
		elseif songs[1] == "Secret" then
			data[forskin]["Secret"] = songs[2]
		elseif songs[1] == "LoadMod" then
			modtoload = songs[2]
		end
	end
end
f:close()

addHook("PostThinkFrame", do
	if gamestate == GS_LEVEL
	and modtoload
	and not modloaded
	and consoleplayer then
		if not (waittime) then
			COM_BufInsertText(consoleplayer, "addfile "..modtoload)
			modloaded = true
		else
			waittime = $-1
		end
	end
end)

function PTV3:__getsongdata(song)
    return data
end