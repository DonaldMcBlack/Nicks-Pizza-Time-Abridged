-- Callbacks work sort of like hooks.
-- Returning does nothing for most of them, unless specified.

PTV3.callbacks = {
	['PlayerThink'] = {},
	-- Use this to execute thinkers in PT safely.
	-- Arguments:
	-- p - Player.

	['TeleportPlayer'] = {},
	-- Usually used to teleport the player to a secret, or the end.
	-- Arguments:
	-- p - Teleported player.

	['NewLap'] = {},
	-- Self-explanatory. Executes all functions here after new lap.
	
	['PizzaTime'] = {},
	-- Triggers on Pizza Time.
	-- Arguments:
	-- p - Player that started Pizza Time.
	
	['VariableInit'] = {},
	-- Runs when all variables get initalized, except the player for reasons.
	
	['PlayerInit'] = {},
	-- Runs when the player gets initalized.
	-- Arguments:
	-- p - Inited player.

	['FoundSecret'] = {},
	-- Runs when the player finds a secret.
	-- Arguments:
	-- p - Player.
	
	['ExitSecret'] = {},
	-- Vice-versa to above.
	-- Arguments:
	-- p - Player.

	['OvertimeStart'] = {},
	-- When Overtime starts, if it could atleast.

	['TauntStart'] = {},
	-- When the player taunts, this runs. Only works with supported characters.
	-- Return true to override the effect ran.
	-- Arguments:
	-- p - Player

	['TauntEnd'] = {},
	-- When the taunt ends, this runs. Only works with supported characters.
	-- Arguments:
	-- p - Player

	['CanPVP'] = {},
	-- If the player passes all the "0" returns, this runs.
	-- Use this for custom logic depending on if your player can hit others or not.
	-- Check Mechanics/PVP for possible PVP returns.
	-- Arguments:
	-- pmo - Player Mobj
	-- mo2 - Hit Player Mobj

	['SwapModeThinker'] = {},
	-- If the player is a follower for Swap Mode.
	-- If this returns true, the normal thinker won't be ran.
	-- Arguments:
	-- p - Player Follower

	['PizzafaceKill'] = {},
	-- If Pizzaface can kill a player, then this will run.
	-- If this returns true, Pizzaface won't kill the player.
	-- Arguments:
	-- pf - Pizzaface
	-- pmo - Player Mobj

	['GameEnd'] = {}
	-- When the game ends.
}

setmetatable(PTV3.callbacks, {__call = function(self, name, ...)
	if not PTV3.callbacks[name] then return end
	local value = nil

	for _,func in ipairs(PTV3.callbacks[name]) do
		local temp = func(...)
		if temp ~= nil then value = temp end
	end

	return temp
end})

function PTV3:insertCallback(name, func)
	if not name or not PTV3.callbacks[name] then
		print('Callback name invalid. Please check TableManager.lua to see valid callbacks.')
		return
	end

	table.insert(PTV3.callbacks[name], func)
end