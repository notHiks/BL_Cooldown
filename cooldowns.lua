--------------------------------------------------------
-- Blood Legion Cooldown - Cooldowns --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD

local index = 0
local function getIndex()
	index = index + 1
	return index
end

BLCD.cooldowns = {
-- Paladin
	[31821] = { -- Aura mastery
		spellID = 31821,
		name = "PAL_AUMA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 8,
		class = "PALADIN",
		spec = 65,
		index = getIndex(),
	},
	[204150] = { -- Aegis of Light
		spellID = 204150,
		name = "PAL_AEOFLI",
		succ = "SPELL_CAST_SUCCESS",
		CD = 300,
		cast = 6,
		class = "PALADIN",
		spec = 70,
		index = getIndex(),
	},
	[6940] = { -- Blessing of Sacrifice
		spellID = 6940,
		name = "PAL_BLOFSA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 121.5,
		cast = 12,
		class = "PALADIN",
		notspec = 70,
		index = getIndex(),
	},
	[1022] = { -- Blessing of Protection
		spellID = 1022,
		name = "PAL_BLOFPR",
		succ = "SPELL_CAST_SUCCESS",
		CD = 301.5,
		cast = 10,
		class = "PALADIN",
		index = getIndex(),
	},
	[105809] = { -- Holy Avenger
		spellID = 105809,
		name = "PAL_HOAV",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 20,
		class = "PALADIN",
		talent = 5,
		talentidx = 17599,
		index = getIndex(),
	},
	[204108] = { -- Blessing of Spellwarding
		spellID = 204018,
		name = "PAL_BLOFSPE",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 10,
		class = "PALADIN",
		spec = 66,
		index = getIndex(),
	},
-- Priest
	[62618] = { -- Power Word: Barrier
		spellID = 62618,
		name = "PRI_POWOBA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 10,
		class = "PRIEST",
		spec = 256,
		index = getIndex(),
	},
	[33206] = { -- Pain Suppression
		spellID = 33206,
		name = "PRI_PASU",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 8,
		class = "PRIEST",
		spec = 256,
		index = getIndex(),
	},
	[64843] = { -- Divine Hymn
		spellID = 64843,
		name = "PRI_DIHY",
		succ = "SPELL_CAST_SUCCESS",
		CD = 181.5,
		cast = 8,
		class = "PRIEST",
		spec = 257,
		index = getIndex(),
	},
	[47788] = { -- Guardian Spirit
		spellID = 47788,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_GUSP",
		CD = 181.5,
		cast = 10,
		class = "PRIEST",
		spec = 257,
		index = getIndex(),
	},
	[64901] = { -- Symbol of Hope
		spellID = 64901,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_SYOFHO",
		CD = 301.5,
		cast = 5,
		class = "PRIEST",
		spec = 257,
		talentidx = 21752,
		index = getIndex(),
	},
	[15286] = { -- Vampiric Embrace
		spellID = 15286,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_VAEM",
		CD = 121.5,
		cast = 15,
		class = "PRIEST",
		spec = 258,
		index = getIndex(),
	},
-- Druid
	[740] = { -- Tranquility
		spellID = 740,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_TR",
		CD = 181.5,
		cast = 8,
		class = "DRUID",
		spec = 105,
		index = getIndex(),
	},
	[102342] = { -- Ironbark
		spellID = 102342,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_IR",
		CD = 91.5,
		cast = 12,
		class = "DRUID",
		spec = 105,
		index = getIndex(),
	},
	[20484] = { -- Rebirth
		spellID = 20484,
		succ = "SPELL_RESURRECT",
		name = "DRU_RE",
		CD = 601.5,
		class = "DRUID",
		index = getIndex(),
	},
	--[[[77761] = { -- Stampeding Roar
		spellID = 77761,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_STRO",
		CD = 120,
		cast = 8,
		spec = ,
		notspec = ,
		class = "DRUID",
		index = getIndex(),
	},]]
-- Shaman
	[98008] = { -- Spirit Link Totem
		spellID = 98008,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_SPLITO",
		CD = 181.5,
		cast = 6,
		class = "SHAMAN",
		spec = 264,
		index = getIndex(),
	},
	[108280] = { -- Healing Tide Totem
		spellID = 108280,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_HETITO",
		CD = 181.5,
		cast = 10,
		class = "SHAMAN",
		spec = 264,
		index = getIndex(),
	},
	[114052] = { -- Ascendance
		spellID = 114052,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_AS",
		CD = 181.5,
		cast = 15,
		class = "SHAMAN",
		talentidx = 21970,
		spec = 264,
		index = getIndex(),
	},	
	[192077] = { -- Wind Rush Totem
		spellID = 192077,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_WIRUTO",
		CD = 121.5,
		cast = 12,
		talentidx = 21963,
		class = "SHAMAN",
		index = getIndex(),
	},
	--[207339] = { -- Ancestral Protection Totem
	--	spellID = 207339,
	--	succ = "SPELL_CAST_SUCCESS",
	--	name = "SHA_ANPRTO",
	--	CD = 300,
	--	cast = 30,
	--	talentidx = 22539,
	--	class = "SHAMAN",
	--	index = getIndex(),
	--},
	--{ -- Reincarnation  -- Needs work, currently doesn't show in combatlog. Thanks blizz.
		--spellID = 20608,
		--succ = "SPELL_RESURRECT",
		--name = "SHA_RE",
		--CD = 1800,
		--class = "SHAMAN",
	--},
	[108281] = { -- Ancestral Guidance
		spellID = 108281,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_ANGU",
		CD = 121.5,
		cast = 10,
		class = "SHAMAN",
		talent = 5,
		talentidx = 19269,
		index = getIndex(),
	},
 -- Monk
	[116849] = {	-- Life Cocoon
		spellID = 116849,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_LICO",
		CD = 121.5,
		cast = 12,
		class = "MONK",
		spec = 270,
		index = getIndex(),
	},
	[115310] = {	-- Revival
		spellID = 115310,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_RE",
		CD = 181.5,
		class = "MONK",
		spec = 270,
		index = getIndex(),
	},
-- Warlock
	[20707] = { -- Soulstone Resurrection
		spellID = 20707,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARL_SORE",
		CD = 601.5,
		class = "WARLOCK",
		index = getIndex(),
	},
-- Death Knight
	[108199] = { -- Gorefiend's Grasp
		spellID = 108199,
		succ = "SPELL_CAST_SUCCESS",
		name = "DEA_GOGR",
		CD = 121.5,
		spec = 250,
		class = "DEATHKNIGHT",
		index = getIndex(),
	},
	[61999] = { -- Raise Ally
		spellID = 61999,
		succ = "SPELL_RESURRECT",
		name = "DEA_RAAL",
		CD = 601.5,
		class = "DEATHKNIGHT",
		index = getIndex(),
	},
-- Warrior
	[97462] = { -- Commanding Shout
		spellID = 97462,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_COSH",
		CD = 181.5,
		cast = 10,
		class = "WARRIOR",
		notspec = 73,
		index = getIndex(),
	},
-- Mage
	[80353] = { -- Time Warp
		spellID = 80353,
		succ = "SPELL_CAST_SUCCESS",
		name = "MAG_TIWA",
		CD = 301.5,
		cast = 40,
		class = "MAGE",
		index = getIndex(),
	},
-- Demon Hunter
	[196718] = { -- Darkness
		spellID = 196718,
		succ = "SPELL_CAST_SUCCESS",
		name = "DEM_DA",
		CD = 301.5,
		cast = 8,
		class = "DEMONHUNTER",
		index = getIndex(),
	},
}

BLCD.cooldownReduction = {
	--[["PAL_HAOFSA"] = {
				spellID = 6940,
				CD = 90,
				spec = 70,
			},]]
}
--------------------------------------------------------