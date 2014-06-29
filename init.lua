--------------------------------------------------------
-- Blood Legion Raidcooldowns - Initialization --
--------------------------------------------------------
local name = "BL_Cooldown"
BLCD = LibStub("AceAddon-3.0"):NewAddon(name, "AceEvent-3.0", "AceConsole-3.0", "AceBucket-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

if not BLCD then return end

if not BLCD.events then
	BLCD.events = LibStub("CallbackHandler-1.0"):New(BLCD)
end

local frame = BLCD.frame
if (not frame) then
	frame = CreateFrame("Frame", name .. "_Frame")
	BLCD.frame = frame
end

BLCD.frame:UnregisterAllEvents()
BLCD.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
BLCD.frame:RegisterEvent("ADDON_LOADED")
BLCD.frame:RegisterEvent("PLAYER_LOGOUT")

BLCD.frame:SetScript("OnEvent", function(this, event, ...) return BLCD[event](BLCD, ...) end)


function BLCD:ADDON_LOADED(name)
	if (name == "BL_Cooldown") then
		print("|cffc41f3bBlood Legion Cooldown|r: version 3.52 /blcd for options")
	end
end

--------------------------------------------------------