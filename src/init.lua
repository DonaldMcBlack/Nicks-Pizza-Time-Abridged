freeslot("TOL_PTV3")
rawset(_G, "PTV3", {})

rawset(_G, "P_FlyTo", function(mo, fx, fy, fz, sped, addques)
	local z = mo.z+(mo.height/2)
    if mo.valid then
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - z)
        if flyto < 1 then
            flyto = 1
        end
		
        if addques then
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - z, flyto), sped)
        end
    end
end)

rawset(_G,'L_DoBrakes', function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end)

rawset(_G, "L_SpeedCap", function(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd, ang =
		R_PointToDist2(0,0,spd_xy,mo.momz),
		R_PointToAngle2(0,0,mo.momx,mo.momy)
	if spd > limit then
		if factor == nil then
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakes(mo,factor)
		return factor
	end
end)

dofile "Freeslots"
rawset(_G, "PTV3_SKINS", {
	pizzaface = {
		[0] = {
			display_name = "Pizzaface",
			name = "Pizzaface",
			minus_name = "Protoface",
			extreme_theme = nil,
			states = { haywire = S_PTV3_PIZZAHAYWIRE, laughing = S_PTV3_PIZZALAUGHING, happy = S_PTV3_PIZZAHAPPY, normal = S_PTV3_PIZZAFACE, enraged = S_PTV3_PIZZAMAD },
			laughsound = sfx_pflgh,
			effect = "PF Afterimage",
			can_haywire = true,
			intspeed = 25,
			incremspeed = FU,
			incremspeedthreshold = 16,

			icons = {
				[-1] = "PROTOFACEICON",
				[0] = "PIZZAFACEICON0",
				[1] = "PIZZAFACEICON1",
				[2] = "PIZZAFACEICON2"
			},

			current_icon = 1,

			spawn = function(pf)
				pf.state = S_PTV3_PIZZALAUGHING
				CONS_Printf(consoleplayer, "Spawn function exists!")
			end,

			behaviour = function(pf)
				pf.angle = R_PointToAngle2(pf.x, pf.y, pf.target.x, pf.target.y)
				pf.combinedspeed = not pf.brokentimer and (pf.skindata.intspeed*pf.skindata.incremspeed) or (pf.skindata.intspeed*pf.skindata.incremspeed)/2
				pf.speed = pf.combinedspeed

				if pf.state == S_PTV3_PIZZALAUGHING then pf.state = S_PTV3_PIZZAFACE end

				local dist = R_PointToDist2(pf.x, pf.y, pf.target.x, pf.target.y)
				if gametype == GT_PTV3DM then
					local sped = pf.combinedspeed/2
					local sped2 = pf.combinedspeed/20

					if not PTV3.pftime then
						sped = 10*pf.combinedspeed/2
						sped2 = pf.combinedspeed/10
						if pf.state ~= S_PTV3_PIZZAFACE then pf.state = S_PTV3_PIZZAFACE end
						pf.skindata.current_icon = 1
					else
						if pf.state ~= S_PTV3_PIZZAHAPPY then pf.state = S_PTV3_PIZZAHAPPY end
						pf.skindata.current_icon = 0
					end

					-- a bit of yoink from FlyTo
					local flyto = P_AproxDistance(P_AproxDistance(pf.target.x - pf.x, pf.target.y - pf.y), pf.target.z - pf.z)
					if flyto < 1 then
						flyto = 1
					end
					local tmomx = FixedMul(FixedDiv(pf.target.x - pf.x, flyto), sped)
					local tmomy = FixedMul(FixedDiv(pf.target.y - pf.y, flyto), sped)
					local tmomz = FixedMul(FixedDiv(pf.target.z - pf.z, flyto), sped)
					-- and again
					local flyto2 = P_AproxDistance(P_AproxDistance(tmomx - pf.momx, tmomy - pf.momy), tmomz - pf.momz)
					if flyto2 < 1 then
						flyto2 = 1
					end
					pf.momx = $ + FixedMul(FixedDiv(tmomx - pf.momx, flyto2), sped2)
					pf.momy = $ + FixedMul(FixedDiv(tmomy - pf.momy, flyto2), sped2)
					pf.momz = $ + FixedMul(FixedDiv(tmomz - pf.momz, flyto2), sped2)
					L_SpeedCap(pf, sped)
				else
					-- Behaviour changes ---------------------
					if pf.angry then -- Enraged Pizzaface
						if pf.state ~= S_PTV3_PIZZAMAD then pf.state = S_PTV3_PIZZAMAD end
						if dist > FU*2000 then
							pf.speed = max(FixedMul(FU/pf.skindata.incremspeedthreshold, dist-(FU*500)), pf.combinedspeed)
						else
							pf.speed = ease.linear(FU/pf.skindata.incremspeedthreshold, pf.speed, pf.combinedspeed)
						end
						pf.skindata.current_icon = 2
					else -- Normal Pizzaface
						if PTV3.pizzatime < 0 then
							if dist < FU*100 and pf.state ~= S_PTV3_PIZZATROLL then pf.state = S_PTV3_PIZZATROLL
							elseif dist > FU*100 and pf.state ~= S_PTV3_PIZZAFACE then pf.state = S_PTV3_PIZZAFACE end

							pf.speed = max(FixedMul(FU/8, dist-(FU*250)), 23*FU)
						end

						if pf.brokentimer and pf.state ~= S_PTV3_PIZZAHAYWIRE then pf.state = S_PTV3_PIZZAHAYWIRE
						elseif not pf.brokentimer and pf.state ~= S_PTV3_PIZZAFACE then
							pf.state = S_PTV3_PIZZAFACE
						end

						pf.skindata.current_icon = 1
					end

					if pf.eflags & MFE_UNDERWATER then
						pf.speed = FixedDiv($, 2*FU)
					end

					P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.speed)
				end
			end
		}
	},
	snick = {
		[0] = {
			display_name = "Snick",
			name = "Snick",
			minus_name = "Shade",
			extreme_theme = nil,
			states = { normal = S_PTV3_SNICK, lunge = S_PTV3_SNICK_LUNGE },
			effect = "Snick Afterimage",
			basespeed = 10*FU,

			icons = {
				[-1] = "SHADEICON",
				[1] = "SNICKICON",
				[2] = "SUPERSNICKICON"
			},

			current_icon = 1,

			behaviour = function(snick)
				local dist = P_AproxDistance(snick.x - snick.target.x, snick.y - snick.target.y)
				local speedup = 650*FU
				snick.angle = R_PointToAngle2(snick.x, snick.y, snick.target.x, snick.target.y)
				
				if dist > speedup then
					snick.speed = min(FixedMul(FU/20, dist), 300*FU)
					if snick.state ~= S_PTV3_SNICK_LUNGE then
						snick.state = S_PTV3_SNICK_LUNGE
					end
				else
					if not snick.speed then snick.speed = snick.skindata.basespeed
					else
						snick.speed = ease.linear(FU/32, snick.speed, 10*FU)
					end

					if snick.state ~= S_PTV3_SNICK then
						snick.state = S_PTV3_SNICK
					end
				end
				
				P_FlyTo(snick, snick.target.x, snick.target.y, snick.target.z+8*FU, snick.speed)
			end
		}
	},
	johnGhost = {
		[0] = {
			display_name = "John",
			name = "John",
			minus_name = "Jonathan",
			extreme_theme = nil,
			states = { normal = S_PTV3_JOHNGHOST, minus_normal = S_PTV3_JONATHANPHANTOM },
			ambient_sfx = { normal = sfx_jghtsp, minus = sfx_jphmsp },
			effect = nil,
			basespeed = 5*FU,

			icons = {
				[-1] = "JONATHANICON",
				[1] = "JOHNICON",
				[2] = "JOHNICON2"
			},

			current_icon = 1,

			behaviour = function(john)
				john.skindata.current_icon = PTV3.pizzatime < 0 and -1 or 1
				john.ambience = PTV3.pizzatime < 0 and john.skindata.ambient_sfx.minus or john.skindata.ambient_sfx.normal

				if not S_SoundPlaying(john, john.ambience) then S_StartSound(john, john.ambience) end

				local dist = P_AproxDistance(john.x - john.target.x, john.y - john.target.y)
				john.angle = R_PointToAngle2(john.x, john.y, john.target.x, john.target.y)
				john.speed = $ == nil and john.skindata.basespeed or $
				john.maxspeed = $ == nil and john.skindata.basespeed or $

				if PTV3.pizzatime < 0 then
					john.skindata.basespeed = 10*FU
					john.maxspeed = dist > 2000*FU and min($+(FU/3), 100*FU) or max(john.skindata.basespeed, $-(FU/6))
					john.speed = john.maxspeed
				else
					john.skindata.basespeed = 5*FU
					john.speed = max(FixedMul(FU/32, dist), john.skindata.basespeed)
				end
				
				P_FlyTo(john, john.target.x, john.target.y, john.target.z+((john.target.scale*john.target.height)+(60*FU)), john.speed)
			end
		}
	}
})
rawset(_G, "CV_PTV3", {})
rawset(_G, "PTV3_MENU", {
	dresser = {
		rootentries = { [0] = "Inventory", [1] = "Chaser Skins"}
	}
})
rawset(_G, "PTV3_2D", {__map = 507})

// TODO:
// add custom music support (done)
// add multiple chasers (done)
// make lobby background
// give pizzaface ana bility
// planned: chasedown, teleport (done, needs polish)
// give snick an ability
// planned: sonic playstyle, ringslinger
// add more ways for players to mock pizzaface and other chasers
// pizzaface skins (coneball, eggman, brody fox, summa dat) (for a separate pack)
// make mod more moddable
// fix and finish death mode
// make a title screen (done)
// make maps for up to castle eggman
// add a tutorial

local file = io.openlocal("client/NicksPT/SongData.txt", "r")
if not file then
	local save = io.openlocal("client/NicksPT/SongData.txt", "w")
	save:flush()
	save:close()
else
	file:close()
end

-- this seems out of place, i know, but its for a reason
G_AddGametype({
    name = "Pizza Time",
    identifier = "PTV3",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_match,
    headerleftcolor = 98,
    headerrightcolor = 51,
    description = "Go head-to-head against your friends! Use items, kill enemies, and be the one that starts Pizza Time in the classic mode you know and love, but better!"
})

G_AddGametype({
    name = "Death Mode",
    identifier = "PTV3DM",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_match,
    headerleftcolor = 163,
    headerrightcolor = 35,
    description = "Pizzaface woke up early and is ready to exact his revenge! Collect clocks to keep him at bay as you battle to be the last one alive in this pizza massacre!"
})

states[freeslot "S_PTV3_PANIC"] = {
	sprite = SPR_PLAY,
	frame = SPR2_CNT1,
	tics = 4,
	nextstate = S_PTV3_PANIC
}

function PTV3:isPTV3(dontCheckState, dontCheckFor2DMap)
	if not dontCheckState
	and gamestate ~= GS_LEVEL then
		return false
	end

	if not dontCheckFor2DMap
	and gamemap == PTV3_2D.__map then
		return false
	end

	return gametype == GT_PTV3 or gametype == GT_PTV3DM or not multiplayer
end

function PTV3_2D:canRun()
	return PTV3:isPTV3(false, true) and gamemap == PTV3_2D.__map
end

-- Actions

--Escape Spawner from Pizza Tower
--The Spawning Action
function A_PizzaTowerEscapeSpawn(actor, var1, var2)
	A_PlaySeeSound(actor,var1,var2)
	local z = actor.z

	if actor.eflags&MFE_VERTICALFLIP then
		z = $1+FixedMul(actor.info.height-mobjinfo[actor.health].height,actor.scale)
	end

	local enemy = P_SpawnMobj(actor.x,actor.y,z,actor.health)

	if actor.eflags&MFE_VERTICALFLIP then
		enemy.eflags = $1|MFE_VERTICALFLIP
		enemy.flags2 = $1|MF2_OBJECTFLIP
	end
	enemy.scale = actor.scale

	P_MoveOrigin(enemy,actor.x,actor.y,z)

	if P_SupermanLook4Players(enemy) then
		A_FaceTarget(enemy,0,0)
	end

	actor.target = enemy
end

dofile "Libs/customhudlib"

dofile "Variables"
dofile "Callbacks"
dofile "Titlecards Data"
dofile "Functions"
dofile "Effects/Main"
dofile "Mechanics/Main"
dofile "Items/Main"
dofile "Config"

PTV3.maxTitlecardTime = 3*TICRATE

dofile "Main"
dofile "Players/Main"
dofile "Music"
dofile "HUD/Main"
dofile "Intermission/Main"

dofile "2D Engine/init"