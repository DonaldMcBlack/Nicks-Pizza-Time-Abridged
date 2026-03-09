local ThinkerPath = "Players/Thinkers/"
local scriptPath = "Players/Scripts/"
local checksPath = "Players/Checks/"

dofile(scriptPath.."PlayerSpawn")
dofile(scriptPath.."PlayerDamage")
dofile(scriptPath.."PVP")


dofile(checksPath.."Init Player")
local cutscene,precutscene = dofile(checksPath.."Cutscene")
local exit = dofile(checksPath.."Exit")
local gameover = dofile(checksPath.."Game Over")

local exithandler = dofile(ThinkerPath.."Exits")
local scoreremoval = dofile(ThinkerPath.."Score Removal")
local taunt,pretaunt = dofile(ThinkerPath.."Taunting")
local panic = dofile(ThinkerPath.."Panic")
local itemequip = dofile(ThinkerPath.."ItemEquip")
local ragdoll = dofile(ThinkerPath.."Ragdoll")

local chaserthink = dofile(ThinkerPath.."Chaser")

addHook("PreThinkFrame", function()
	for p in players.iterate do
		if not (p and p.mo and p.PTRound) then continue end

		if not (p
		and p.valid
		and p.mo
		and p.mo.valid
		and p.PTRound) then continue end

		precutscene(p)
		pretaunt(p)
	end
end)

local function runCode(p)
	if p.spectator then return end
	if not p.mo    then return end
	if cutscene(p) then return end
	if exit(p)     then return end
	if gameover(p) then return end

	if not p.PTRound.chaser then
		exithandler(p)
		scoreremoval(p)
		taunt(p)
		panic(p)
		ragdoll(p)
	else
		R_SetPlayerSkin(p, "sonic")
		p.mo.flags2 = $|MF2_DONTDRAW

		chaserthink(p)
	end

	itemequip(p)

	PTV3:checkRank(p)
	PTV3:returnNextRankPercent(p)
	PTV3.callbacks("PlayerThink", p)
end

addHook("PlayerThink", function(p)
	if not PTV3:isPTV3() or not p.PTRound then return end

	p.spectator = p.PTRound.specforce

	runCode(p)
	p.PTRound.canLap = max(0, $-1)

	if p.spectator
	and PTV3.snick
	and PTV3.snick.valid
	and not PTV3.snick.PTRound
	and p.cmd.buttons & BT_ATTACK then -- yea thats not a player, fill in snicks spot lol
		p.spectator = false
		p.playerstate = PST_LIVE

		p.PTRound.specforce = false
		p.PTRound.chaser = true
		p.PTRound.chasertype = "snick"
		
		PTV3.snick.tracer = p.mo
		p.PTRound.pizzaMobj = PTV3.snick
		PTV3.snick = p
		
		P_ResetPlayer(p)
	end

	if p.mo then
		table.insert(p.PTRound.movementData, {
			x = p.mo.x,
			y = p.mo.y,
			z = p.mo.z,
			angle = p.drawangle,
			momx = p.mo.momx,
			momy = p.mo.momy,
			momz = p.mo.momz
		})

		if #p.PTRound.movementData > (3*6) then
			table.remove(p.PTRound.movementData, 1)
		end
	end

	p.PTGlobal.buttons = p.cmd.buttons
	p.PTGlobal.forwardmove = p.cmd.forwardmove and $+1 or 0
	p.PTGlobal.sidemove = p.cmd.sidemove and $+1 or 0
end)

local function DoNotTheChaser(t, return_value)
	if t.valid and t.player and t.player.PTRound.chaser then 
		print(return_value)
		return return_value 
	end
end

addHook("ShouldDamage", function(t,i,s) return DoNotTheChaser(t, false) end, MT_PLAYER)
addHook("MobjDeath",    function(t,i,s) return DoNotTheChaser(t, true)  end, MT_PLAYER)
addHook("MobjDamage",   function(t,i,s) return DoNotTheChaser(t, true)  end, MT_PLAYER)

addHook("PlayerCmd", function(p, cmd)
	if not PTV3:isPTV3() then return end
	
	if PTV3.game_over < (21*TICRATE)-10 or p.PTGlobal.menumode.inmenu then

		p.PTGlobal.buttons = cmd.buttons
		p.PTGlobal.forwardmove = cmd.forwardmove
		p.PTGlobal.sidemove = cmd.sidemove

		cmd.buttons = 0
		cmd.forwardmove = 0
		cmd.sidemove = 0
	end
end)

-- No more game status.
addHook("KeyDown", function(key)
	if not PTV3:isPTV3() then return end
	if PTV3.game_over > (21*TICRATE)-10 then return end

	if key.num == input.gameControlToKeyNum(GC_SCORES) then return true end

	return false
end)

addHook("MobjDamage", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (t and t.player) then return end

	t.player.score = max(0, $-350)
end, MT_PLAYER)

addHook("MobjDeath", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (i and i.valid and (i.type == MT_PTV3_PIZZAFACE or i.type == MT_PLAYER)) then return end
	if not (t and t.player and t.player.PTRound) then return end

	-- if t.player.PTRound.swapModeFollower then
	-- 	local mo = t.player.PTRound.swapModeFollower

	-- 	mo.player.PTRound.swapModeFollower = nil
	-- 	mo.player.PTRound.isSwap = nil
	-- end
	-- t.player.PTRound.isSwap = nil
	-- t.player.PTRound.swapModeFollower = nil
end, MT_PLAYER)