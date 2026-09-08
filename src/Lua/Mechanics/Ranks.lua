PTV3.ranks = {
	{
		rank = "D",
		music = "DRANK",
		fill = true
	},
	{
		rank = "C",
		music = "CBRANK",
		fill = true
	},
	{
		rank = "B",
		music = "CBRANK",
		fill = true
	},
	{
		rank = "A",
		music = "ARANK",
		fill = true
	},
	{
		rank = "S",
		music = "SRANK",
		fill = false
	},
	{
		rank = "P",
		music = "PRANK",
		fill = false,
		canGet = function(p)
			if PTV3.pizzatime then return p.PTRound
			and not p.PTRound.combo_dropped
			and p.PTRound.started_combo
			and abs(p.PTRound.laps) >= 2
			and p.PTRound.secretsfound >= #PTV3.secrets
			end
		end
	}

}

for i = 1,5 do
	sfxinfo[freeslot("sfx_rup"..i)].caption = "Ranked up!"
	sfxinfo[freeslot("sfx_rad"..i)].caption = "Ranked down!"
end

---@param p player_t
---@param rank string
function PTV3:canGet(p, rank)
	if not (p and p.PTRound) or not self.ranks[rank] then return false end

	if self.ranks[rank].canGet then return self.ranks[rank].canGet(p) end

	local total_score = p.PTRound.fake_exit and (p.score + p.PTRound.comboscore) or p.score
	if total_score < self.maxrankrequirement*(rank-1) then return false end

	return true
end

---@param p player_t
function PTV3:returnNextRankPercent(p)
	local depletion = self.maxrankrequirement*(p.PTRound.rank-1)
	local total_score = p.PTRound.fake_exit and (p.score + p.PTRound.comboscore) or p.score

	if not self.ranks[p.PTRound.rank+1] then return 0 end

	if self.ranks[p.PTRound.rank+1].canGet and not self.ranks[p.PTRound.rank+1].canGet(p) then return 0 end

	return FixedDiv((total_score-depletion)*FU, ((PTV3.maxrankrequirement*p.PTRound.rank)-depletion)*FU)
end

local sounds = {
	{
		up = sfx_rup1,
		down = sfx_rad1
	},
	{
		up = sfx_rup2,
		down = sfx_rad2
	},
	{
		up = sfx_rup3,
		down = sfx_rad3
	},
	{
		up = sfx_rup4,
		down = sfx_rad4
	},
	{
		up = sfx_rup5,
		down = sfx_rad5
	},
}

---@param p player_t
function PTV3:checkRank(p)
	if self:canGet(p, p.PTRound.rank+1) then
		if PTV3.ranks[p.PTRound.rank+1].rank == "P"
		and leveltime-p.PTRound.rank_changetime < 2*TICRATE then return end
		S_StartSound(nil, sounds[p.PTRound.rank].up, p)
		p.PTRound.rank = $+1
		p.PTRound.rank_changetime = leveltime
	end

	if PTV3.ranks[p.PTRound.rank-1]
	and not self:canGet(p, p.PTRound.rank) then
		p.PTRound.rank = $-1
		S_StartSound(nil, sounds[p.PTRound.rank].down, p)
		p.PTRound.rank_changetime = leveltime
	end
end