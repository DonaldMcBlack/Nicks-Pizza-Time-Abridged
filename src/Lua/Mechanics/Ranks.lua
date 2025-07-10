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
			if PTV3.pizzatime or PTV3.minusworld then return p.ptv3
			and not p.ptv3.combo_dropped
			and p.ptv3.started_combo
			and abs(p.ptv3.laps) >= 2
			and p.ptv3.secretsfound >= #PTV3.secrets
			end
		end
	}

}

for i = 1,5 do
	sfxinfo[freeslot("sfx_rup"..i)].caption = "Ranked up!"
	sfxinfo[freeslot("sfx_rad"..i)].caption = "Ranked down!"
end

function PTV3:canGet(p, rank)
	if not (p and p.ptv3) then return end

	if not self.ranks[rank] then
		return false
	end

	if PTV3.ranks[rank].canGet and PTV3.ranks[rank].canGet(p) then return true end

	if p.score < PTV3.maxrankrequirement*(rank-1) then
		return false
	end

	if PTV3.ranks[rank].canGet
	and not PTV3.ranks[rank].canGet(p) then
		return false
	end

	return true
end

function PTV3:returnNextRankPercent(p)
	if not p.ptv3 then return end

	local depletion = PTV3.maxrankrequirement*(p.ptv3.rank-1)

	if not PTV3.ranks[p.ptv3.rank+1] then
		return 0
	end

	if PTV3.ranks[p.ptv3.rank+1].canGet
	and not PTV3.ranks[p.ptv3.rank+1].canGet(p) then
		return 0
	end

	return FixedDiv((p.score-depletion)*FU, ((PTV3.maxrankrequirement*p.ptv3.rank)-depletion)*FU)
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

function PTV3:checkRank(p)
	if self:canGet(p, p.ptv3.rank+1) then
		if PTV3.ranks[p.ptv3.rank+1].rank == "P"
		and leveltime-p.ptv3.rank_changetime < 2*TICRATE then return end
		S_StartSound(nil, sounds[p.ptv3.rank].up, p)
		p.ptv3.rank = $+1
		p.ptv3.rank_changetime = leveltime
	end

	if PTV3.ranks[p.ptv3.rank-1]
	and not self:canGet(p, p.ptv3.rank) then
		p.ptv3.rank = $-1
		S_StartSound(nil, sounds[p.ptv3.rank].down, p)
		p.ptv3.rank_changetime = leveltime
	end
end