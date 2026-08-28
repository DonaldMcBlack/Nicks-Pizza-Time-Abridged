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
		if not p.PTRound then PTV3:InitPlayerChecks(p) end

		p.PTGlobal.lastbuttons = p.PTGlobal.buttons
		p.PTGlobal.lastforwardmove = p.PTGlobal.forwardmove
		p.PTGlobal.lastsidemove = p.PTGlobal.sidemove
		
		p.PTGlobal.buttons = p.cmd.buttons
		p.PTGlobal.forwardmove = p.cmd.forwardmove
		p.PTGlobal.sidemove = p.cmd.sidemove

		if PTV3.game_over < (21*TICRATE)-10 or p.PTGlobal.menumode.inmenu then
			p.cmd.buttons = 0
			p.cmd.forwardmove = 0
			p.cmd.sidemove = 0
		end

		if not (p.mo and p.mo.valid) continue end

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

	p.PTRound.freeflow = p.speed > p.normalspeed/2 and min($+1, 10*TICRATE) or max($-1, 0)

	if p.PTRound.freeflow == 9*TICRATE and p.speed > p.normalspeed/2 then S_StartSound(p.mo, sfx_spin) end

	if p.PTRound.freeflow > 9*TICRATE then
		local circle = P_SpawnMobjFromMobj(p.mo, 0, 0, p.mo.scale * p.mo.height/2, MT_THOK)
		circle.fuse = 7
		circle.scale = p.mo.scale
		circle.destscale = FU/5
		circle.colorized = true
		circle.color = p.mo.color
		circle.momx = -p.mo.momx / 2
		circle.momy = -p.mo.momy / 2
	elseif p.speed < p.normalspeed/2 then
		p.PTRound.freeflow = 0
	end

	if p.powers[pw_super] and not (leveltime % TICRATE) and not (p.mo.state >= S_PLAY_SUPER_TRANS1) and (p.mo.state <= S_PLAY_SUPER_TRANS6) then P_GivePlayerRings(p, 1) end

	if skins[p.mo.skin].flags & SF_SUPER then
		p.charflags = p.PTRound.combo >= 50 and $|SF_SUPER or $ & ~SF_SUPER
	end

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
	and PTV3.snick and PTV3.snick.valid and not PTV3.snick.PTRound
	and p.PTGlobal.buttons & BT_ATTACK then -- yea thats not a player, fill in snicks spot lol
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

addHook("SpinSpecial", function(p)
	if not PTV3:isPTV3() then return end
	if not p.PTRound then return end
	if multiplayer and p.powers[pw_emeralds] ~= 127 then return end
	if not multiplayer and not All7Emeralds(emeralds) then return end

	if p.pflags & PF_JUMPED and p.PTRound.combo >= 50 and p.charflags & SF_SUPER and not p.powers[pw_super] then
		p.rings = $ == 0 and $+2 or $
		P_DoSuperTransformation(p, false)
		p.mo.state = S_PLAY_SUPER_TRANS1
		return true
	end
	return false
end)

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

addHook("PlayerCanDamage", function(p, mo)
	if not PTV3:isPTV3() then return end

	if p.PTRound.freeflow > 9*TICRATE then return true end
end)


local function ParryBurst(p, mo)
	p.PTRound.isTaunting = false
	p.PTRound.tauntTime = 0
	p.powers[pw_invulnerability] = TICRATE

	local speedburst = 0

	if P_GetPlayerControlDirection(p) then
		speedburst = FixedHypot(p.PTRound.tauntmomx, p.PTRound.tauntmomy)*4
	else
		speedburst = -24*FU
		p.drawangle = R_PointToAngle2(p.mo.x, p.mo.y, mo.x, mo.y)
		p.mo.state = S_PLAY_SKID
		p.powers[pw_nocontrol] = TICRATE/2
	end

	S_StartSound(p.mo, sfx_ptprry)
	P_InstaThrust(p.mo, p.drawangle, speedburst)
end

addHook("MobjMoveCollide", function(pmo, mo)
	if not PTV3:isPTV3() then return end
	if not (mo and mo.valid) or not (pmo and pmo.valid and pmo.player) then return end

	local p = pmo.player

	if not p.PTRound.isTaunting then return end
	if not (mo.flags & MF_ENEMY) then return end

	ParryBurst(p, mo)
	P_KillMobj(mo, pmo, pmo)
end, MT_PLAYER)

addHook('ShouldDamage', function(pmo, inflictor, source, _, dmg)
	if not PTV3:isPTV3() then return end
	if not (pmo and pmo.valid and pmo.player) then return end

	local p = pmo.player

	if not p.PTRound.isTaunting then return end
	if not (inflictor and inflictor.valid) then return end

	ParryBurst(p, inflictor)

	if (inflictor.flags & MF_MISSILE) then
		inflictor.target = pmo
		inflictor.momx = -$
		inflictor.momy = -$
		inflictor.momz = -$
	else
		P_DamageMobj(inflictor, pmo, pmo)
	end
	return false
end, MT_PLAYER)