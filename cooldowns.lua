--------------------------------------------------------
-- Blood Legion Cooldown - Cooldowns --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD

BLCD.cooldowns = {
-- Paladin
	{ -- Devotion Aura
		spellID = 31821,
		name = "PAL_DEAU",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 6,
		class = "PALADIN",
	},
	{ -- Hand of Sacrifice
		spellID = 6940,
		name = "PAL_HAOFSA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 120,
		cast = 12,
		class = "PALADIN",
	},
	{ -- Hand of Protection
		spellID = 1022,
		name = "PAL_HAOFPR",
		succ = "SPELL_CAST_SUCCESS",
		CD = 300,
		cast = 10,
		class = "PALADIN",
	},
	{ -- Holy Avenger
		spellID = 105809,
		name = "PAL_HOAV",
		succ = "SEPLL_CAST_SUCCESS",
		CD = 120,
		cast = 18,
		class = "PALADIN",
		talent = 5,
	},
	{ -- Hand of Salvation
		spellID = 105622,
		name = "PAL_HAOFSAL",
		succ = "SPELL_CAST_SUCCESS",
		CD = 120,
		cast = 10,
		class = "PALADIN",
	},
-- Priest
	{ -- Power Word: Barrier 
		spellID = 62618,
		name = "PRI_POWOBA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 10,
		class = "PRIEST",
		spec = 256,
	},
	{ -- Pain Suppression  
		spellID = 33206,
		name = "PRI_PASU",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 8,
		class = "PRIEST", 
		spec = 256,
	},
	{ -- Divine Hymn
		spellID = 64843,
		name = "PRI_DIHY",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180, 
		cast = 8,
		class = "PRIEST",
		spec = 257,
	},	
	{ -- Guardian Spirit 
		spellID = 47788,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_GUSP",
		CD = 180,
		cast = 10,
		class = "PRIEST", 
		spec = 257,
	},	
	{ -- Void Shift
		spellID = 108968,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_VOSH",
		CD = 360,
		class = "PRIEST",
	},
	{ -- Hymn Of Hope
		spellID = 64901,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_HYOFHO",
		CD = 360, 
		cast = 8,
		class = "PRIEST",
	},
	{ -- Vampiric Embrace
		spellID = 15286,
		succ = "SPELL_CAST_SUCCESS",
		name = "PRI_VAEM",
		CD = 180, 
		cast = 15,
		class = "PRIEST",
		spec = 258,
	},
-- Druid
	{ -- Tranquility
		spellID = 740,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_TR",
		CD = 480,
		cast = 8,
		class = "DRUID",
	},
	{ -- Ironbark
		spellID = 102342,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_IR",
		CD = 120,
		cast = 12,
		class = "DRUID",
		spec = 105,
	},
	{ -- Rebirth
		spellID = 20484,
		succ = "SPELL_RESURRECT",
		name = "DRU_RE",
		CD = 600,
		class = "DRUID",
	},
	{ -- Innervate
		spellID = 29166,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_IN",
		CD = 180,
		class = "DRUID",
	},
	{ -- Heart of the Wild
		spellID = 108288,
		succ = "SPELL_CAST_SUCCESS",
		name = "DRU_HEOFTHWI",
		CD = 360,
		class = "DRUID",
		talent = 6,
	},
-- Shaman
	{ -- Spirit Link Totem
		spellID = 98008,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_SPLITO",
		CD = 180,
		cast = 6,
		class = "SHAMAN", 
		spec = 264,
	},
	{ -- Mana Tide Totem
		spellID = 16190,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_MATITO",
		CD = 180,
		cast = 16,
		class = "SHAMAN",
		spec = 264,
	},
	{ -- Healing Tide Totem
		spellID = 108280,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_HETITO",
		CD = 180,
		cast = 10,
		class = "SHAMAN",
		talent = 5,
	},
	{ -- Stormlash Totem
		spellID = 120668,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_STTO",
		CD = 300,
		cast = 10,
		class = "SHAMAN",
	},
	{ -- Tremor Totem
		spellID = 8143,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_TRTO",
		CD = 60,
		cast = 6,
		class = "SHAMAN",
		talent = 5,
	},
	{ -- Bloodlust
		spellID = 2825,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_BL",
		CD = 300,
		cast = 40,
		class = "SHAMAN",
	},
	{ -- Heroism
		spellID = 32182,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_HE",
		CD = 300,
		cast = 40,
		class = "SHAMAN",
	},
	{ -- Reincarnation
		spellID = 20608,
		succ = "SPELL_RESURRECT",
		name = "SHA_RE",
		CD = 1800,
		class = "SHAMAN",
	},
	{ -- Ancestral Guidance
		spellID = 108281,
		succ = "SPELL_CAST_SUCCESS",
		name = "SHA_ANGU",
		cd = 120,
		class = "SHAMAN",
		talent = 5,
	},
 -- Monk
	{	-- Zen Meditation
		spellID = 115176,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_ZEME",
		CD = 180,
		cast = 8,
		class = "MONK",
	},
	{	-- Life Cocoon
		spellID = 116849,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_LICO",
		CD = 120,
		cast = 12,
		class = "MONK",
		spec = 270,
	},
	{	-- Revival
		spellID = 115310,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_RE",
		CD = 180,
		class = "MONK",
		spec = 270,
	},
	{	-- Avert Harm
		spellID = 115213,
		succ = "SPELL_CAST_SUCCESS",
		name = "MON_AVHA",
		CD = 180,
		cast = 6,
		class = "MONK",
		spec = 268,
	},
-- Warlock
	{ -- Soulstone Resurrection
		spellID = 95750,
		succ = "SPELL_RESURRECT",
		name = "WARL_SORE",
		CD = 600,
		class = "WARLOCK",
	},
-- Death Knight
	{ -- Raise Ally
		spellID = 61999,
		succ = "SPELL_RESURRECT", 
		name = "DEA_RAAL",
		CD = 600,
		class = "DEATHKNIGHT",
	},
	{ -- Anti-Magic Zone
		spellID = 51052,
		succ = "SPELL_CAST_SUCCESS",
		name = "DEA_ANMAZO",
		CD = 120,
		cast = 10,
		class = "DEATHKNIGHT",
		talent = 2,
	},
-- Warrior
	{ -- Rallying Cry
		spellID = 97462,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_RACR",
		CD = 180,
		cast = 10,
		class = "WARRIOR",
	},
	{ -- Demoralizing Banner
		spellID = 114203,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_DEBA",
		CD = 180,
		cast = 15,
		class = "WARRIOR",
	},
	{ -- Skull Banner
		spellID = 114207,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_SKBA",
		CD = 180,
		cast = 10,
		class = "WARRIOR",
	},
	{ -- Vigilance
		spellID = 114030,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_VI",
		CD = 120,
		cast = 12,
		class = "WARRIOR",
		talent = 5,
	},
	{ -- Shattering Throw
		spellID = 64382,
		succ = "SPELL_CAST_SUCCESS",
		name = "WARR_SHTH",
		CD = 300,
		cast = 10,
		class = "WARRIOR",
	},
-- Mage
	{ -- Time Warp
		spellID = 80353,
		succ = "SPELL_CAST_SUCCESS",
		name = "MAG_TIWA",
		CD = 300,
		cast = 40,
		class = "MAGE",
	},
-- Rogue
	{ -- Smoke Bomb
		spellID = 76577,
		succ = "SPELL_CAST_SUCCESS",
		name = "ROG_SMBO",
		CD = 180,
		cast = 5,
		class = "ROGUE",
	},
}
--------------------------------------------------------

BLCD.cooldownReduction = {
	["DRU_TR"] = { -- Tranquility
				spellID = 740,
				CD = 180,
				spec = 105,
			},
}