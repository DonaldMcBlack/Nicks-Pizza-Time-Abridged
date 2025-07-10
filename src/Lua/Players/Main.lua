local playerThinkerPath = "Players/Thinkers/Player/"
local chaserThinkerPath = "Players/Thinkers/Chaser/"
local scriptPath = "Players/Scripts/"
local checksPath = "Players/Checks/"

dofile(scriptPath.."PlayerSpawn")
dofile(scriptPath.."PlayerDamage")
dofile(scriptPath.."PVP")

local cutscene,precutscene = dofile(checksPath.."Cutscene")
local exit = dofile(checksPath.."Exit")
local gameover = dofile(checksPath.."Game Over")
local ragdoll = dofile(checksPath.."Ragdoll")

local exithandler = dofile(playerThinkerPath.."Exits")
local scoreremoval = dofile(playerThinkerPath.."Score Removal")
local taunt,pretaunt = dofile(playerThinkerPath.."Taunting")
local panic = dofile(playerThinkerPath.."Panic")

local chasers = {
	pizzaface = dofile(chaserThinkerPath.."Pizzaface"),
	snick     = dofile(chaserThinkerPath.."Snick"),
	johnghost = dofile(chaserThinkerPath.."John Ghost")
}

addHook("PreThinkFrame", do
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
    if ragdoll(p) then return end

	if not p.ptv3.chaser then
		exithandler(p)
		scoreremoval(p)
		taunt(p)
		panic(p)
	else
		R_SetPlayerSkin(p, "sonic")
		p.mo.flags2 = $|MF2_DONTDRAW

		local chaserfunc = chasers[p.ptv3.chasertype]

		chaserfunc(p)
	end

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
end)

local function DoNotTheChaser(t, return_value)
	if (t and t.player and t.player.ptv3 and t.player.ptv3.chaser) then return return_value end
end

addHook("ShouldDamage", function(t,i,s) DoNotTheChaser(t, false) end, MT_PLAYER)
addHook("MobjDeath",    function(t,i,s) DoNotTheChaser(t, true)  end, MT_PLAYER)
addHook("MobjDamage",   function(t,i,s) DoNotTheChaser(t, true)  end, MT_PLAYER)