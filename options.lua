--------------------------------------------------------
-- Blood Legion Raidcooldowns - Options --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things really easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

function BLCD:SetupOptions()
	BLCD.options.args.profile = AceDBOptions:GetOptionsTable(BLCD.db)
	AceConfig:RegisterOptionsTable("BLCD", BLCD.options, nil)

	BLCD.optionsFrames = {}
	BLCD.optionsFrames.general = AceConfigDialog:AddToBlizOptions("BLCD", "Blood Legion Cooldown", nil, "general")
	BLCD.optionsFrames.cooldowns = AceConfigDialog:AddToBlizOptions("BLCD", "Cooldown Settings", "Blood Legion Cooldown", "cooldown")
	BLCD.optionsFrames.profile = AceConfigDialog:AddToBlizOptions("BLCD", "Profiles", "Blood Legion Cooldown", "profile")
end

local order = 0
local function getOrder()
	order = order + 1
	return order
end

BLCD.TexCoords = {.08, .92, .08, .92}

BLCD.defaults = {
	profile = {
		minimap = true,
		castannounce = false,
		cdannounce = false,
		announcechannel = false,
		clickannounce = false,
		scale = 1,
		xOffset = 0,
		yOffset = 0,
		framePoint = 'TOPLEFT',
		relativePoint = 'TOPLEFT',
		growth = "right",
		show = "raidorparty",
		autocheckextra = true,
		hideempty = true,
		availablebars = true,
		classcolorbars = false,
		barfill = false,
		barheight = 9,
		barwidth = 100,
		barfontsize = 11,
		battleres = true,
		cooldown = {
			PAL_AUMA = true,
			--PAL_AEOFLI = false,
			PAL_BLOFSA = false,
			PAL_BLOFPR = false,
			PAL_BLOFSPE = false,
			PRI_POWOBA = true,
			PRI_PASU = false,
			PRI_DIHY = true,
			PRI_GUSP = false,
			PRI_SYOFHO = true,
			PRI_VAEM = true,
			DRU_TR = true,
			DRU_IR = false,
			DRU_RE = false,
			--DRU_STRO = false,
			SHA_SPLITO = true,
			SHA_HETITO = true,
			SHA_AS = false,
			SHA_WIRUTO = false,
			--SHA_ANPRTO = false,
			--SHA_RE = false,
			SHA_ANGU = false,
			MON_LICO = false,
			MON_RE = true,
			WARL_SORE = true,
			DEA_GOGR = false,
			DEA_RAAL = false,
			WARR_COSH = false,
			MAG_TIWA = false,
			DEM_DA = true,
		},
	},
}

BLCD.options =  {
	type = "group",
	name = "Blood Legion Cooldown",
	args = {
		general = {
			order = getOrder(),
			type = "group",
			name = "General Settings",
			--inline = true,
			get = function(info) return BLCD.db.profile[info[#info]] end,
			set = function(info,value) BLCD.db.profile[info[#info]] = value; end,
			args = {
				show = {
					order = getOrder(),
					name = "Show Main Frame",
					type = 'select',
					set = function(info, value)
						BLCD.db.profile.show = value; BLCD:DynamicCooldownFrame(); BLCD:CheckVisibility()
					end,
					values = {
						['raidorparty'] = "Raid or Party",
						['raid'] = "Raid",
						['party'] = "Party (BG's/Arena included)",
						['never'] = "Never",
					},
				},
				minimap = {
					type = "toggle",
					name = "Minimap Button",
					order = getOrder(),
					set = function(info,value)
						BLCD.db.profile.minimap = value;
						if value then BLCD.minimapButton:Show("BLCD") else BLCD.minimapButton:Hide("BLCD") end
					end,
				},
				scale = {
					order = getOrder(),
					type = "range",
					name = 'Set Scale',
					desc = "Sets Scale of Raid Cooldowns",
					min = 0.3, max = 2, step = 0.01,
					set = function(info, value)
						BLCD.db.profile.scale = value;
						BLCD:Scale();
					end,
				},
				autocheckextra = {
					type = "toggle",
					name = "Automatically Check for Extras",
					desc = "Enabling this option will automatically filter out extra players in the raid.\n\nIf enabled only players in the first groups up to the maximum players allowed will be tracked by BLCD.\n\nYou can manually filter out extras with \"/blcd ext\" and you can resume showing all players with \"/blcd clrext\"",
					order = getOrder(),
					set = function(key, value)
						BLCD.db.profile.autocheckextra = value;
						BLCD:UpdateExtras();
					end,
				},
				hideempty = {
					type = "toggle",
					name = "Hide Empty Cooldowns",
					desc = "Hide the icons for cooldowns which no one in the raid has",
					order = getOrder(),
					set = function(key, value)
						BLCD.db.profile.hideempty = value;
						BLCD:DynamicCooldownFrame()
					end,
				},
				battleres = {
					type = "toggle",
					name = "Battle Res Monitor",
					desc = "Show the battle res monitor at the top of the frame",
					order = getOrder(),
					set = function(key, value)
						BLCD.db.profile.battleres = value;
					end,
				},
				announcegroup = {
					type = "group",
					name = "Announce Options",
					inline = true,
					args = {
						castannounce = {
							type = "toggle",
							name = "Announce Casts",
							order = getOrder(),
						},
						cdannounce = {
							type = "toggle",
							name = "Announce CD Expire",
							order = getOrder(),
						},
						clickannounce = {
							type = "toggle",
							name = "Click to Announce Available",
							order = getOrder(),
						},
						announcechannel = {
							order = getOrder(),
							name = "Announce to Custom Channel",
							desc = "Click the abilities icon to announce to raid whose coolddown is available",
							type = 'toggle',
						},
						customchan = {
							order = getOrder(),
							type = "input",
							name = "Channel Name",
							desc = "Channel you want to announce to",
						},
					},
				},
				bargroup = {
					type = "group",
					name = "Bar Options",
					inline = true,
					args = {
						barheight = {
							type = "range",
							name = "Bar Height",
							order = getOrder(),
							get = function () return BLCD.db.profile.barheight end,
							set = function (key, value) 
								BLCD.db.profile.barheight = value; BLCD:RestyleBars('height',value)
							end,
							min = 9,
							max = 25,
							step = 1,
						},
						barwidth = {
							type = "range",
							name = "Bar Width",
							order = getOrder(),
							get = function () return BLCD.db.profile.barwidth end,
							set = function (key, value) 
								BLCD.db.profile.barwidth = value; BLCD:RestyleBars('width',value)
							end,
							min = 50,
							max = 500,
							step = 1,
						},
						barfontsize = {
							type = "range",
							name = "Bar Font Size",
							order = getOrder(),
							get = function () return BLCD.db.profile.barfontsize end,
							set = function (key, value) 
								BLCD.db.profile.barfontsize = value; BLCD:RestyleBars('barfont',value)
							end,
							min = 9,
							max = 25,
							step = 1,
						},
						growth = {
							order = getOrder(),
							name = "Bar Grow Direction",
							type = 'select',
							set = function(info, value)
								BLCD.db.profile.growth = value; BLCD:UpdateBarGrowthDirection()
							end,
							values = {
								['left'] = "Left",
								['right'] = "Right",
							},
						},
						availablebars = {
							type = "toggle",
							name = "Ready bar mode",
							desc = "Always show bars",
							order = getOrder(),
							set = function(key, value)
								BLCD.db.profile.availablebars = value; BLCD:AvailableBars(value)
							end,
						},
						classcolorbars = {
							type = "toggle",
							name = "Class color bars",
							desc = "Color the cooldown bars according to class",
							order = getOrder(),
							set = function(key, value)
								BLCD.db.profile.classcolorbars = value; BLCD:RestyleBars('color', value)
							end,
						},
						barfill = {
							type = "toggle",
							name = "Bar drain/fill",
							desc = "Toggle the direction that the bars drain (default false = drain)",
							order = getOrder(),
							set = function(key, value)
								BLCD.db.profile.barfill = value; BLCD:RestyleBars('fill', value)
							end,
						},
					},
				},
			},
		},
		cooldown = {
			order = getOrder(),
			type = "group",
			name = "Cooldown Settings",
			cmdInline = true,
			get = function(info) return BLCD.db.profile.cooldown[info[#info]] end,
			set = function(info,value) BLCD.db.profile.cooldown[info[#info]] = value; BLCD:DynamicCooldownFrame() end,
			args = {
				paladin = {
					type = "group",
					name = "Paladin Cooldowns",
					order = getOrder(),
					args ={
						PAL_AUMA = {
							type = "toggle",
							name = "Aura Mastery",
							desc = "Empowers your chosen aura and increases its radius to 40 yards for 6 sec.",
							order = getOrder(),
						},
						--PAL_AEOFLI = {
						--	type = "toggle",
						--	name = "Aegis of Light",
						--	desc = "Channels an Aegis of Light that protects you and all allies standing within 10 yards behind you for 6 sec, reducing all damage taken by 20%.",
						--	order = getOrder(),
						--},
						PAL_BLOFSA = {
							type = "toggle",
							name = "Blessing of Sacrifice",
							desc = "Places a Blessing on a party or raid member, transferring 30% of damage taken to you for 12 sec, or until transferred damage would cause you to fall below 20% health.",
							order = getOrder(),
						},
						PAL_BLOFPR = {
							type = "toggle",
							name = "Blessing of Protection",
							desc = "Places a blessing on a party or raid member, protecting them from all physical attacks for 10 sec. Cannot be used on a target with Forbearance.\n\nCauses Forbearance for 30 sec.",
							order = getOrder(),
						},
						PAL_BLOFSPE = {
							type = "toggle",
							name = "Blessing of Spellwarding",
							desc = "Places a blessing on a party or raid member, protecting them from all magical attacks for 10 sec. Cannot be used on a target with Forbearance.  Causes Forbearance for 30 sec.",
							order = getOrder(),
						},
					},
				},
				priest = {
					type = "group",
					name = "Priest Cooldowns",
					order = getOrder(),
					args ={
						PRI_POWOBA = {
							type = "toggle",
							name = "Power Word: Barrier",
							desc = "Summons a holy barrier to protect all allies at the target location for 10 sec, reducing all damage taken by 25% and preventing damage from delaying spellcasting.",
							order = getOrder(),
						},
						PRI_PASU = {
							type = "toggle",
							name = "Pain Suppression",
							desc = "Reduces all damage taken by a friendly target by 40% for 8 sec. Castable while stunned.",
							order = getOrder(),
						},
						PRI_DIHY = {
							type = "toggle",
							name = "Divine Hymn",
							desc = "Heals all party or raid members within 40 yards for [5 * (144% of Spell power)] over 8 sec, and increases healing done to them by 10% for 8 sec. Healing increased by 100% when not in a raid.",
							order = getOrder(),
						},
						PRI_GUSP = {
							type = "toggle",
							name = "Guardian Spirit",
							desc = "Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 40% and preventing the target from dying by sacrificing itself.  This sacrifice terminates the effect and heals the target for 40% of maximum health. Castable while stunned.\n\nMassive damage amounts will kill the target despite this effect.",
							order = getOrder(),
						},
						PRI_SYOFHO = {
							type = 'toggle',
							name = "Symbol of Hope",
							desc = "Bolster the morale of all healers in your party or raid within 40 yards, allowing them to cast spells for no mana for 10 sec.",
							order = getOrder(),
						},
						PRI_VAEM = {
							type = 'toggle',
							name = "Vampiric Embrace",
							desc = "Fills you with the embrace of Shadow energy for 15 sec, causing you to heal a nearby ally for 40% of any single-target Shadow spell damage you deal.",
							order = getOrder(),
						},
					},
				},
				druid = {
					type = "group",
					name = "Druid Cooldowns",
					order = getOrder(),
					args ={
						DRU_TR = {
							type = "toggle",
							name = "Tranquility",
							desc = "Heals all allies within 40 yards for [5 * (180% of Spell power)] over 8 sec. Healing increased by 100% when not in a raid.",
							order = getOrder(),
						},
						DRU_IR = {
							type = "toggle",
							name = "Ironbark",
							desc = "The target's skin becomes as tough as Ironwood, reducing all damage taken by 20% for 12 sec.",
							order = getOrder(),
						},
						DRU_RE = {
							type = "toggle",
							name = "Rebirth",
							desc = "Returns the spirit to the body, restoring a dead target to life with 60% health and 20% mana.",
							order = getOrder(),
						},
						--[[DRU_STRO = {
							type = "toggle",
							name = "Stampeding Roar",
							desc = "The Druid roars, increasing the movement speed of all friendly players within 10 yards by 60% for 8 sec and removing all roots and snares on those targets.",
							order = getOrder(),
						},]]
					},
				},
				shaman = {
					type = "group",
					name = "Shaman Cooldowns",
					order = getOrder(),
					args ={
						SHA_SPLITO = {
							type = "toggle",
							name = "Spirit Link Totem",
							desc = "Summons a totem at the target location for 6 sec, which reduces damage taken by all party and raid members within 10 yards by 10%. Every 1 sec the health of all affected players is redistributed, such that all players are at the same percentage of maximum health.",
							order = getOrder(),
						},
						SHA_HETITO = {
							type = "toggle",
							name = "Healing Tide Totem",
							desc = "Summons a totem at your feet for 10 sec, which pulses every 2 sec, healing all party or raid members within 40 yards for (96% of Spell power).",
							order = getOrder(),
						},
						SHA_AS = {
							type = "toggle",
							name = "Ascendance",
							desc = "Transform into a Water Ascendant for 15 sec, causing all healing you deal to be duplicated and distributed evenly among nearby allies.",
							order = getOrder(),
						},
						SHA_WIRUTO = {
							type = "toggle",
							name = "Wind Rush Totem",
							desc = "Summons a totem at the target location for 15 sec, continually granting all allies who pass within 10 yards 60% increased movement speed for 5 sec.",
							order = getOrder(),
						},
						--SHA_ANPRTO = {
						--	type = "toggle",
						--	name = "Ancestral Protection Totem",
						--	desc = "Summons a totem at the target location for 30 sec. All allies within 20 yards of the totem gain 10% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with 20% health and mana.\n\nCannot reincarnate an ally who dies to massive damage.",
						--	order = getOrder(),
						--},
						--[[SHA_BL = {
							type = "toggle",
							name = "Bloodlust",
							desc = "Increases melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become Sated and be unable to benefit from Bloodlust or Time Warp again for 10 min.",
							order = getOrder(),
							disabled = function()
								return (UnitFactionGroup("player") ~= "Horde")
							end,
							get = function()
								if (UnitFactionGroup("player") ~= "Horde") then
									return false
								else
									return BLCD.db.profile.cooldown.SHA_BL
								end
							end,
							set = function(key, value)
								BLCD.db.profile.cooldown.SHA_BL = value; BLCD:DynamicCooldownFrame()
							end,
						},
						SHA_HE = {
							type = "toggle",
							name = "Heroism",
							desc = "Increases melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become Exhausted and be unable to benefit from Heroism or Time Warp again for 10 min.",
							order = getOrder(),
							disabled = function()
								return (UnitFactionGroup("player") ~= "Alliance")
							end,
							get = function()
								if (UnitFactionGroup("player") ~= "Alliance") then
									return false
								else
									return BLCD.db.profile.cooldown.SHA_HE
								end
							end,
							set = function(key, value)
								BLCD.db.profile.cooldown.SHA_HE = value; BLCD:DynamicCooldownFrame()
							end,
						},]]
						--[[SHA_RE = {
							type = "toggle",
							name = "Reincarnation",
							desc = "Allows you to resurrect yourself upon death with 20% health and mana.",
							order = getOrder(),
						},]]
					},
				},
				monk = {
					type = "group",
					name = "Monk Cooldowns",
					order = getOrder(),
					args ={
						MON_LICO = {
							type = "toggle",
							name = "Life Cocoon",
							desc = "Encases the target in a cocoon of Chi energy for 12 sec, absorbing [(((Spell power * 31.164) + 0)) * (1 + $versadmg)] damage and increasing all healing over time received by 50%.",
							order = getOrder(),
						},
						MON_RE = {
							type = "toggle",
							name = "Revival",
							desc = "Heals all party and raid members within 40 yards for (720% of Spell power) and clears them of all harmful Magical, Poison, and Disease effects.",
							order = getOrder(),
						},
					},
				},
				warlock = {
					type = "group",
					name = "Warlock Cooldowns",
					order = getOrder(),
					args ={
						WARL_SORE = {
							type = "toggle",
							name = "Soulstone Resurrection",
							desc = "When cast on living party or raid members, the soul of the target is stored and they will be able to resurrect upon death.\n\nIf cast on a dead target, they are instantly resurrected. Targets resurrect with 60% health and 20% mana.",
							order = getOrder(),
						},
					},
				},
				deathknight = {
					type = "group",
					name = "Death Knight Cooldowns",
					order = getOrder(),
					args ={
						DEA_GOGR = {
							type = "toggle",
							name = "Gorefiend's Grasp",
							desc = "Shadowy tendrils coil around all enemies within 20 yards of a hostile or friendly target, pulling them to the target's location.",
							order = getOrder(),
						},
						DEA_RAAL = {
							type = "toggle",
							name = "Raise Ally",
							desc = "Pours dark energy into a dead target, reuniting spirit and body to allow the target to reenter battle with 60% health and 20% mana.",
							order = getOrder(),
						},
					},
				},
				warrior = {
					type = "group",
					name = "Warrior Cooldowns",
					order = getOrder(),
					args ={
						WARR_COSH = {
							type = "toggle",
							name = "Commanding Shout",
							desc = "Lets loose a commanding shout, granting all party or raid members within 30 yards 15% increased maximum health for 10 sec. After this effect expires, the health is lost.",
							order = getOrder(),
						},
					},
				},
				mage = {
					type = "group",
					name = "Mage Cooldowns",
					order = getOrder(),
					args ={
						MAG_TIWA = {
							type = "toggle",
							name = "Time Warp",
							desc = "Warp the flow of time, increasing melee, ranged, and spell haste by 30% for all party and raid members. Lasts 40 sec.\n\nAllies receiving this effect will become unstuck in time, and be unable to benefit from Bloodlust, Heroism, or Time Warp again for 10 min.",
							order = getOrder(),
						},
					},
				},
				demonhunter = {
					type = "group",
					name = "Demon Hunter Cooldowns",
					order = getOrder(),
					args ={
						DEM_DA = {
							type = "toggle",
							name = "Darkness",
							desc = "Summons darkness around you in an 8 yd radius, cloaking friendly targets and granting a 15% chance to avoid all damage from an attack.  Lasts 8 sec.",
							order = getOrder(),
						},
					},
				},
			},
		},
	},
}

--------------------------------------------------------