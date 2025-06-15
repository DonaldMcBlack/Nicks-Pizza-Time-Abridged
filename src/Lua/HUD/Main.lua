local ReduceHUD = dofile "HUD/Remove Score"
local InventoryHUD = dofile "HUD/Inventory"
local PizzaTimeHUD = dofile "HUD/Pizza Time"
local MinusWorldHUD = dofile "HUD/Minus World"
local OvertimeHUD = dofile "HUD/Overtime Text"
local LapHUD = dofile "HUD/Laps"
local SecretHUD = dofile "HUD/Secrets"
local CanLapHUD = dofile "HUD/Can Lap"
local CamperHud = dofile "HUD/PF Camper"
local ExtremeNHud = dofile "HUD/ELap Notif"
local PizzafaceRageHUD = dofile "HUD/Pizzaface Rage"
local PizzafaceTimerHUD = dofile "HUD/Pizzaface Timer"
local TimerHUD = dofile "HUD/Normal Timer"
local WarTimerHUD = dofile "HUD/Overtime Timer"
local EndHUD = dofile "HUD/Overtime End"
local RankHUD = dofile "HUD/Ranks"
local ComboHUD = dofile "HUD/Combo"
local IconHUD = dofile "HUD/Icons"
local TitlecardHUD = dofile "HUD/Titlecards"
local InversionHUD = dofile "HUD/Inversion"
local VersionHUD = dofile "HUD/Version"

function PTV3.HUD_returnTime(startTime, length, offset, useTics)
	if offset == nil then
		offset = 0
	end
	if not useTics then
		length = $*TICRATE/FU
	end

	local time = startTime+offset
	local tween = FixedDiv(max(0, min(leveltime-time, length)), length)

	return tween
end

customhud.SetupFont("PTFNT", 1, 12)
customhud.SetupFont("PCFNT")
customhud.SetupFont("WARFN", 8, 40)
customhud.SetupFont("PTLAP")
customhud.SetupFont("PTCMB")
customhud.SetupFont("STCFN")

customhud.SetupItem("Icons", "ptv3", IconHUD, "game")
customhud.SetupItem("Reduce Score", "ptv3", ReduceHUD, "game")
customhud.SetupItem("Inventory", "ptv3", InventoryHUD, "game", 1)
customhud.SetupItem("Laps", "ptv3", LapHUD, "game", 1)
customhud.SetupItem("Pizza Time", "ptv3", PizzaTimeHUD, "game", 1)
customhud.SetupItem("Minus World", "ptv3", MinusWorldHUD, "game", 1)
customhud.SetupItem("Overtime", "ptv3", OvertimeHUD, "game", 1)
customhud.SetupItem("Pizzaface Rage", "ptv3", PizzafaceRageHUD, "game", 1)
customhud.SetupItem("Pizzaface Timer", "ptv3", PizzafaceTimerHUD, "game", 1)
customhud.SetupItem("Timer", "ptv3", TimerHUD, "game", 1)
customhud.SetupItem("Overtime Timer", "ptv3", WarTimerHUD, "game", 1)
customhud.SetupItem("End", "ptv3", EndHUD, "game", 1)
customhud.SetupItem("Rank", "ptv3", RankHUD, "game", -1)
customhud.SetupItem("Combo", "ptv3", ComboHUD, "game", -1)
customhud.SetupItem("Secrets", "ptv3", SecretHUD, "game", 2)
customhud.SetupItem("Camper", "ptv3", CamperHud, "game", 2)
customhud.SetupItem("Can Lap", "ptv3", CanLapHUD, "game", 2)
customhud.SetupItem("Extreme Notif", "ptv3", ExtremeNHud, "game", 3)
customhud.SetupItem("Titlecards", "ptv3", TitlecardHUD, "gameandscores", 4)
customhud.SetupItem("Version", "ptv3", VersionHUD, "gameandscores", 5)
customhud.SetupItem("Inversion", "ptv3", InversionHUD, "game", 5)