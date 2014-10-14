--------------------------------------------------------
-- Blood Legion Raidcooldowns - Core --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local CB = LibStub("LibCandyBar-3.0")
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things really easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

local Elv = IsAddOnLoaded("ElvUI")
local commPrefix = "BLCD"
local BLCD_VERSION = tonumber(GetAddOnMetadata("BL_Cooldown", "Version")) or 0

local E, L, V, P, G
if(Elv) then
	E, L, V, P, G = unpack(ElvUI);
end

local UnitInRaid, UnitInParty, IsInRaid, IsInGroup, UnitIsDeadOrGhost, UnitIsConnected, GetPlayerInfoByGUID, GetNumGroupMembers, GetRaidRosterInfo, UnitGUID, UnitName, UnitIsUnit =
      UnitInRaid, UnitInParty, IsInRaid, IsInGroup, UnitIsDeadOrGhost, UnitIsConnected, GetPlayerInfoByGUID, GetNumGroupMembers, GetRaidRosterInfo, UnitGUID, UnitName, UnitIsUnit
local ipairs, pairs, unpack, print, type =
      ipairs, pairs, unpack, print, type
local cooldownFrameicons = {}
local cooldownFrames = {}
local cooldownTimes = {}
local cooldownNames = {}
local cooldownIndex = {}
local LList = {}
local usersRelease = {}
local resCount = 1

--------------------------------------------------------
-- Raid Roster Functions --
--------------------------------------------------------
function BLCD:OnLGIST(event, guid, unit, info)
	if event == "GroupInSpecT_Update" then
		local baseclass = info.class
		local name = info.name
		local spec_id = info.global_spec_id
		local talents = info.talents
		if not baseclass or not guid or not spec_id or not talents or not guid then return end
		local  _,classFilename = GetPlayerInfoByGUID(guid)

		BLCD['raidRoster'][guid] = BLCD['raidRoster'][guid] or {}
		BLCD['raidRoster'][guid]['name'] = name
		BLCD['raidRoster'][guid]['class'] = classFilename
		if spec_id ~= 0 then BLCD['raidRoster'][guid]['spec'] = spec_id end
		if next(talents) ~= nil then BLCD['raidRoster'][guid]['talents'] = talents end
	elseif event == "GroupInSpecT_Remove" then
		if (guid) then
			BLCD['raidRoster'][guid] = nil
		else
			BLCD['raidRoster'] = {}
		end
	end
end

local function hasHoTW(guid)
	local char = BLCD['raidRoster'][guid]
	if char['talents'][18584] or char['talents'][21714] or char['talents'][21715] or char['talents'][21716] then
		return true
	else
		return false
	end
end

function BLCD:UpdateRoster(cooldown)
	local bar
	--local time1 = debugprofilestop()
	local grouptype = BLCD:GetPartyType()
	local sologroup = (grouptype == "none" and (BLCD.profileDB.show == "solo" or BLCD.profileDB.show == "always"))
	if(grouptype == "party" or grouptype == "raid" or grouptype == "instance" or sologroup) then
		local guid, name, char
		for guid, name in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
			if not(UnitInRaid(name) or UnitInParty(name)) or guid['extra'] then
				BLCD.cooldownRoster[cooldown['spellID']][guid] = nil
				if BLCD.profileDB.availablebars then
					BLCD:StopPausedBar(cooldown,guid)
				end
			
			end
		end

		local rosterCount = 0
		for guid, char in pairs(BLCD['raidRoster']) do
			if (UnitInRaid(char['name']) or UnitInParty(char['name'])) and not char['extra'] or sologroup then
				if(string.lower(char["class"]:gsub(" ", ""))==string.lower(cooldown["class"]):gsub(" ", "")) then
					local unitalive = (not UnitIsDeadOrGhost(char['name'])) and UnitIsConnected(char['name'])
					if(cooldown["spec"] and char["spec"]) then
						if(char["spec"]==cooldown["spec"]) then
							BLCD.cooldownRoster[cooldown['spellID']][guid] = char['name']
							rosterCount = rosterCount + 1
						end
					elseif(cooldown["talent"] and char["talents"]) then
						if(char["talents"][cooldown["talentidx"]]) then
							BLCD.cooldownRoster[cooldown['spellID']][guid] = char['name']
							rosterCount = rosterCount + 1
						end
						if cooldown['name'] == "DRU_HEOFTHWI" then
							if hasHoTW(guid) then
								BLCD.cooldownRoster[108291][guid] = char['name']
								rosterCount = rosterCount + 1
							end
						end
					elseif(not cooldown["spec"] and not cooldown["talent"] and cooldown["class"] == char["class"]) then
						BLCD.cooldownRoster[cooldown['spellID']][guid] = char['name']
						rosterCount = rosterCount + 1
					end

					if BLCD.profileDB.availablebars then
						if BLCD.profileDB.cooldown[cooldown.name] and unitalive and
							((cooldown["spec"] and char["spec"] and char["spec"] == cooldown["spec"] or (cooldown["notspec"] and char["spec"] and char["spec"] ~= cooldown["notspec"])) or 
							(cooldown["talent"] and char["talents"] and (char["talents"][cooldown["talentidx"]] or hasHoTW(guid))) or
							(not cooldown["spec"] and not cooldown["talent"] and cooldown["class"] == char["class"])) then
							BLCD:CreatePausedBar(cooldown,guid)
						elseif(unitalive and BLCD.cooldownRoster[cooldown["spellID"]][guid]) then
							BLCD.cooldownRoster[cooldown['spellID']][guid] = nil
							BLCD:StopPausedBar(cooldown,guid)
						end
					end

				end
			else
				if not char['extra'] then
					BLCD.raidRoster[guid] = nil
				end
				if(BLCD.cooldownRoster[cooldown['spellID']][guid]) then
					BLCD.cooldownRoster[cooldown['spellID']][guid] = nil
					BLCD:StopPausedBar(cooldown,guid)
				end
			end
		end

		if BLCD.profileDB.hideempty then
			local i = cooldown.index
			if BLCD.profileDB.cooldown[cooldown.name] then
				if rosterCount < 1 and cooldownIndex[i] ~= nil then
					--BLCD:HandleEvents(cooldownFrames[i],false)
					BLCD:RemoveFrame(cooldownFrames[i],cooldownIndex[i]['previous'],cooldownIndex[i]['next'], cooldownFrames)
					BLCD:RemoveNode(cooldownIndex[i])
					cooldownIndex[i] = nil
				end

				if rosterCount > 0 and cooldownIndex[i] == nil then
					cooldownIndex[i] = {}
					if LList.head == nil then
						BLCD:InsertBeginning(cooldownIndex[i],i)
					else
						BLCD:InsertNode(cooldownIndex[i],i)
					end
					BLCD:InsertFrame(cooldownFrames[i],cooldownIndex[i]['previous'],cooldownIndex[i]['next'], cooldownFrames)
					--BLCD:HandleEvents(cooldownFrames[i],true)
				end
			end
		end
	else
		BLCD.cooldownRoster[cooldown['spellID']] = {}
		BLCD:StopAllBars()
		BLCD.curr[cooldown['spellID']] = {}
		BLCD.tmp = {}
	end
	--BLCD:RedrawCDList()
	BLCD:RearrangeBars(cooldownFrameicons[cooldown['spellID']])
end

function BLCD:DebugFunc()
	--[[for id,tabl in pairs(BLCD.cooldownRoster) do
		for guid,name in pairs(tabl) do
			print('check ', name)
			self:CheckPausedBars(BLCD.cooldowns[id],name)
		end
	end]]
	BLCD:ResetBRes(true)
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
			local i, cooldown
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
				if (BLCD.profileDB.cooldown[cooldown.name] == true) then
					BLCD:UpdateRoster(cooldown)
					local frameicon = cooldownFrameicons[cooldown['spellID']]
					if frameicon then frameicon.text:SetText(BLCD:GetTotalCooldown(cooldown)) end
				end
			end
		end
	else
		local k, v, i, cooldown
		for k,v in pairs(BLCD["raidRoster"]) do
			if BLCD["raidRoster"][k]["extra"] then
				BLCD["raidRoster"][k]["extra"] = nil
			end
		end
		for i,cooldown in pairs(BLCD.cooldowns) do
			if (BLCD.profileDB.cooldown[cooldown.name] == true) then
				BLCD:UpdateRoster(cooldown)
				local frameicon = cooldownFrameicons[cooldown['spellID']]
				if frameicon then frameicon.text:SetText(BLCD:GetTotalCooldown(cooldown)) end
			end
		end
	end
end

local grouped = nil
function BLCD:GROUP_ROSTER_UPDATE()
	BLCD:CheckVisibility()
	local groupType = (IsInGroup(2) and 3) or (IsInRaid() and 2) or (IsInGroup() and 1) -- LE_PARTY_CATEGORY_INSTANCE = 2
	if (not grouped and groupType) or (grouped and groupType and grouped ~= groupType) then
		grouped = groupType
		SendAddonMessage("BLCD", ("VQ:%.2f"):format(BLCD_VERSION), groupType == 3 and "INSTANCE_CHAT" or "RAID")
	elseif grouped and not groupType then
		grouped = nil
		wipe(usersRelease)
	end
end

function BLCD:UpdateExtras()
	if not BLCD.profileDB.autocheckextra
		or not IsInRaid()
		 then return end

	BLCD:SetExtras(true)
end
--------------------------------------------------------

-------------------------------------------------------
-- Frame Management --
-------------------------------------------------------
function BLCD:CreateBase()
	local raidcdbasemover = CreateFrame("Frame", 'BLCooldownBaseMover_Frame', UIParent)
	raidcdbasemover:SetClampedToScreen(true)
	raidcdbasemover:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                            edgeFile = nil,
                                            tile = true, tileSize = 16, edgeSize = 16,
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	raidcdbasemover:SetBackdropColor(0,0,0,1)
	BLCD:BLPoint(raidcdbasemover,BLCD.profileDB.framePoint,UIParent,BLCD.profileDB.relativePoint,BLCD.profileDB.xOffset,BLCD.profileDB.yOffset)
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

	BLCD:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 3, "UpdateExtras")

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
	else
		frameicon:SetBackdrop({nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0}})
	end
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	BLCD:BLSize(frameicon,28*BLCD.profileDB.scale,28*BLCD.profileDB.scale)
	frameicon:SetClampedToScreen(true);

	local previousIndex = cooldownIndex[index].previous
	BLCD:SetBarGrowthDirection(frame, frameicon, previousIndex)

	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	BLCD:BLPoint(frameicon.icon,'TOPLEFT', 2, -2)
	BLCD:BLPoint(frameicon.icon,'BOTTOMRIGHT', -2, 2)

	frameicon.text = frameicon:CreateFontString(nil, 'OVERLAY')
	BLCD:BLFontTemplate(frameicon.text, 20*BLCD.profileDB.scale, 'OUTLINE')
	BLCD:BLPoint(frameicon.text, "CENTER", frameicon, "CENTER", 1, 0)
	
	local id = cooldown['spellID']
	if id == 20484 or id == 20707 or id == 61999 then
		frameicon.cooldown = CreateFrame("Cooldown", "BLCooldownIcon"..index.."Cooldown", frameicon, "CooldownFrameTemplate")
		frameicon.cooldown:SetAllPoints()
		frameicon.cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill-Upgrade")
	end
	cooldownFrameicons[cooldown['spellID']] = frameicon
	
	--BLCD:UpdateCooldown(frame,event,cooldown,frameicon.text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:RegisterEvent("PARTY_MEMBER_ENABLE")
	frame:RegisterEvent("PARTY_MEMBER_DISABLE")
	frame:RegisterEvent("UNIT_CONNECTION")
	frame:RegisterEvent("UNIT_HEALTH")

	LGIST.RegisterCallback (frame, "GroupInSpecT_Update", function(event, ...)
		-- Delay these as it's creating a race condition with the callback set up in OnInitialization()
		BLCD:ScheduleTimer("UpdateRoster", .4, cooldown)
		BLCD:ScheduleTimer("UpdateCooldown", .5, frame,event,cooldown,frameicon.text,frameicon, ...)
		--BLCD:UpdateRoster(cooldown)
		--BLCD:UpdateCooldown(frame,event,cooldown,frameicon.text,frameicon, ...)
	end)

	LGIST.RegisterCallback (frame, "GroupInSpecT_Remove", function(event, ...)
		BLCD:ScheduleTimer("UpdateRoster", .4, cooldown)
		BLCD:ScheduleTimer("UpdateCooldown", .5, frame,event,cooldown,frameicon.text,frameicon, ...)
		--BLCD:UpdateRoster(cooldown)
		--BLCD:UpdateCooldown(frame,event,cooldown,frameicon.text,frameicon, ...)
	end)

	local function CleanBar(callback, bar)
	local a = bar:Get("raidcooldowns:anchor") --'a' is frameicon
	if a and a.bars and a.bars[bar] then
		a.bars[bar] = nil

		local bd = bar.candyBarBackdrop
		bd:Hide()
		if bd.iborder then
			bd.iborder:Hide()
			bd.oborder:Hide()
		end
		bar:SetTexture(nil)
		local guid = bar:Get("raidcooldowns:key")
		local spell = bar:Get("raidcooldowns:spell")
		local cooldown = bar:Get("raidcooldowns:cooldown")
		local caster = bar:Get("raidcooldowns:caster")
		--[[if BLCD['handles'] and BLCD["handles"][guid] and BLCD["handles"][guid][spell] then
			BLCD['handles'][guid][spell] = nil
		end]]
		BLCD.curr[cooldown['spellID']][guid] = nil;

		if(BLCD.profileDB.cdannounce) then
			local name = select(1, GetSpellInfo(cooldown['spellID']))
			local grouptype = BLCD:GetPartyType()
			if(grouptype == "raid") then
				SendChatMessage(caster.."'s "..name.." is ready!" ,"RAID");
			elseif(grouptype == "instance") then
				SendChatMessage(caster.."'s "..name.." is ready!" ,"INSTANCE_CHAT");
			elseif(grouptype == "party") then
				SendChatMessage(caster.."'s "..name.." is ready!" ,"PARTY");
			else
				SendChatMessage(caster.."'s "..name.." is ready!" ,"PARTY");
			end
		end

		if BLCD.profileDB.availablebars and BLCD.profileDB.cooldown[cooldown.name] and a:IsVisible() then
			local unitalive = (not UnitIsDeadOrGhost(caster) and UnitIsConnected(caster))
			if BLCD.cooldownRoster[cooldown['spellID']][guid] and unitalive then
				BLCD:CreatePausedBar(cooldown,guid)
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
		BLCD:UpdateCooldown(frame,event,cooldown,frameicon.text,frameicon, ...)
 	end);

	frame:Show()

	return frame
end

function BLCD:HandleEvents(frame,register)
	--[[if register then
		if not frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
			frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
			frame:RegisterEvent("GROUP_ROSTER_UPDATE")
			frame:RegisterEvent("ENCOUNTER_END")
			frame:RegisterEvent("PARTY_MEMBER_ENABLE")
			frame:RegisterEvent("PARTY_MEMBER_DISABLE")
			frame:RegisterEvent("UNIT_CONNECTION")
			frame:RegisterEvent("UNIT_HEALTH")
		end
	else
		frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		frame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		frame:UnregisterEvent("ENCOUNTER_END")
		frame:UnregisterEvent("PARTY_MEMBER_ENABLE")
		frame:UnregisterEvent("PARTY_MEMBER_DISABLE")
		frame:UnregisterEvent("UNIT_CONNECTION")
		frame:UnregisterEvent("UNIT_HEALTH")
	end]]
end

function BLCD:CreatePausedBar(cooldown,guid)
	if BLCD.curr[cooldown['spellID']][guid] then
		local bar = BLCD.curr[cooldown['spellID']][guid]
		if (cooldown['name'] == "DRU_TR" or cooldown['name'] == "PRI_VOSH") then
			local duration = BLCD:getCooldownCD(cooldown,guid)
			local rand = tonumber(string.format("%." .. (3 or 0) .. "f", fastrandom()*0.01)) -- add .00X to keep the compare from jumping around in the bar sorter.
			bar:SetDuration(duration - 1 - rand)
		end
	else
		local duration = BLCD:getCooldownCD(cooldown,guid)
		local rand = tonumber(string.format("%." .. (3 or 0) .. "f", fastrandom()*0.01)) -- add .00X to keep the compare from jumping around in the bar sorter.
		local spellID = cooldown['spellID']
		local spellName = GetSpellInfo(spellID)
		local caster = select(6,GetPlayerInfoByGUID(guid))
		local bar = BLCD:CreateBar(nil, cooldown, caster, cooldownFrameicons[spellID], guid, duration - 1 - rand, spellName)
		BLCD.curr[spellID][guid] = bar
		bar:SetTimeVisibility(false)
		bar.candyBarBar:SetMinMaxValues(0, bar.remaining)
		bar.candyBarBar:SetValue(bar.remaining)
		bar:Start()
		bar.updater:Pause()
		bar:EnableMouse(true)
		bar:SetScript("OnMouseDown", function(self,event, ...) SendChatMessage("Use "..self:Get("raidcooldowns:spell").." please!", "WHISPER", "Common", GetUnitName(self:Get("raidcooldowns:caster"),1)) end)
		return bar
	end
end

function BLCD:StopAllBars()
	local spellId,bar,frame
	for spellId, frame in pairs(cooldownFrameicons) do
		for bar in pairs(frame.bars) do
			if bar then bar:Stop() end
		end
	end
end

function BLCD:StopAllPausedBars()
	local spellId,bar,frame
	for spellId, frame in pairs(cooldownFrameicons) do
		for bar in pairs(frame.bars) do
			if not bar.updater:IsPlaying() then bar:Stop() end
		end
	end
end

function BLCD:UpdateBarGrowthDirection()
	local i, cooldown
	for i, cooldown in pairs(BLCD.cooldowns) do
		if (BLCD.profileDB.cooldown[cooldown.name] == true) then
			local frameicon = cooldownFrameicons[cooldown['spellID']]
			BLCD:RearrangeBars(frameicon)
		end
	end
end

function BLCD:RedrawCDList()
	local spellID, frame
	for spellID, frame in pairs(cooldownFrames) do
		if frame then
			frame:Hide()
			frame:ClearAllPoints()
		end
	end

	local IsTail = LList['head']
	while IsTail ~= nil do
		BLCD:RepositionFrames(cooldownFrames[IsTail],cooldownIndex[IsTail]['previous'])
		cooldownFrames[IsTail]:Show()
		IsTail = cooldownIndex[IsTail]['next']
	end
end

function BLCD:AvailableBars(value)
	if value then --create bars
		for spell, tabled in pairs(BLCD.cooldownRoster) do
			for sourceGUID, sourceName in pairs(tabled) do
				local unitalive = not (UnitIsDeadOrGhost(sourceName) or not UnitIsConnected(sourceName) or false)
				if unitalive then
				if not(BLCD.curr[spell][sourceGUID]) then
					local cooldown = BLCD.cooldowns[spell]
						if cooldown['spellID'] == spell then
							BLCD:CreatePausedBar(cooldown,sourceGUID)
							BLCD:RearrangeBars(cooldownFrameicons[spell])
						end
				end
				end
			end
		end
	elseif not value then --stop and recycle paused bars
		BLCD:StopAllPausedBars()
	end
end

function BLCD:RecolorBars(value)
	local spellId,bar,frame,cooldown
	for spellId, frame in pairs(cooldownFrameicons) do
		for bar in pairs(frame.bars) do
			if value then
				cooldown = 	bar:Get("raidcooldowns:cooldown")
				local color = RAID_CLASS_COLORS[cooldown['class']] or {r=0.5; g=0.5; b=0.5}
				bar:SetColor(color.r,color.g,color.b,1)
			else
				bar:SetColor(.5,.5,.5,1)
			end
		end
	end
end

function BLCD:DynamicCooldownFrame()--key,value)
	local i, cooldown
	for i, cooldown in pairs(BLCD.cooldowns) do
		i = cooldown.index
		if ((not BLCD.profileDB.cooldown[cooldown.name]) and cooldownIndex[i] ~= nil) then  -- cooldown removed
			BLCD.active = BLCD.active - 1
			--index = index + 1;
			--BLCD.curr[cooldown['spellID']] = {}
			--BLCD.cooldownRoster[cooldown['spellID']] = {}
			--BLCD:HandleEvents(cooldownFrames[i],false)
			-- Linked List management
			BLCD:RemoveFrame(cooldownFrames[i],cooldownIndex[i]['previous'],cooldownIndex[i]['next'], cooldownFrames)
			BLCD:RemoveNode(cooldownIndex[i])
			cooldownIndex[i] = nil
		end

		if (BLCD.profileDB.cooldown[cooldown.name] and cooldownIndex[i] == nil) then  -- cooldown added
			BLCD.active = BLCD.active + 1
			if not BLCD.curr[cooldown['spellID']] then BLCD.curr[cooldown['spellID']] = {} end
			if not BLCD.cooldownRoster[cooldown['spellID']] then BLCD.cooldownRoster[cooldown['spellID']] = {} end

			-- Linked List management
			cooldownIndex[i] = {}
			if LList.head == nil then
				BLCD:InsertBeginning(cooldownIndex[i],i)
			else
				BLCD:InsertNode(cooldownIndex[i],i)
			end
			--
			if cooldownFrames[i] == nil then
				cooldownFrames[i] = BLCD:CreateCooldown(i, cooldown);
			end
			BLCD:InsertFrame(cooldownFrames[i],cooldownIndex[i]['previous'],cooldownIndex[i]['next'], cooldownFrames)
			--BLCD:HandleEvents(cooldownFrames[i],false)

		end
		if (BLCD.profileDB.cooldown[cooldown.name]) then
			BLCD:UpdateRoster(cooldown)
			local frameicon = cooldownFrameicons[cooldown['spellID']]
			if frameicon then frameicon.text:SetText(BLCD:GetTotalCooldown(cooldown)) end
		end
    end
	--BLCD:RedrawCDList()
end

--------------------------------------------------------

--------------------------------------------------------
-- Cooldown Management --
--------------------------------------------------------
function BLCD:UpdateCooldown(frame,event,cooldown,text,frameicon, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, eventType , _, soureGUID, sourceName, srcFlags, _, destGUID, destName, dstFlags, _, spellId, spellName = select(1, ...)
		if (spellId == 108292 or spellId == 108293 or spellId == 108294) and cooldown['spellID'] == 108291 then -- Stupid Heart of the Wild with it's 4 ID's
			spellId = 108291
		end
		local group = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)
		if(eventType == cooldown['succ'] and spellId == cooldown['spellID']) and bit.band(srcFlags, group) ~= 0 then
			if (BLCD['raidRoster'][soureGUID]  and not BLCD['raidRoster'][soureGUID]['extra']) then
				local duration = BLCD:getCooldownCD(cooldown,soureGUID)
				local index = frame.index
				BLCD:StartCD(frame,cooldown,text,soureGUID,sourceName,frameicon, spellName,duration,false)
				local data = {{spellID = cooldown['spellID'], name = cooldown['name']},soureGUID,sourceName,spellName,duration,index}
				BLCD:SendCommand(data)
	            text:SetText(BLCD:GetTotalCooldown(cooldown))
			end
		elseif (eventType == "UNIT_DIED") then
			if bit.band(dstFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(dstFlags, group) ~= 0 then
				destName = UnitName(destName)
				BLCD.tmp[destName] = 1
				BLCD:CheckPausedBars(cooldown, destName)
				text:SetText(BLCD:GetTotalCooldown(cooldown))
			end
		elseif (eventType == "SPELL_AURA_APPLIED") and spellId ==  160029 and cooldown['spellID'] == 20484 then
			if bit.band(dstFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 and bit.band(dstFlags, group) ~= nil then
				BLCD:DecrementBRes()
			end
		end
	elseif(event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_CONNECTION") then
		local unit = ...
		BLCD:CheckPausedBars(cooldown,unit)
		text:SetText(BLCD:GetTotalCooldown(cooldown))
	elseif(event == "UNIT_HEALTH") then
		local unit = ...
		if UnitInRaid(unit) then
			local name = UnitName(unit)
			--local guid = UnitGUID(unit)
			local health = UnitHealth(unit)
			if BLCD.tmp[name] == nil then BLCD.tmp[name] = 0 end
			if BLCD.tmp[name] == 0 then return end
			local connected = UnitIsConnected(unit)
			local deadorghost = UnitIsDeadOrGhost(unit)
			if BLCD.tmp[name] ~= 0 and health > 1 then
				BLCD:CheckPausedBars(cooldown, name)
				BLCD:RearrangeBars(cooldownFrameicons[cooldown['spellID']])
				text:SetText(BLCD:GetTotalCooldown(cooldown))
				--if (BLCD.tmp[name] or 0) > 100 then BLCD.tmp[name] = 0 end
			else
				--unit is probably still dead and laying on the ground eating some old bubble gum. Almost certainly hasn't released yet.
				BLCD.tmp[name] = 1
			end
		end
	elseif(event =="GROUP_ROSTER_UPDATE") then
	    local partyType = BLCD:GetPartyType()
	    if(partyType=="none" and (BLCD.profileDB.show ~= "always" or BLCD.profileDB.show ~= "solo")) then
	        BLCD:CancelBars(frameicon)
	        BLCD.curr[cooldown['spellID']]={}
	        BLCD.cooldownRoster[cooldown['spellID']] = {}
	        BLCD:CheckVisibility()
	    end
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
    elseif(event =="GroupInSpecT_Update") then
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
	end
end

function BLCD:StartCD(frame,cooldown,text,guid,caster,frameicon,spellName,duration,fromComms)
	if(BLCD.profileDB.castannounce) then
		local name = select(1, GetSpellInfo(cooldown['spellID']))
		--print(caster,name,duration)
		if(BLCD:GetPartyType()=="raid") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"RAID");
		elseif(BLCD:GetPartyType()=="party") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"PARTY");
		elseif(BLCD:GetPartyType()=="instance") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"INSTANCE_CHAT");
		else
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"SAY");
		end
	end
	local adjust = .75
	if fromComms then
		adjust = 1
	end

	local bar
	if BLCD.profileDB.availablebars then
		bar = BLCD.curr[cooldown['spellID']][guid]
		--print('already made: ', bar, bar['running'], bar['remaining'])
	else
		bar = BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration-adjust,spellName)
	end
	if bar then 
		bar:SetTimeVisibility(true)
		bar:EnableMouse(false)
		bar:Start()
	else
		if(cooldown["spec"]) then
			BLCD['raidRoster'][guid]["spec"] = cooldown["spec"]
			BLCD.cooldownRoster[cooldown['spellID']][guid] = BLCD['raidRoster'][guid]['name']
		elseif(cooldown["talent"]) then
			if not BLCD['raidRoster'][guid]["talents"] then
				BLCD['raidRoster'][guid]["talents"] = {}
				BLCD['raidRoster'][guid]["talents"][cooldown["talentidx"]] = {}
			end
			BLCD.cooldownRoster[cooldown['spellID']][guid] = BLCD['raidRoster'][guid]['name']
		elseif(not cooldown["spec"] and not cooldown["talent"] and cooldown["class"]) then -- we should never miss a class ability
			BLCD.cooldownRoster[cooldown['spellID']][guid] = BLCD['raidRoster'][guid]['name']
		end
		BLCD:UpdateRoster(cooldown)
		--bar = BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration-adjust,spellName)
		if not bar then
			return --error('still couldnt get bar for '.. caster .. " " .. spellName)
		end
		bar = BLCD.curr[cooldown['spellID']][guid]
		bar:SetTimeVisibility(true)
		bar:EnableMouse(false)
		bar:Start()
	end
	BLCD:RearrangeBars(frameicon)

	if not(BLCD.curr[cooldown['spellID']][guid]) then
	    BLCD.curr[cooldown['spellID']][guid] = bar
    end
	if cooldown['charges'] and BLCD['raidRoster'][guid]['talents'][105622] then --Pally Clemency, could be useful later
		if BLCD['charges'][guid] == nil then
			BLCD['charges'][guid] = {}
		end
		BLCD['charges'][guid][cooldown['spellID']] = (BLCD['charges'][guid][cooldown['spellID']] or cooldown['charges']) - 1
	end
end

function BLCD:getCooldownCD(cooldown,sourceGUID)
	local cd = cooldown['CD']
	if(BLCD.cooldownReduction[cooldown['name']]) then
		if(BLCD['raidRoster'][sourceGUID]['spec'] == BLCD.cooldownReduction[cooldown['name']]['spec']) then
			cd = BLCD.cooldownReduction[cooldown['name']]['CD']
		end
	end

	return cd
end

function BLCD:GetTotalCooldown(cooldown)
	local cd = 0
	local cdTotal = 0
	local i,v 
	
	if IsEncounterInProgress() and IsInRaid() and (cooldown['spellID'] == 20484 or cooldown['spellID'] == 20707 or cooldown['spellID'] == 61999) then
		return resCount
	end
	
	for i,v in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
		local unitalive = not (UnitIsDeadOrGhost(v) or not UnitIsConnected(v) or false)
		if unitalive then
			cdTotal=cdTotal+1
		end
 	end

	for i,v in pairs(BLCD.curr[cooldown['spellID']]) do
		if v.updater:IsPlaying() then
			local _,_,_,_,_,name = GetPlayerInfoByGUID(i)
			local unitalive = not (UnitIsDeadOrGhost(name) or not UnitIsConnected(name) or false)
			if unitalive then
				cd=cd+1
			end
		end
	end
	
	local total = (cdTotal-cd)
	if(total < 0) then
		total = 0
	end
		
	return total
end

function BLCD:ResetAll()
	local spellId,guids
	for spellId,guids in pairs(BLCD.curr) do
		for guid,bar in pairs(BLCD.curr[spellId]) do
			bar:Stop()
		end
	end
end

function BLCD:ResetWipe()
	local spellId,guids,guid,bar
	for spellId,guids in pairs(BLCD.curr) do
		if cooldownTimes[spellId] >= 300 or spellId == 115310 then
			for guid,bar in pairs(BLCD.curr[spellId]) do
				bar:Stop()
			end
		end
	end
	local bResIDs = {20484, 20707, 61999}
	for _, spellId in pairs(bResIDs) do
		local frameicon = cooldownFrameicons[spellId]
		frameicon.cooldown:SetCooldown(0, 0)
	end
end

function BLCD:ResetBRes(engage, playersOnPull)
	local bResIDs,spellID,guid,bar = {20484, 20707, 61999}
	if engage then
		playersOnPull = select(9,GetInstanceInfo())
		resCount = 1
		BLCD.resTimer = BLCD:ScheduleRepeatingTimer("ResetBRes", ((90/playersOnPull)*60 - 1), false, playersOnPull)
	else
		resCount = resCount + 1
	end
	
	for _, spellID in pairs(bResIDs) do
		--for guid,bar in pairs(BLCD.curr[spellID]) do
			--bar:Stop()
		--end
		local frameicon = cooldownFrameicons[spellID]
		if engage then
			frameicon.text:SetText(1)
		else 
			frameicon.text:SetText(resCount)
		end
		frameicon.cooldown:SetCooldown(GetTime(), (90/playersOnPull)*60)
	end
end

function BLCD:DecrementBRes()
	local bResIDs,spellID,guid,bar = {20484, 20707, 61999}
	resCount = resCount - 1
	for _, spellID in pairs(bResIDs) do
		local frameicon = cooldownFrameicons[spellID]
		frameicon.text:SetText(max(0,(resCount)))
	end
end

function BLCD:shallowcopy(orig)
    local orig_type = type(orig)
    local copy, orig_key, orig_value
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
--------------------------------------------------------

--------------------------------------------------------
-- Initialization --
--------------------------------------------------------

local count = 0
function BLCD:OnInitialize()
	if count == 1 then return end
	BLCD:RegisterChatCommand("BLCD", "SlashProcessor_BLCD")
	
	-- DB
	BLCD.db = AceDB:New("BLCDDB", BLCD.defaults, true)
	
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	BLCD.profileDB = BLCD.db.profile
	BLCD:SetupOptions()
	
	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Update", "OnLGIST")

	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Remove", "OnLGIST")
	
	
	BLCD:CreateRaidTables()
	BLCD:CreateBase()
	LList['head'] = nil
	LList['tail'] = nil
	local index = 0
	local i, cooldown
	for i, cooldown in pairs(BLCD.cooldowns) do
		i = cooldown.index
		cooldownTimes[cooldown['spellID']] = cooldown['CD']  -- Go ahead and make this so I don't have to manage it later. 
		cooldownNames[cooldown['spellID']] = cooldown['name']
		if (BLCD.profileDB.cooldown[cooldown.name]) then
			index = index + 1;
			BLCD.curr[cooldown['spellID']] = {}
			BLCD.cooldownRoster[cooldown['spellID']] = {}
			cooldownIndex[i] = {}
			if LList.head == nil then 
				BLCD:InsertBeginning(cooldownIndex[i], i)
			else
				BLCD:InsertNode(cooldownIndex[i],i)
			end
			cooldownFrames[i] = BLCD:CreateCooldown(i, cooldown);	
			BLCD:InsertFrame(cooldownFrames[i],cooldownIndex[i]['previous'],cooldownIndex[i]['next'], cooldownFrames)			
		end
    end
	BLCD:DynamicCooldownFrame()
	
	BLCD.active = index
	BLCD:CheckVisibility()

	count = 1
end
-----------------------------------

-----------------------------------
-- Linked List Management --
-----------------------------------

function BLCD:RemoveNode(node)
	if node['previous'] == nil then
		LList.head = node['next']
	else
		cooldownIndex[node['previous']]['next'] = node['next']
	end
	if node['next'] == nil then
		LList.tail = node['previous']
	else
		cooldownIndex[node['next']]['previous'] = node['previous']
	end
end

function BLCD:InsertNode(newNode, index)
	local key, node
	for key, node in pairs(cooldownIndex) do
		if index ~= key then  -- Node already created in LList but next,prev == nil. Like a floating node.
			if (node['previous'] or 0) < index and key > index then
				BLCD:InsertBefore(cooldownIndex[key], key, newNode, index)
				break
			elseif (node['next'] or 100) > index and key < index then
				BLCD:InsertAfter(cooldownIndex[key], key, newNode, index)
				break
			end
		end
	end
end

function BLCD:InsertAfter(node, index, newNode, index2)
    newNode['previous'] = index
    newNode['next']  = node['next']
	 
    if node['next'] == nil then
		LList.tail = index2
    else
		cooldownIndex[node['next']]['previous'] = index2
	end
	node['next'] = index2
end

function BLCD:InsertBefore(node, index, newNode, index2)
    newNode['previous'] = node['previous']
    newNode['next'] = index
	 
    if node['previous'] == nil then
        LList.head = index2
    else
        cooldownIndex[node['previous']]['next'] = index2
	end	
	node['previous'] = index2
end

function BLCD:InsertBeginning(newNode, index)
    if LList.head == nil then
         LList.head = index
         LList.tail = index
         newNode['previous']  = nil
         newNode['next']  = nil
    else	
         BLCD:InsertBefore(cooldownIndex[LList.head], LList.head, newNode, index)
	end
end
----------------------------------------------

----------------------------------------------
-- Version Control --
----------------------------------------------

do
	local timer = BLCD.frame:CreateAnimationGroup()
	timer:SetScript("OnFinished", function()
		if IsInGroup() then
			SendAddonMessage("BLCD", ("VR:%2f"):format(BLCD_VERSION), IsInGroup(2) and "INSTANCE_CHAT" or "RAID") -- LE_PARTY_CATEGORY_INSTANCE = 2
		end
	end)
	local anim = timer:CreateAnimation()
	anim:SetDuration(3)
	
	
	local hasWarned, hasCritWarned = nil, nil
	local function printOutOfDate(tbl)
		if hasCritWarned then return end
		local warnedOutOfDate, warnedExtremelyOutOfDate = 0, 0
		for k,v in next(tbl) do
			if (v) > BLCD_VERSION then
				warnedOutOfDate = warnedOutOfDate + 1
				if warnedOutOfDate > 1 and not hasWarned then
					hasWarned = true
					print("Your BL_Cooldown is out of date. Update to the latest version on curse.")
				end
			end
		end
	end

	function BLCD:VersionCheck(prefix, message, sender)
		if prefix == "VQ" or prefix == "VR" then
			if prefix == "VQ" then
				timer:Stop()
				timer:Play()
			end
			message = tonumber(message)
			if not message or message == 0 then return end 
			usersRelease[sender] = message
			
			if message > BLCD_VERSION then BLCD_VERSION = message end
			if BLCD_VERSION ~= -1 and message > BLCD_VERSION then
				printOutOfDate(usersRelease)
			end
			
		end
	end
end

function BLCD:PrintVersions()
	if not IsInGroup() then return end

	local function coloredNameVersion(name, version)
		if version == -1 then
			version = "|cFFCCCCCC(SVN)|r"
		elseif not version then
			version = ""
		else
			version = ("|cFFCCCCCC(%s%s)|r"):format(version, alpha and "-alpha" or "")
		end

		local _, class = UnitClass(name)
		local tbl = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or GRAY_FONT_COLOR
		name = name:gsub("%-.+", "*") -- Replace server names with *
		return ("|cFF%02x%02x%02x%s|r%s"):format(tbl.r*255, tbl.g*255, tbl.b*255, name, version)
	end

	local m = {}
	local unit
	if not IsInRaid() then
		m[1] = UnitName("player")
		unit = "party%d"
	else
		unit = "raid%d"
	end
	local i, player
	for i = 1, GetNumGroupMembers() do
		local n, s = UnitName((unit):format(i))
		if n and s and s ~= "" then n = n.."-"..s end
		if n then m[#m+1] = n end
	end

	local good = {} -- highest release users
	local ugly = {} -- old version users

	for i, player in next, m do
		if usersRelease[player] then
			if usersRelease[player] < BLCD_VERSION then
				ugly[#ugly + 1] = coloredNameVersion(player, usersRelease[player])
			else
				good[#good + 1] = coloredNameVersion(player, usersRelease[player])
			end
		end
	end

	if #good > 0 then print("Up to date: ", unpack(good)) end
	if #ugly > 0 then print("Out of date: ", unpack(ugly)) end
end
------------------------------------------------

------------------------------------------------
-- Addon Communication --
------------------------------------------------

function BLCD:ReceiveMessage(prefix, message, distribution, sender)
	if UnitIsUnit(sender, "player") then return end
	if prefix == commPrefix then
		local blPrefix, blMsg = message:match("^(%u-):(.+)")
		sender = Ambiguate(sender, "none")
		if blPrefix == "VQ" or blPrefix == "VR" then
			self:VersionCheck(blPrefix, blMsg, sender)
		end
		local success, DATA = self:Deserialize(message)
		if not success then 
			return -- Failure
		elseif type(DATA) == "table" then 
			local index = DATA[6]
			--print('recieved@ ', GetTime(), 'from: ', sender)--, 'message: ', BLCD:print_r(DATA))
			--local data = {{cooldown['spellID'], cooldown['name']},soureGUID,sourceName,spellName,duration,index}
			--local DATA = {cooldown,sourceGUID,sourceName,spellName,duration,index}
			--	DATA			1		 2		   3		  4		   5	   6
			if BLCD.profileDB.cooldown[DATA[1]['name']] then -- The player might not be tracking the cooldown that is received from comms
				if not(BLCD.curr[DATA[1]['spellID']][DATA[2]]) then
					local frameicon = cooldownFrameicons[DATA[1]['spellID']]
					local text = frameicon.text
					--BLCD:StartCD(frame                , cooldown,text,soureGUID,sourceName,frameicon, spellName,duration, true)
					BLCD:StartCD(cooldownFrames[index], DATA[1], text,DATA[2],  DATA[3],   frameicon, DATA[4],  DATA[5],  true )
					text:SetText(BLCD:GetTotalCooldown(DATA[1]))
				elseif BLCD.profileDB.availablebars then
				
					if BLCD.curr[DATA[1]['spellID']][DATA[2]] and not BLCD.curr[DATA[1]['spellID']][DATA[2]]['updater']:IsPlaying()  then
						local bar = BLCD.curr[DATA[1]['spellID']][DATA[2]]
							if bar then
								bar:SetTimeVisibility(true)
								bar:EnableMouse(false)
								bar:Start()
							end
						local frameicon = cooldownFrameicons[DATA[1]['spellID']]
						local text = frameicon.text	
						BLCD:RearrangeBars(frameicon)
						text:SetText(BLCD:GetTotalCooldown(DATA[1]))
					end
				end
			end
		end
	end
end

function BLCD:SendCommand(data)
	local s = self:Serialize(data)
	self:SendCommMessage(commPrefix, s, "RAID", "", "ALERT")
end

function BLCD:OnEnable()
	self:RegisterComm(commPrefix, "ReceiveMessage")
end

function BLCD:OnDisable()

end

function BLCD:PLAYER_LOGOUT()
	BLCDrosterReload = BLCD['raidRoster']
end
--------------------------------------------------------