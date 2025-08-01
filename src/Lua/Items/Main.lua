local files = {
	"Banana",
	"Shotgun"
}

local function DummyFunc()
	CONS_Printf(consoleplayer, "If you triggered this, you didn't define this properly.")
end

local ITEM_STRUCT = {
	id = "thok",

	displayname = "Thok",
	graphic = { name = "SPR2_ROLL", offset_x = -3*FU, offset_y = -9*FU, scale = FU/2 },

	mobj = MT_THOK,
	state = S_THOK,
	use = DummyFunc,
	equipable = false,

	timeleft = -1,

	max_hit = 0,
	max_cooldown = 0,
	max_anim = TICRATE,
	max_ammo = 3,

	hit = 0,
	anim = 0,
	cooldown = 0,
	ammo = 1,

	range = FU*2,

	pos = {x = 0, y = 0, z = 0},
	default_pos = {x = 0, y = 0, z = 0},
	anim_pos = {x = 0, y = 0, z = 0},

	equip_sfx = sfx_thok,

	stick = true,
	hiddenforothers = false,
	showinfirstperson = false,
	
	animation = true,
	weaponize = true,
	droppable = false,
	shootable = false,
	shootmobj = MT_THOK,
	nostrafe = false,
	rapidfire = false,
	aimtrail = false,

	bullets = {} -- save valid bullets here
}

PTV3.items = {}

-- Loads item tables from the array. See results in latest-log.txt if there's any errors.
function PTV3:CreateItem(item, filename)
	if not item then error(filename.." not found.") end
	if type(item) ~= "table" then error(filename.." is not a table.") end

	for k,v in pairs(ITEM_STRUCT) do
		if item[k] == nil
		or type(item[k]) ~= type(ITEM_STRUCT[k]) then
			--these are debugging messages, so only print if so
			if (devparm) then
				if item[k] == nil then
					print(tostring(k).." is nil. It has been corrected to the default property from ITEM_DEF.")
					print("Ignore this notification unless you are the dev and know that something is wrong.")
				else
					print(tostring(k).." is not the same type as the default. It has been corrected to the default property from ITEM_DEF.")
				end
				print("View pk3/Lua/Items/main.lua for more information.")
			end
			
			item[k] = ITEM_STRUCT[k]
		end
	end
	
	self.items[item.id] = item
	print("PTV3 item: "..self.items[item.id].displayname.." found!")
end

-- Create the mobj for the item you can equip.
function PTV3:MakeItemMobj(mo, item)
	local rawitem = self.items[item]
	if not rawitem.equipable then return end

	local mobj = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)

	mobj.tics, mobj.fuse = -1, -1
	mobj.state = rawitem.state
	mobj.flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOTHINK|MF_NOCLIP|MF_NOCLIPHEIGHT
	mobj.flags2 = MF2_DONTDRAW

	CONS_Printf(mo.player, "Mobj Created")

	return mobj
end

-- Give a player an item of the specified ID. Returns false if invalid.
function PTV3:GiveItem(p, item_input)
	if not (p and p.valid and p.ptv3) then return end

	local input_valid = type(item_input) == "string" and true or false

	if not item_input or (input_valid and item_input and not self.items[item_input]) then
		return false
	else
		p.ptv3.curItem = item_input
	end
end

function PTV3:UseEquipableItem(p)
	if not (p.mo and p.ptv3 and p.ptv3.curItem) then return end
	if not (p.ptv3.curItem_mobj and p.ptv3.curItem_mobj.valid) then return end

	local rawitem = self.items[p.ptv3.curItem]
	if not rawitem.equipable then return end

	if rawitem.use then
		rawitem.use(p, p.ptv3.curItem_mobj)
	end
	
	if rawitem.ammo > 0 then
		rawitem.ammo = $-1
	elseif rawitem.ammo == -1 then return
	else
		P_RemoveMobj(p.ptv3.curItem_mobj)
		p.ptv3.curItem = nil
		p.ptv3.curItem_equipped = false
	end
end

function PTV3:InstantUseItem(p)
	if not (p.mo and p.ptv3 and p.ptv3.curItem) then return end

	local rawitem = self.items[p.ptv3.curItem]
	if rawitem.equipable then return end

	local item = P_SpawnMobjFromMobj(p.mo, 0,0,0, rawitem.mobj)
	item.target = p.mo

	if rawitem.use then
		rawitem.use(item, p.mo)
	end
	
	if rawitem.ammo > 0 then
		rawitem.ammo = $-1
		if rawitem.ammo then return end
	end

	PTV3:logEvent(p.name.." has used "..rawitem.displayname.."!")
	
	p.ptv3.curItem = nil
	p.ptv3.curItem_equipped = false
end

for _,i in ipairs(files) do
	PTV3:CreateItem(dofile("Items/"..i), i)
end