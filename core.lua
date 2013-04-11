--------------------------------------------------------
-- Blood Legion Raidcooldowns - Core --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local CB = LibStub("LibCandyBar-3.0")
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.0")
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things relaly easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

local freebarbg = {}
local cooldownFrameicons = {}
local cooldownFrames = {}
local cooldownTimes = {}
--------------------------------------------------------
-- Raid Roster Functions --
--------------------------------------------------------
function BLCD:OnUpdate(event, info)
    local baseclass = info.class							  	
    local name = info.name
    local spec_id = info.global_spec_id
    local talents = info.talents
    local guid = info.guid
	if not baseclass or not guid or not spec_id or not talents or not guid then return end	
	local  _,classFilename = GetPlayerInfoByGUID(guid)
	
	BLCD['raidRoster'][guid] = BLCD['raidRoster'][guid] or {}
	BLCD['raidRoster'][guid]['name'] = name
	BLCD['raidRoster'][guid]['class'] = classFilename
	BLCD['raidRoster'][guid]['spec'] = spec_id
	BLCD['raidRoster'][guid]['talents'] = talents
end

function BLCD:OnRemove(guid)
	if(guid) then
	    BLCD['raidRoster'][guid] = nil
	else
		BLCD['raidRoster'] = {}
	end
end

function BLCD:UpdateRoster(cooldown)
	if(BLCD:GetPartyType() == "party" or BLCD:GetPartyType() == "raid") then

		for i, name in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
			if not(UnitInRaid(i) or UnitInParty(i)) or char['extra'] then
				BLCD.cooldownRoster[cooldown['spellID']][i] = nil
			end
		end
		
		local rosterCount = 0
		for i, char in pairs(BLCD['raidRoster']) do
			if (UnitInRaid(char['name']) or UnitInParty(char['name'])) and not char['extra'] then 
				if(string.lower(char["class"]:gsub(" ", ""))==string.lower(cooldown["class"]):gsub(" ", "")) then 
					if(cooldown["spec"] and char["spec"]) then
						if(char["spec"]==cooldown["spec"]) then 
							BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
							rosterCount = rosterCount + 1
						end
					elseif(cooldown["talent"] and char["talents"]) then
						if(char["talents"][cooldown["spellID"]]) then 
							BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
							rosterCount = rosterCount + 1
						end
					else
						BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
						rosterCount = rosterCount + 1
					end
				end
			else
				if(BLCD.cooldownRoster[cooldown['spellID']][i]) then
					BLCD.cooldownRoster[cooldown['spellID']][i] = nil
				end
			end
		end
		
		if BLCD.profileDB.hideempty then
			local frameicon = cooldownFrameicons[cooldown['spellID']]
			if frameicon then
				local frameparent = frameicon:GetParent()
				if frameparent then
					local index = frameparent.index
					local nextFrame = cooldownFrames[index+1]
					if rosterCount < 1 then
						frameparent:Hide()
						if nextFrame then
							nextFrame:ClearAllPoints()
							BLCD:BLPoint(nextFrame, 'TOPLEFT', frameparent, 'TOPLEFT', 0, 0);
						end
					else
						if nextFrame then
							nextFrame:ClearAllPoints()
							BLCD:BLPoint(nextFrame, 'TOPLEFT', frameparent, 'BOTTOMLEFT', 0, -4);
						end
						frameparent:Show()
					end
				end
			end
		end
	else
		BLCD.cooldownRoster[cooldown['spellID']] = {}
		BLCD.curr[cooldown['spellID']] = {}
	end
end

function BLCD:SetExtras(set)
	if set then
	local inInstance,_ = IsInInstance()
	local _,_,_,_,maxPlayers,_,_,_ = GetInstanceInfo()
	local maxSubgroup = 8
	
	if maxPlayers == 25 then
		maxSubgroup = 5
	elseif maxPlayers == 10 then
		maxSubgroup = 2
	end
	
	if IsInRaid() and inInstance then
	for i=1, GetNumGroupMembers(), 1 do
			local _,_,subgroup,_,_,_,_,_,_,_,_ = GetRaidRosterInfo(i)
			local guid = UnitGUID("raid"..tostring(i))
			if BLCD["raidRoster"] and BLCD["raidRoster"][guid] then
				if subgroup > maxSubgroup then
					BLCD["raidRoster"][guid]["extra"] = true
				else
					BLCD["raidRoster"][guid]["extra"] = nil
				end
			end
		end
		for i,cooldown in pairs(BLCD.cooldowns) do
			if (BLCD.db.profile.cooldown[cooldown.name] == true) then
				BLCD:UpdateRoster(cooldown)
				local frameicon = cooldownFrameicons[cooldown['spellID']]
				if frameicon then frameicon.text:SetText(BLCD:GetTotalCooldown(cooldown)) end
			end
		end
	end
	else
		for k,v in pairs(BLCD["raidRoster"]) do
			if BLCD["raidRoster"][k]["extra"] then
				BLCD["raidRoster"][k]["extra"] = nil
			end
		end
		for i,cooldown in pairs(BLCD.cooldowns) do
			if (BLCD.db.profile.cooldown[cooldown.name] == true) then
				BLCD:UpdateRoster(cooldown)
				local frameicon = cooldownFrameicons[cooldown['spellID']]
				if frameicon then frameicon.text:SetText(BLCD:GetTotalCooldown(cooldown)) end
			end
		end
	end
end

function BLCD:UpdateExtras()
	if not BLCD.profileDB.autocheckextra
		or not IsInRaid()
		or InCombatLockdown() then return end
		
	BLCD:SetExtras(true)
end
--------------------------------------------------------

-------------------------------------------------------
-- Frame Management --
-------------------------------------------------------
function BLCD:CreateBase()
	local raidcdbasemover = CreateFrame("Frame", 'BLCooldownBaseMover_Frame', UIParent)
	raidcdbasemover:SetClampedToScreen(true)
	BLCD:BLPoint(raidcdbasemover,'TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
	BLCD:BLSize(raidcdbasemover,32*BLCD.profileDB.scale,(96)*BLCD.profileDB.scale)
	if(Elv) then
		raidcdbasemover:SetTemplate()
	end
	raidcdbasemover:SetMovable(true)
	raidcdbasemover:SetFrameStrata("HIGH")
	raidcdbasemover:SetScript("OnDragStart", function(self) self:StartMoving() end)
	raidcdbasemover:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	raidcdbasemover:Hide()
	
	local raidcdbase = CreateFrame("Frame", 'BLCooldownBase_Frame', UIParent)
	BLCD:BLSize(raidcdbase,32*BLCD.profileDB.scale,(96)*BLCD.profileDB.scale)
	BLCD:BLPoint(raidcdbase,'TOPLEFT', raidcdbasemover, 'TOPLEFT')
	raidcdbase:SetClampedToScreen(true)
	
	BLCD:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 5, "UpdateExtras")
	
	BLCD.locked = true
	BLCD:CheckVisibility()
end

function BLCD:CreateCooldown(index, cooldown)
	local frame = CreateFrame("Frame", 'BLCooldown'..index, BLCooldownBase_Frame);
	BLCD:BLHeight(frame,28*BLCD.profileDB.scale);
	BLCD:BLWidth(frame,145*BLCD.profileDB.scale);	
	frame:SetClampedToScreen(true);
	frame.index = index

	local frameicon = CreateFrame("Button", 'BLCooldownIcon'..index, BLCooldownBase_Frame);
	
	if(Elv) then
		frameicon:SetTemplate()
	end
	
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	BLCD:BLSize(frameicon,28*BLCD.profileDB.scale,28*BLCD.profileDB.scale)
	frameicon:SetClampedToScreen(true);

	BLCD:SetBarGrowthDirection(frame, frameicon, index)
	
	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	BLCD:BLPoint(frameicon.icon,'TOPLEFT', 2, -2)
	BLCD:BLPoint(frameicon.icon,'BOTTOMRIGHT', -2, 2)

	frameicon.text = frameicon:CreateFontString(nil, 'OVERLAY')
	BLCD:BLFontTemplate(frameicon.text, 20*BLCD.profileDB.scale, 'OUTLINE')
	BLCD:BLPoint(frameicon.text, "CENTER", frameicon, "CENTER", 1, 0)
	cooldownFrameicons[cooldown['spellID']] = frameicon
	
	BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")

	LGIST.RegisterCallback (frame, "GroupInSpecT_Update", function(event, ...)
		BLCD:UpdateRoster(cooldown)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)

	LGIST.RegisterCallback (frame, "GroupInSpecT_Remove", function(event, ...)
		BLCD:UpdateRoster(cooldown)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)

	local function CleanBar(callback, bar)
		local a = bar:Get("raidcooldowns:anchor")
		if a and a.bars and a.bars[bar] then
			if (Elv) then
				local bg = bar:Get("raidcooldowns:elvbg")
				if (bg) then
					bg:ClearAllPoints()
					bg:SetParent(UIParent)
					bg:Hide()
					freebarbg[#freebarbg + 1] = bg
				end
			end
			local guid = bar:Get("raidcooldowns:key")
			local spell = bar:Get("raidcooldowns:spell")
			local cooldown = bar:Get("raidcooldowns:cooldown")
			local caster = bar:Get("raidcooldowns:caster")
			if BLCD['handles'] and BLCD["handles"][guid] and BLCD["handles"][guid][spell] then
				BLCD['handles'][guid][spell] = nil
			end
			bar:ClearAllPoints()
			bar:SetParent(UIParent)
			bar:Set("raidcooldowns:module", nil)
			bar:Set("raidcooldowns:anchor", nil)
			bar:Set("raidcooldowns:key", nil)
			bar:Set("raidcooldowns:spell", nil)
			bar:Set("raidcooldowns:cooldown", nil)
			bar:Set("raidcooldowns:caster", nil)
			a.bars[bar] = nil
			BLCD.curr[cooldown['spellID']][guid] = nil;
	
			if(BLCD.profileDB.cdannounce) then
				local name = select(1, GetSpellInfo(cooldown['spellID']))
				if(BLCD:GetPartyType()=="raid") then
					SendChatMessage(caster.."'s "..name.." CD UP" ,"RAID");
				elseif(BLCD:GetPartyType()=="party") then
					SendChatMessage(caster.."'s "..name.." CD UP" ,"PARTY");
				else
					SendChatMessage(caster.."'s "..name.." CD UP" ,"PARTY");
				end
			end
			
			BLCD:RearrangeBars(a)
			a.text:SetText(BLCD:GetTotalCooldown(cooldown))
		end
	end
	
	CB.RegisterCallback(self, "LibCandyBar_Stop", CleanBar)
	
	frameicon:SetScript("OnEnter", function(self,event, ...)
		BLCD:OnEnter(self, cooldown, BLCD.cooldownRoster[cooldown['spellID']], BLCD.curr[cooldown['spellID']])
   	end);
   
	frameicon:SetScript("PostClick", function(self,event, ...)
		BLCD:PostClick(self, cooldown, BLCD.cooldownRoster[cooldown['spellID']], BLCD.curr[cooldown['spellID']])
	end);  
    
 	frameicon:SetScript("OnLeave", function(self,event, ...)
		BLCD:OnLeave(self)
   	end);
	
	frame:SetScript("OnEvent", function(self,event, ...)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
 	end);
		
	frame:Show()
	
	return frame
end
--------------------------------------------------------

--------------------------------------------------------
-- Cooldown Management --
--------------------------------------------------------
function BLCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, eventType , _, soureGUID, soureName, _, _, destGUID, destName, _, _, spellId, spellName = select(1, ...)
		if(eventType == cooldown['succ'] and spellId == cooldown['spellID']) then
			if (BLCD['raidRoster'][soureGUID]  and not BLCD['raidRoster'][soureGUID]['extra']) then
				local duration = BLCD:getCooldownCD(cooldown,soureGUID)
				BLCD:StartCD(frame,cooldown,text,soureGUID,soureName,frameicon, spellName,duration)
	            text:SetText(BLCD:GetTotalCooldown(cooldown))
			end
		end
		if IsInRaid() and eventType == "UNIT_DIED" then
			local raidWiped = true
			local maxIndex = GetNumGroupMembers()
			local _,_,_,_,maxPlayers,_,_,_ = GetInstanceInfo()
			
			if maxPlayers and maxIndex > maxPlayers then
				maxIndex = maxPlayers
			end
			
			for i = 1, maxIndex, 1 do
				if not UnitIsDeadOrGhost("raid" .. i) then
					raidWiped = false
					break
				end
			end
		
			if raidWiped then
				BLCD:ResetWipe()
			end
		end
	elseif(event =="GROUP_ROSTER_UPDATE") then
	    local partyType = BLCD:GetPartyType()
	    if(partyType=="none") then
	        BLCD.curr[cooldown['spellID']]={}
	        BLCD.cooldownRoster[cooldown['spellID']] = {}
	        BLCD:CancelBars(frameicon)
	        BLCD:CheckVisibility()
	    end
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
    elseif(event =="GroupInSpecT_Update") then
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
    end
end

function BLCD:StartCD(frame,cooldown,text,guid,caster,frameicon,spell,duration)
	if(BLCD.profileDB.castannounce) then
		local name = select(1, GetSpellInfo(cooldown['spellID']))
		print(caster,name,duration)
		if(BLCD:GetPartyType()=="raid") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"RAID");
		elseif(BLCD:GetPartyType()=="party") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"PARTY");
		else
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"SAY");
		end
	end

	local bar = BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration,spell)
	
	if not(BLCD.curr[cooldown['spellID']][guid]) then
	    BLCD.curr[cooldown['spellID']][guid] = bar
    end
end

function BLCD:getCooldownCD(cooldown,soureGUID)
	local cd = cooldown['CD']
	if(BLCD.cooldownReduction[cooldown['name']]) then
		if(BLCD['raidRoster'][soureGUID]['spec'] == BLCD.cooldownReduction[cooldown['name']]['spec']) then
			cd = BLCD.cooldownReduction[cooldown['name']]['CD']
		end
	end
	
	return cd
end

function BLCD:GetTotalCooldown(cooldown)
	local cd = 0
	local cdTotal = 0
	
	for i,v in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
		cdTotal=cdTotal+1
	end
	
	for i,v in pairs(BLCD.curr[cooldown['spellID']]) do
		cd=cd+1
	end

	local total = (cdTotal-cd)
	if(total < 0) then
		total = 0
	end
		
	return total
end

function BLCD:BLCreateBG(frame)
	if(Elv) then
		local bg = nil
		if #freebarbg > 0 then
			bg = table.remove(freebarbg)
		else
			bg = CreateFrame("Frame");
		end
		bg:SetTemplate("Default")
		bg:SetParent(frame)
		bg:ClearAllPoints()
		bg:Point("TOPLEFT", frame, "TOPLEFT", -2, 2)
		bg:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
		bg:SetFrameStrata("MEDIUM")
		bg:Show()
		frame:Set("raidcooldowns:elvbg", bg)
	end
end

function BLCD:ResetAll()
	for spellId,guids in pairs(BLCD.curr) do
		for guid,bar in pairs(BLCD.curr[spellId]) do
			bar:Stop()
		end
	end
end

function BLCD:ResetWipe()
	for spellId,guids in pairs(BLCD.curr) do
		if cooldownTimes[spellId] >= 300 then
			for guid,bar in pairs(BLCD.curr[spellId]) do
				bar:Stop()
			end
		end
	end
end
--------------------------------------------------------

--------------------------------------------------------
-- Initialization --
--------------------------------------------------------
function BLCD:CreateRaidTables()
	BLCD.cooldownRoster = {}
	BLCD.raidRoster = {}
    BLCD.curr = {}
    BLCD.tmp = {}
	BLCD.handles = {}
	BLCD.frame_cache = {}
end

function BLCD:SlashProcessor_BLCD(input)
	local v1, v2 = input:match("^(%S*)%s*(.-)$")
	v1 = v1:lower()

	if v1 == "" then
		print("|cffc41f3bBlood Legion Cooldown|r:")
		print("/blcd opt - Open BLCD Options")
		print("/blcd lock - Lock/Unlock Cooldown Frame")
		print("/blcd show - Hide/Show Cooldown Frame")
		print("/blcd reset - Reset all running cooldowns")
		print("/blcd wipe - Reset after a wipe")
		print("/blcd ext - Manually filter extras in raid")
		print("/blcd clrext - Remove extra filtering (track all players)")
		print("---------------------------------------")
	elseif v1 == "lock" or v1 == "unlock" or v1 == "drag" or v1 == "move" or v1 == "l" then
		BLCD:ToggleMoversLock()
	elseif v1 == "show" then
		BLCD:ToggleVisibility()
	--elseif v1 == "raid" then
		--BLCD:print_raid()
	elseif v1 == "config" or v1 == "opt" then
		AceConfigDialog:Open("BLCD")
	elseif v1 == "extra" or v1 == "ext" then
		BLCD:SetExtras(true)
	elseif v1 == "clearextra" or v1 == "clrext" then
		BLCD:SetExtras()
	elseif v1 == "reset" then
		BLCD:ResetAll()
	elseif v1 == "wipe" then
		BLCD:ResetWipe()
	--elseif v1 == "dev" then
		--local _,_,_,_,maxPlayers,_,_,_ = GetInstanceInfo()
		--print(maxPlayers)
		--print("dev: "..tostring(true))
	else
		print("BLCD Unrecognized command")
		print("-------------------------")
	end
end

local count = 0
function BLCD:OnInitialize()
	if count == 1 then return end
	BLCD:RegisterChatCommand("BLCD", "SlashProcessor_BLCD")
	
	-- DB
	BLCD.db = AceDB:New("BLCDDB", BLCD.defaults, true)
	
	--self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	BLCD.profileDB = BLCD.db.profile
	BLCD:SetupOptions()
	
	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Update", function(event, ...)
		BLCD.OnUpdate(...)
	end)

	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Remove", function(...)
		BLCD.OnRemove(...)
	end)

	BLCD:CreateRaidTables()
	BLCD:CreateBase()

	local index = 0
	for i, cooldown in pairs(BLCD.cooldowns) do
		if (BLCD.db.profile.cooldown[cooldown.name] == true) then
			index = index + 1;
			BLCD.curr[cooldown['spellID']] = {}
			BLCD.cooldownRoster[cooldown['spellID']] = {}
			cooldownTimes[cooldown['spellID']] = cooldown['CD']
			cooldownFrames[index] = BLCD:CreateCooldown(index, cooldown);
		end
    end
	BLCD.active = index
	BLCD:CheckVisibility()

	count = 1
end

function BLCD:OnEnable()

end

function BLCD:OnDisable()

end
--------------------------------------------------------