local function getNearestPlayer(pos, conditions)
	local x,y,z,pl,pm

	for p in players.iterate do
		if not p.mo then continue end
		if conditions and not conditions(p) then continue end
		
		local newx = abs(p.mo.x - pos.x)
		local newy = abs(p.mo.y - pos.y)
		local newz = abs(p.mo.z - pos.z)

		if (x == nil
		or y == nil
		or z == nil)
		or (newx < x
		and newy < y
		and newz < z) then
			x = newx
			y = newy
			z = newz
			pl = p
			pm = p.mo
		end
	end

	return pl, pm
end

rawset(_G, "PTV3_SKINS", {
	pizzaface = {
		[0] = {
			display_name = { [-1] = "Protoface", [1] = "Pizzaface"},
			name = "Pizzaface",
			extreme_theme = "POTMAC",
			states = { haywire = S_PTV3_PIZZAHAYWIRE, laughing = S_PTV3_PIZZALAUGHING, happy = S_PTV3_PIZZAHAPPY, normal = S_PTV3_PIZZAFACE, enraged = S_PTV3_PIZZAMAD },
			laughsound = { [-1] = sfx_fplgh, [1] = sfx_pflgh },
			movesound = { [-1] = sfx_promov, [1] = sfx_pizmov },
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

			spawn = function(p, pf, pf_data)
				S_StartSound(nil, pf_data.laughsound[PTV3.pizzatime < 0 and -1 or 1])
				if not p then pf.state = PTV3.pizzatime > -1 and S_PTV3_PIZZALAUGHING or S_PTV3_PROTOFACE end
				pf_data.current_icon = PTV3.pizzatime > -1 and 1 or -1
				local spawnmessage = PTV3.pizzatime < 0 and "Is that... Pizzaface?" or "Pizzaface is coming..."
				print(spawnmessage)
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
							pf.speed = max(FixedMul(FU/8, dist-(FU*250)), 23*FU)
						end

						if pf.brokentimer then
							pf.state = S_PTV3_PIZZAHAYWIRE
						elseif not pf.brokentimer and pf.state == S_PTV3_PIZZAHAYWIRE then
							pf.state = S_PTV3_PIZZAFACE
						end

						pf.skindata.current_icon = PTV3.pizzatime > -1 and 1 or -1
					end

					if pf.eflags & MFE_UNDERWATER then
						pf.speed = FixedDiv($, 2*FU)
					end

					P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.speed)
				end
			end,

			active_ability = 0,
			pizzaface_tpselection = 0,

			abilities = {
				[1] = {
					name = "Ram",
					buttontype = "Press",
					actiontime = 10*TICRATE,
					icon = "ACTION_RAM",
					button = "C1",
					
					cooldown = 0,
					cooldown_maxduration = 20*TICRATE,

					can_cancel = true,
					restrict = true,

					action_start = function(p, pf, pf_data)
						-- CONS_Printf(p, "Ram Start")
					end,
					
					action_behaviour = function(p, pf, pf_data)
						-- CONS_Printf(p, "Ram")

						local player = getNearestPlayer(p.mo, function(p2)
							return p2
							and p2.mo
							and p2.mo.health
							and p2.PTRound
							and not p2.PTRound.chaser
						end)

						if not player then
							pf_data.abilities[1].actiontime = 0
						else
							P_FlyTo(p.mo, player.mo.x, player.mo.y, player.mo.z, 45*FU)
						end
					end,

					action_end = function(p, pf, pf_data)
						-- CONS_Printf(p, "Ram End")
					end
				},
				[2] = {
					name = "Teleport",
					buttontype = "Hold",
					actiontime = -1,
					icon = "ACTION_TELEPORT",
					button = "C2",

					cooldown = 0,
					cooldown_maxduration = 40*TICRATE,

					can_cancel = false,
					restrict = true,

					action_start = function(p, pf, pf_data)
						p.PTRound.stun = 4*TICRATE
						S_StartSound(p.mo, pf_data.laughsound[(PTV3.pizzatime or 1)])
					end,

					action_behaviour = function(p, pf, pf_data)
						-- CONS_Printf(p, "Teleport")

						local pt_table = p.PTRound
						pf.flags2 = $|MF2_DONTDRAW

						if abs(p.cmd.sidemove) >= 25
						and abs(pt_table.pizzaface_tpsidemove) < 25 then
							local selIndex = p.cmd.sidemove >= 0 and 1 or -1

							pf.pizzaface_tpselection = $+selIndex

							if pf.pizzaface_tpselection > #PTV3.pizzafacetps then
								pf.pizzaface_tpselection = 1
							elseif pf.pizzaface_tpselection < 1 then
								pf.pizzaface_tpselection = #PTV3.pizzafacetps
							end
						end
						pt_table.pizzaface_tpsidemove = p.cmd.sidemove

						local sel = PTV3.pizzafacetps[pf.pizzaface_tpselection]

						P_SetOrigin(p.mo, sel.x, sel.y, sel.z)
						p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
					end,

					action_end = function(p, pf, pf_data)
						-- CONS_Printf(p, "Teleport End")
						pf.flags2 = $ & ~MF2_DONTDRAW
					end
				},
				[3] = {
					name = "Deploy",
					buttontype = "Press",
					actiontime = 12,
					icon = "ACTION_DEPLOY",
					button = "C3",
					
					cooldown = 0,
					cooldown_maxduration = 5*TICRATE,

					can_cancel = false,
					restrict = false,

					action_start = function(p, pf, pf_data)
						pf.state = S_PTV3_PIZZAFACE_SUMMON1
					end,

					action_behaviour = function(p, pf, pf_data)
						-- CONS_Printf(p, "Deploy")
					end,

					action_end = function(p, pf, pf_data)
						-- CONS_Printf(p, "Deploy End")
					end
				}
			}
		}
	},
	snick = {
		[0] = {
			display_name = { [-1] = "Shade", [1] = "Snick" },
			name = "Snick",
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

			spawn = function(p, snick, snick_data)
				local spawnmessage = PTV3.pizzatime < 0 and "Watch your back... And your front." or "Snick is here..."
				print(spawnmessage)
			end,

			touch = function(snick, pmo)
				if (pmo.player.pflags & PF_JUMPED or pmo.player.pflags & PF_SPINNING or pmo.player.pflags & PF_STARTDASH) or pmo.player.powers[pw_invulnerability] then
					local i = 0
					while i < 20 do
						local particle = P_SpawnMobjFromMobj(snick, 0, 0, 0, MT_ARIDDUST)
						particle.momx = P_RandomRange(-10, 10)*FU
						particle.momy = P_RandomRange(-10, 10)*FU
						particle.momz = P_RandomRange(-10, 10)*FU
						particle.scalespeed = FU/TICRATE
						particle.destscale = 0
						i = $+1
					end
					S_StartSound(nil, sfx_s1a3, pmo.player)

					if PTV3.pizzatime < 0 then
						local case = P_RandomRange(1, 4)
						if case == 1 then     P_SetOrigin(snick, pmo.x - 1000*FU, pmo.y, 0)
						elseif case == 2 then P_SetOrigin(snick, pmo.x + 1000*FU, pmo.y, 0)
						elseif case == 3 then P_SetOrigin(snick, pmo.x, pmo.y + 1000*FU, 0)
						elseif case == 4 then P_SetOrigin(snick, pmo.x, pmo.y - 1000*FU, 0)
						end
					else
						P_SetOrigin(snick, 0, 0, 0)
					end
					
					return
				elseif (pmo.player.powers[pw_flashing] and pmo.player.panim == PA_PAIN) or pmo.player.PTRound.fake_exit then
					return
				end
				
				P_DamageMobj(pmo, snick, snick)
			end,

			behaviour = function(snick)
				local dist = P_AproxDistance(snick.x - snick.target.x, snick.y - snick.target.y)
				local speedup = PTV3.pizzatime > -1 and 650*FU or 1000*FU
				snick.angle = R_PointToAngle2(snick.x, snick.y, snick.target.x, snick.target.y)

				local normalstate = PTV3.pizzatime > -1 and S_PTV3_SNICK or S_PTV3_SHADE
				local lungestate = PTV3.pizzatime > -1 and S_PTV3_SNICK_LUNGE or S_PTV3_SHADE_LUNGE
				
				if dist > speedup then

					if PTV3.pizzatime > -1 then
						snick.speed = min(FixedMul(FU/20, dist), 300*FU)
						if snick.state ~= lungestate then snick.state = lungestate end
					else
						local i = 0
						while i < 20 do
							local particle = P_SpawnMobjFromMobj(snick, 0, 0, 0, MT_ARIDDUST)
							particle.momx = P_RandomRange(-10, 10)*FU
							particle.momy = P_RandomRange(-10, 10)*FU
							particle.momz = P_RandomRange(-10, 10)*FU
							particle.scalespeed = FU/TICRATE
							particle.destscale = 0
							i = $+1
						end
						S_StartSound(nil, sfx_cdfm74, snick.target)
						local case = P_RandomRange(1, 4)
						if case == 1 then
							P_SetOrigin(snick, snick.target.x - 1000*FU, snick.target.y, 0)
						elseif case == 2 then P_SetOrigin(snick, snick.target.x + 1000*FU, snick.target.y, 0)
						elseif case == 3 then P_SetOrigin(snick, snick.target.x, snick.target.y + 1000*FU, 0)
						elseif case == 4 then P_SetOrigin(snick, snick.target.x, snick.target.y - 1000*FU, 0)
						end

					end
					
				else
					if not snick.speed then snick.speed = snick.skindata.basespeed
					else
						snick.speed = ease.linear(FU/32, snick.speed, 10*FU)
					end
					if snick.state ~= normalstate then snick.state = normalstate end
				end
				
				P_FlyTo(snick, snick.target.x, snick.target.y, snick.target.z+8*FU, snick.speed)
			end,

			abilities = {
				[1] = {
					name = "Dash",
					buttontype = "Hold",
					actiontime = 10*TICRATE,
					icon = "ACTION_DASH",
					button = "C1",
					
					cooldown = 0,
					cooldown_maxduration = 20*TICRATE,

					can_cancel = true,
					restrict = false,

					action_start = function(p, snick, snick_data)
						CONS_Printf(p, "Dash Start")
						snick_data.basespeed = 20*FU
						if FixedHypot(p.mo.momx, p.mo.momy) > 0 then
							snick.state = PTV3.pizzatime >= 0 and S_PTV3_SNICK_LUNGE or S_PTV3_SHADE_LUNGE
						end
					end,
					
					action_behaviour = function(p, snick, snick_data)
					end,

					action_end = function(p, snick, snick_data)
						snick.basespeed = 10*FU
					end
				},
				[2] = {
					name = "None",
					buttontype = "Hold",
					actiontime = -1,
					icon = "ACTION_TELEPORT",
					button = "C2",

					cooldown = 0,
					cooldown_maxduration = 40*TICRATE,

					can_cancel = false,
					restrict = true,

					action_start = function(p, snick, snick_data)
						-- CONS_Printf(p, "Teleport Start")
					end,

					action_behaviour = function(p, snick, snick_data)
						-- CONS_Printf(p, "Teleport")
					end,

					action_end = function(p, snick, snick_data)
						-- CONS_Printf(p, "Teleport End")
					end
				},
				[3] = {
					name = "Deploy",
					buttontype = "Press",
					actiontime = 12,
					icon = "ACTION_DEPLOY",
					button = "C3",
					
					cooldown = 0,
					cooldown_maxduration = 5*TICRATE,

					can_cancel = false,
					restrict = false,

					action_start = function(p, snick, snick_data)

					end,

					action_behaviour = function(p, snick, snick_data)
						-- CONS_Printf(p, "Deploy")
					end,

					action_end = function(p, snick, snick_data)
						-- CONS_Printf(p, "Deploy End")
					end
				}
			}
		}
	},
	johnGhost = {
		[0] = {
			display_name = { [-1] = "Jonathan", [1] = "John"},
			name = "John",
			extreme_theme = nil,
			states = { normal = S_PTV3_JOHNGHOST, minus_normal = S_PTV3_JONATHANPHANTOM },
			ambient_sfx = { [1] = sfx_jghtsp, [-1] = sfx_jphmsp },
			effect = nil,
			basespeed = 5*FU,
			touch_cooldown = 0, -- 5*FU

			icons = {
				[-1] = "JONATHANICON",
				[1] = "JOHNICON",
				[2] = "JOHNICON2"
			},

			current_icon = 1,

			spawn = function(p, john, john_data)
				-- john_data.touch_cooldown = TICRATE
				local spawnmessage = PTV3.pizzatime < 0 and "FEAR THE PHANTOM" or "John's ghost wants vengeance..."
				print(spawnmessage)
			end,

			touch = function(john, pmo)
				if john.tracer == pmo or john.skindata.touch_cooldown then return end
				if (pmo and pmo.player and pmo.player.PTRound and pmo.player.PTRound.chaser) then return end

				local p = pmo.player
				
				if p.PTRound.fake_exit then return end
				john.speed, john.basespeed, john.maxspeed = 0, 0, 0
				john.momx, john.momy, john.momz = 0, 0, 0

				local teleportdest = p.PTRound.pizzapost_id or p.PTRound.lastTeleportDest
				if not teleportdest then teleportdest = PTV3.pizzatime > 0 and PTV3.endpos or PTV3.spawn end

				PTV3:queueTeleport(p, teleportdest, false, john)
				S_StartSound(nil, sfx_jghtct, p)
				john.skindata.touch_cooldown = TICRATE
			end,

			behaviour = function(john)
				john.frame = ($ & ~FF_TRANSMASK)|((john.skindata.touch_cooldown/FU)/6<<FF_TRANSSHIFT)

				john.skindata.current_icon = PTV3.pizzatime < 0 and -1 or 1
				john.ambience = john.skindata.ambient_sfx[PTV3.pizzatime or 1]

				if not S_SoundPlaying(john, john.ambience) then S_StartSound(john, john.ambience) end

				if john.skindata.touch_cooldown then
					john.skindata.touch_cooldown = max($-1, 0)

					if john.skindata.touch_cooldown == 0 then
						P_SetOrigin(john, 0, 0, 0)
					end
					return
				end

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

dofile "Config/Music Data"