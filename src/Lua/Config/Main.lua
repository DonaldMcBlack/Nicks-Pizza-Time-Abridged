local function followC(p) return p.mo.health and p.PTRound and not p.PTRound.chaser and not (p.PTRound.fake_exit) end

rawset(_G, "PTV3_SKINS", {
	pizzaface = {
		[0] = {
			display_name = { [-1] = "Protoface", [1] = "Pizzaface"},
			name = "Pizzaface",
			extreme_theme = "POTMAC",
			can_haywire = true,
			basespeed = 25*FU,

			icons = {
				[-1] = "PROTOFACEICON",
				[0] = "PIZZAFACEICON0",
				[1] = "PIZZAFACEICON1",
				[2] = "PIZZAFACEICON2"
			},

			current_icon = 1,

			spawn = function(pf)
				S_StartSound(nil, PTV3.pizzatime < 0 and sfx_fplgh or sfx_pflgh)
				if not pf.tracer then pf.state = PTV3.pizzatime > -1 and S_PTV3_PIZZALAUGHING or S_PTV3_PROTOFACE end
				local spawnmessage = PTV3.pizzatime < 0 and "Is that... Pizzaface?" or "Pizzaface is coming..."
				print(spawnmessage)
			end,

			behaviour = function(pf)
				if pf.cooldown then return end
				pf.target = PTV3:getNearestPlayer(pf, followC)
				if not pf.target then pf.momx, pf.momy, pf.momz = 0, 0, 0 return end

				pf.angle = R_PointToAngle2(pf.x, pf.y, pf.target.x, pf.target.y)
				pf.combinedspeed = not pf.brokentimer and pf.skindata.basespeed or pf.skindata.basespeed/2
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

						pf.maxspeed = $ == nil and pf.skindata.basespeed or $
						if dist > FU*1500 then pf.maxspeed = min($+FU, 1000*FU) end

						if pf.state ~= S_PTV3_PIZZAMAD then pf.state = S_PTV3_PIZZAMAD end
						if dist > FU*2000 then
							pf.speed = max(FixedMul(FU/16, dist-(FU*500)), pf.combinedspeed)
						else
							pf.maxspeed = max(pf.skindata.basespeed+FixedMul(pf.skindata.basespeed/PTV3.max_elaps, (PTV3.highestlap-5)*FU), $-(FU/2))
							pf.speed = pf.maxspeed
						end
					else -- Normal Pizzaface
						if PTV3.pizzatime < 0 then
							pf.speed = max(FixedMul(FU/8, dist-(FU*250)), 23*FU)
						end

						if pf.brokentimer then
							pf.state = S_PTV3_PIZZAHAYWIRE
						elseif not pf.brokentimer and pf.state == S_PTV3_PIZZAHAYWIRE then
							pf.state = S_PTV3_PIZZAFACE
						end
					end

					if pf.eflags & MFE_UNDERWATER then
						pf.speed = FixedDiv($, 2*FU)
					end

					P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.speed)
				end
			end,

			touch = function(pf, mo)
				P_DamageMobj(mo, pf, pf, 999, DMG_INSTAKILL)

				local alive = PTV3.playerCount and PTV3:playerCount()

				if #alive < 1 then
					S_StartSound(nil, PTV3.pizzatime < 0 and sfx_fplgh or sfx_pflgh)
					if not pf.tracer then pf.state = PTV3.pizzatime > -1 and S_PTV3_PIZZALAUGHING or S_PTV3_PROTOFACE end
				end
			end,

			update = function(pf)
				local movesound = PTV3.pizzatime > -1 and sfx_pizmov or sfx_promov
				if not S_SoundPlaying(pf, movesound) then S_StartSound(pf, movesound) end

				if not (leveltime % 8) then
					if (pf.momx ~= 0 or pf.momy ~= 0 or pf.momz ~= 0) then
						PTV3:doEffect(pf, "PF Afterimage")
					end
				end

				if pf.cooldown then
					pf.cooldown = max($-1, 0)
					pf.frame = ($ & ~FF_TRANSMASK)|((pf.cooldown)/16<<FF_TRANSSHIFT)
				end

				pf.angry = (PTV3.extreme or PTV3.overtime) and PTV3.pizzatime > 0 or false

				if pf.angry then
					pf.skindata.current_icon = 2
				else
					pf.skindata.current_icon = PTV3.pizzatime > -1 and 1 or -1
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

						local player = PTV3:getNearestPlayer(p.mo, function(p2)
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
			basespeed = 10*FU,

			icons = {
				[-1] = "SHADEICON",
				[1] = "SNICKICON",
				[2] = "SUPERSNICKICON"
			},

			current_icon = 1,

			spawn = function(snick)
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

			update = function(snick)
				if not (leveltime % 8) and (snick.momx ~= 0 or snick.momy ~= 0 or snick.momz ~= 0) and not PTV3.snick.PTRound then
					PTV3:doEffect(snick, "Snick Afterimage")
				end
			end,

			behaviour = function(snick)
				snick.target = PTV3:getNearestPlayer(PTV3.spawn, followC)
				if not snick.target then snick.momx, snick.momy, snick.momz = 0, 0, 0 return end

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
						S_StartSound(nil, sfx_cdfm74, snick.target.player)
						local case = P_RandomRange(1, 4)
						if case == 1 then
							P_SetOrigin(snick, snick.target.x - 1000*FU, snick.target.y, 0)
						elseif case == 2 then P_SetOrigin(snick, snick.target.x + 1000*FU, snick.target.y, 0)
						elseif case == 3 then P_SetOrigin(snick, snick.target.x, snick.target.y + 1000*FU, 0)
						elseif case == 4 then P_SetOrigin(snick, snick.target.x, snick.target.y - 1000*FU, 0)
						end

					end
					
				else
					snick.speed = (not snick.speed) and snick.skindata.basespeed or ease.linear(FU/32, snick.speed, 10*FU)
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
			basespeed = 5*FU,
			touch_cooldown = 0, -- 5*FU

			icons = {
				[-1] = "JONATHANICON",
				[1] = "JOHNICON",
				[2] = "JOHNICON2"
			},

			current_icon = 1,

			spawn = function(john)
				-- john_data.touch_cooldown = TICRATE
				john.state = PTV3.pizzatime < 0 and S_PTV3_JONATHANPHANTOM or S_PTV3_JOHNGHOST
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

			update = function(john)
				local ambientsound = PTV3.pizzatime < 0 and sfx_jphmsp or sfx_jghtsp
				if not S_SoundPlaying(john, ambientsound) then S_StartSound(john, ambientsound) end

				john.skindata.current_icon = PTV3.pizzatime < 0 and -1 or 1
			end,

			behaviour = function(john)
				john.target = PTV3:getNearestPlayer(PTV3.spawn, followC)
				if not john.target then john.momx, john.momy, john.momz = 0, 0, 0 return end
				john.frame = ($ & ~FF_TRANSMASK)|((john.skindata.touch_cooldown/FU)/6<<FF_TRANSSHIFT)

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