local ThinkerPath = "Players/Thinkers/"
local scriptPath = "Players/Scripts/"
local checksPath = "Players/Checks/"

dofile(scriptPath.."PlayerSpawn")
dofile(scriptPath.."PlayerDamage")
dofile(scriptPath.."PVP")

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
		if not (p and p.mo and p.ptv3) then continue end

		if not (p
		and p.valid
		and p.mo
		and p.mo.valid
		and p.ptv3) then continue end

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

	if not p.ptv3.chaser then
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
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then PTV3:player(p) end

	p.spectator = p.ptv3.specforce

	runCode(p)
	p.ptv3.canLap = max(0, $-1)

	if p.spectator
	and PTV3.snick
	and PTV3.snick.valid
	and not PTV3.snick.ptv3
	and p.cmd.buttons & BT_ATTACK then -- yea thats not a player, fill in snicks spot lol
		p.spectator = false
		p.playerstate = PST_LIVE

		p.ptv3.specforce = false
		p.ptv3.chaser = true
		p.ptv3.chasertype = "snick"
		
		PTV3.snick.tracer = p.mo
		p.ptv3.pizzaMobj = PTV3.snick
		PTV3.snick = p
		
		P_ResetPlayer(p)
	end

	if p.mo then
		table.insert(p.ptv3.movementData, {
			x = p.mo.x,
			y = p.mo.y,
			z = p.mo.z,
			angle = p.drawangle,
			momx = p.mo.momx,
			momy = p.mo.momy,
			momz = p.mo.momz
		})

		if #p.ptv3.movementData > (3*6) then
			table.remove(p.ptv3.movementData, 1)
		end
	end

	p.ptv3.buttons = p.cmd.buttons
	p.ptv3.forwardmove = p.cmd.forwardmove and $+1 or 0
	p.ptv3.sidemove = p.cmd.sidemove and $+1 or 0
end)

local function DoNotTheChaser(t, return_value)
	if t.valid and t.player and t.player.ptv3.chaser then 
		print(return_value)
		return return_value 
	end
end

addHook("ShouldDamage", function(t,i,s) return DoNotTheChaser(t, false) end, MT_PLAYER)
addHook("MobjDeath",    function(t,i,s) return DoNotTheChaser(t, true)  end, MT_PLAYER)
addHook("MobjDamage",   function(t,i,s) return DoNotTheChaser(t, true)  end, MT_PLAYER)

addHook("PlayerCmd", function(p, cmd)
	if not PTV3:isPTV3() then return end
	if not (PTV3.game_over < 15*TICRATE) or not (p.ptv3 and p.ptv3.menumode.inmenu) then return end

	cmd.buttons = 0
	cmd.forwardmove = 0
	cmd.sidemove = 0
end)

addHook("MobjDamage", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (t and t.player) then return end

	t.player.score = max(0, $-350)
end, MT_PLAYER)

addHook("MobjDeath", function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (i and i.valid and (i.type == MT_PTV3_PIZZAFACE or i.type == MT_PLAYER)) then return end
	if not (t and t.player and t.player.ptv3) then return end

	if t.player.ptv3.swapModeFollower then
		local mo = t.player.ptv3.swapModeFollower

		mo.player.ptv3.swapModeFollower = nil
		mo.player.ptv3.isSwap = nil
	end
	t.player.ptv3.isSwap = nil
	t.player.ptv3.swapModeFollower = nil
end, MT_PLAYER)