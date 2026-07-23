--- Stores everything globally between maps.
--- @class PTV3PlayerGlobal_t
--- Buttons currently held down for the player whenever input is not used for the player mobj. Useful for menus.
--- @field buttons UINT16
--- Forwardmove for the player. Useful for menus.
--- @field forwardmove SINT8
--- Sidemove for the player. Useful for menus.
--- @field sidemove SINT8
--- The last sidemove of the player. Useful for menus.
--- @field lastsidemove SINT8
--- The last forwardmove of the player. Useful for menus.
--- @field lastforwardmove SINT8
--- The last pressed buttons for the player. Useful for menus.
--- @field lastbuttons UINT16
--- The player's skin for when they play as Pizzaface. Interchangable in the dresser menu.
--- @field pizzaface_skin string
--- The player's skin for when they play as Snick. Interchangable in the dresser menu.
--- @field snick_skin string
--- The player's skin for when they play as John Ghost. Interchangable in the dresser menu.
--- @field johnghost_skin string
--- The item currently available for use in the player's inventory.
--- @field curItem string
--- Items in the player's inventory
--- @field invItems table
--- How many rings the player has collected in total
--- @field ringBank integer


--- Round exclusive info.
--- @class PTV3PlayerRound_t
--- The number of laps ran.
--- @field laps integer
--- The ragdoll state for the player. The value decreases after the player has stopped bouncing. Once it reaches 1, the player will recover.
--- @field ragdoll integer
--- How many bounces the player will perform when ragdolling.
--- @field ragdoll_bounces integer
--- Is the player now a chaser?
--- @field chaser boolean
--- Force the player to spectate?
--- @field specforce boolean
--- Has the player entered Extreme Laps?
--- @field extreme boolean
--- Is the player exiting the level?
--- @field fake_exit boolean
--- Is the player in a secret?
--- @field insecret boolean
--- Number of secrets found by the player.
--- @field secretsfound integer
--- Should the player be teleported to end of their current secret?
--- @field secret_tptoend boolean
--- The player's combo number.
--- @field combo integer
--- The position of the Combo Puppet on the player's HUD.
--- @field combo_pos fixed_t
--- Is the player camping?
--- @field camper boolean
--- The duration of the previous lap.
--- @field lap_time number
--- The time left for the player to continue lapping from the Exit Gate.
--- @field canLap tic_t
--- The player's result rank for the end of the round.
--- @field rank integer
--- Tics used to measure the rank change time.
--- @field rank_changetime tic_t


--- Add fields to player_t
--- @class player_t
--- @field PTGlobal PTV3PlayerGlobal_t?
--- @field PTRound PTV3PlayerRound_t?

---@param p player_t
function PTV3:InitPlayerChecks(p)
	if not p.PTGlobal then
		PTV3:InitPlayerGlobal(p)
	end

	PTV3:InitPlayerRound(p)

end

--- Initialises the player's global variables for in between rounds. Should only be called once.
--- @param p player_t
function PTV3:InitPlayerGlobal(p)
	p.PTGlobal = {
		buttons = p.cmd.buttons,
		forwardmove = 0,
		sidemove = 0,

		lastbuttons = 0,
		lastforwardmove = 0,
		lastsidemove = 0,

		pizzaface_skin = "pizzaface",
		snick_skin = "snick",
		johnghost_skin = "john",

		curItem = nil,
		invItems = {},
		ringBank = 0,

		menumode = { inmenu = false, menutype = nil, selection = 1 }
	}
end

--- Initialises the player's per round variables.
--- @param p player_t
function PTV3:InitPlayerRound(p)
	-- local isSwap = player.ptv3 and player.ptv3.isSwap
	-- local swapModeFollower = player.ptv3 and player.ptv3.swapModeFollower

	p.PTRound = {
		laps = 0,

		ragdoll = 0,
		ragdoll_bounces = 0,

		chaser = false,
		chasertype = "pizzaface",
		chasermovetime = 0,
		chaservertmovetime = 0,

		specforce = false,
		extreme = false,
		fake_exit = false,
		insecret = false,
		secretsfound = 0,
		secret_tptoend = false,

		combo = 0,
		combo_pos = 0,
		combo_display = 0,
		combo_start_time = 0,
		started_combo = false,
		combo_offtime = 0,
		combo_rank = { rank = nil, rankn = 0, very = false, time = 5*TICRATE},

		lap_time = -1,
		canLap = 0,

		toppins = {},
		gate_vote = nil,

		curItem_equipped = false,
		curItem_mobj = nil,

		exitShield = SH_NONE,
		pvpCooldown = 0,
		
		movementData = {},
		lastTeleportDest = nil,
		pizzapost_id = nil,
		
		rank = 1,
		rank_changetime = -1,
		extremeNotif = 0,

		scoreReduce = {time = false, by = 0},
		comboscore = 0,
		roundscore = 0,

		pizzaMobj = false,
		pizzaMobj_skindata = {},
		
		isTaunting = false,
		tauntTime = 0,
		tauntmomx = 0,
		tauntmomy = 0,
		tauntmomz = 0,
		tauntlaststate = S_PLAY_STND,
		tauntsprite = SPR2_STND,
		tauntframe = A,

		stun = 0,

		camper = false,
		camper_area = {x=0, y=0},
		camper_radius = (40*24)*FU,
		camper_time = 0,
	}
	
	if self.pizzatime then
		p.PTRound.specforce = true
	end
	p.score = 0
	-- player.ptv3.swapModeFollower = swapModeFollower
	-- player.ptv3.isSwap = isSwap
	P_ResetPlayer(p)

	PTV3.callbacks('PlayerInit', p)
end