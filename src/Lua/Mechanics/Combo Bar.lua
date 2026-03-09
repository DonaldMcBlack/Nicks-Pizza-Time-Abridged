freeslot("sfx_combo1", "sfx_combo2", "sfx_combo3")

sfxinfo[sfx_combo1].caption = "Combo up!"
sfxinfo[sfx_combo2].caption = "Combo up!"
sfxinfo[sfx_combo3].caption = "Combo up!"

PTV3.MAX_COMBO_TIME = 15*FU

local ranks = { 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75 }

addHook('MobjDamage', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (t.player) then return end
	local p = t.player

	if not (p.PTRound.combo_pos) then return end

	if p.PTRound.combo_pos > PTV3.MAX_COMBO_TIME/2 then
		p.PTRound.combo_pos = PTV3.MAX_COMBO_TIME/2
	else
		p.PTRound.combo_pos = 0
	end
end, MT_PLAYER)

---@param p player_t
---@param type number
---@param increase number
function PTV3:increaseCombo(p, type, increase)
	if type == 1 then
		p.PTRound.combo_pos = PTV3.MAX_COMBO_TIME
		if not (p.PTRound.combo) then
			p.PTRound.combo_start_time = leveltime
			p.PTRound.started_combo = true
		end
		p.PTRound.combo = $+1
	elseif type == 2 then
		p.PTRound.combo_pos = min($+increase, PTV3.MAX_COMBO_TIME)
	elseif type == 3 then
		p.PTRound.combo_pos = PTV3.MAX_COMBO_TIME
	end
end

addHook('MobjDamage', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.type == MT_PLAYER) then return end
	if not (s.player.PTRound and s.player.PTRound.combo) then return end
	if not (t.flags & MF_ENEMY) then return end
	
	PTV3:increaseCombo(s.player, 3)
end)

addHook('MobjDeath', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.type == MT_PLAYER) then return end
	
	if t.flags & MF_ENEMY then
		PTV3:increaseCombo(s.player, 1)
	elseif t.flags & MF_MONITOR then
		PTV3:increaseCombo(s.player, 3)
	else
		PTV3:increaseCombo(s.player, 2, PTV3.MAX_COMBO_TIME/5)
	end
end)

local function IncrementByFive(combo)
	if combo >= 80 and combo % 5 == 0 then return (((combo-80)/5)+1)
	elseif combo % 5 == 0 and combo > 4 then return ((combo+5)/5) -- Skip 'LAME'
	elseif combo < 4 then return 0 end

	return 0
end

PTV3:insertCallback("PlayerThink", function(p)
	if p.PTRound.combo_offtime then
		local time = min(((leveltime - p.PTRound.combo_offtime)*(FU*2))/35, FU+1)
		if time > FU then
			p.PTRound.combo_offtime = nil
		end
	end
	if not (p.PTRound.combo) then return end

	if not (p.exiting) then
		p.PTRound.combo_pos = $-(FU/TICRATE)
	end

	p.PTRound.combo_display = $ + ((p.PTRound.combo_pos-p.PTRound.combo_display)/2)

	local combo = p.PTRound.combo
	local very

	local rank_increment = IncrementByFive(combo)

	if combo >= 80 then very = true end

	p.PTRound.combo_rank.very = very

	if (p.PTRound.combo_pos > 0) then
		if rank_increment and combo >= ranks[rank_increment]
		and p.PTRound.combo_rank.rank ~= ranks[rank_increment] then -- Replace oldrank in Combo.lua
			p.PTRound.combo_rank.rank = ranks[rank_increment]
			p.PTRound.combo_rank.rankn = rank_increment
			p.PTRound.combo_rank.time = leveltime
			S_StartSound(nil, P_RandomRange(sfx_combo1, sfx_combo3), p)
		end
	else -- Reset
		p.PTRound.combo = 0
		p.PTRound.combo_pos = 0
		p.PTRound.combo_display = 0
		p.PTRound.combo_offtime = leveltime
		p.PTRound.combo_dropped = true
		
		for _,i in ipairs(ranks) do
			if combo >= i then
				p.PTRound.combo_rank.rank = i
				p.PTRound.combo_rank.rankn = _
			else
				break
			end
		end
		p.PTRound.combo_rank.time = leveltime
	end
	
	if p.PTRound.isSwap
	and p.PTRound.isSwap.valid then
		local p2 = p.PTRound.isSwap
		p2.PTRound.combo = p.PTRound.combo
		p2.PTRound.combo_pos = p.PTRound.combo_pos
		p2.PTRound.combo_display = p.PTRound.combo_display
		p2.PTRound.combo_offtime = p.PTRound.combo_offtime
		p2.PTRound.combo_dropped = p.PTRound.combo_dropped
		p2.PTRound.combo_rank = p.PTRound.combo_rank
	end
end)