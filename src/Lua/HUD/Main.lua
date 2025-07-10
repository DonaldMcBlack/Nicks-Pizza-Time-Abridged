local ReduceHUD = dofile "HUD/Remove Score"
local InventoryHUD = dofile "HUD/Inventory"
local PizzaTimeHUD = dofile "HUD/Pizza Time"
local MinusWorldHUD = dofile "HUD/Minus World"
local OvertimeHUD = dofile "HUD/Overtime Text"
local LapHUD = dofile "HUD/Laps"
local SecretHUD = dofile "HUD/Secrets"
local CanLapHUD = dofile "HUD/Can Lap"
local CamperHud = dofile "HUD/PF Camper"
local ExtremeNHUD = dofile "HUD/ELap Notif"
local SnickHUD = dofile "HUD/Spawn as Snick"
local ControlsHUD = dofile "HUD/Controls"
local PizzaRageHUD = dofile "HUD/Pizza Rage"
local PizzafaceTimerHUD = dofile "HUD/Pizzaface Timer"
local TimerHUD = dofile "HUD/Normal Timer"
local WarTimerHUD = dofile "HUD/Overtime Timer"
local EndHUD = dofile "HUD/Overtime End"
local RankHUD = dofile "HUD/Ranks"
local ComboHUD = dofile "HUD/Combo"
local DresserHUD = dofile "HUD/Dresser Menu"
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

customhud.SetupItem("PTV3_Icons",           "ptv3", IconHUD,           "game")
customhud.SetupItem("PTV3_Reduce Score",    "ptv3", ReduceHUD,         "game")
customhud.SetupItem("PTV3_Inventory",       "ptv3", InventoryHUD,      "game", 1)
customhud.SetupItem("PTV3_Laps",            "ptv3", LapHUD,            "game", 1)
customhud.SetupItem("PTV3_Pizza Time",      "ptv3", PizzaTimeHUD,      "game", 1)
customhud.SetupItem("PTV3_Minus World",     "ptv3", MinusWorldHUD,     "game", 1)
customhud.SetupItem("PTV3_Overtime",        "ptv3", OvertimeHUD,       "game", 1)
customhud.SetupItem("PTV3_Pizza Rage",      "ptv3", PizzaRageHUD,      "game", 1)
customhud.SetupItem("PTV3_Pizzaface Timer", "ptv3", PizzafaceTimerHUD, "game", 1)
customhud.SetupItem("PTV3_Timer",           "ptv3", TimerHUD,          "game", 1)
customhud.SetupItem("PTV3_Overtime Timer",  "ptv3", WarTimerHUD,       "game", 1)
customhud.SetupItem("PTV3_End",             "ptv3", EndHUD,            "game", 1)
customhud.SetupItem("PTV3_Rank",            "ptv3", RankHUD,           "game", -1)
customhud.SetupItem("PTV3_Combo",           "ptv3", ComboHUD,          "game", -1)
customhud.SetupItem("PTV3_Secrets",         "ptv3", SecretHUD,         "game", 2)
customhud.SetupItem("PTV3_Camper",          "ptv3", CamperHud,         "game", 2)
customhud.SetupItem("PTV3_Snick",           "ptv3", SnickHUD,          "game", 2)
customhud.SetupItem("PTV3_Controls",        "ptv3", ControlsHUD,       "game", 2)
customhud.SetupItem("PTV3_Can Lap",         "ptv3", CanLapHUD,         "game", 2)
customhud.SetupItem("PTV3_ELap Notif",      "ptv3", ExtremeNHUD,       "game", 3)
customhud.SetupItem("PTV3_Dresser Menu",    "ptv3", DresserHUD,        "game", 3)
customhud.SetupItem("PTV3_Titlecards",      "ptv3", TitlecardHUD,      "gameandscores", 4)
customhud.SetupItem("Version",              "ptv3", VersionHUD,        "gameandscores", 5)
customhud.SetupItem("Inversion",            "ptv3", InversionHUD,      "game", 5)