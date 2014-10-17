--------------------------------------------------------
-- Blood Legion Raidcooldowns - Functions --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")
local CB = LibStub("LibCandyBar-3.0")
local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

local GameFontHighlightSmallOutline = GameFontHighlightSmallOutline
local _fontName, _fontSize = GameFontHighlightSmallOutline:GetFont()
local _fontShadowX, _fontShadowY = GameFontHighlightSmallOutline:GetShadowOffset()
local _fontShadowR, _fontShadowG, _fontShadowB, _fontShadowA = GameFontHighlightSmallOutline:GetShadowColor()

--------------------------------------------------------

--------------------------------------------------------
-- Helper Functions --
--------------------------------------------------------
function BLCD:GetPartyType()
	local grouptype = (IsInGroup(2) and 3) or (IsInRaid() and 2) or (IsInGroup() and 1)
	if grouptype == 3 then
		return "instance"
	elseif grouptype == 2 then
		return "raid"
	elseif grouptype == 1 then
		return "party"
	else
		return "none"
	end
end

--[[
0 - None; not in an Instance.
1 - 5-player Instance.
2 - 5-player Heroic Instance.
3 - 10-player Raid Instance.
4 - 25-player Raid Instance.
5 - 10-player Heroic Raid Instance.
6 - 25-player Heroic Raid Instance.
7 - Raid Finder Instance.
8 - Challenge Mode Instance.
9 - 40-player Raid Instance.
10 - Not used.
11 - Heroic Scenario Instance.
12 - Scenario Instance.
13 - Not used.
14 - Flexible Raid.
]]

function BLCD:print_r ( t )
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(pos)=="table") then
						print(indent.."["..tostring(pos).."] => "..tostring(t).." {")
						sub_print_r(pos,indent..string.rep(" ",string.len(tostring(pos))+8))
						print(indent..string.rep(" ",string.len(tostring(pos))+6).."}")
					else
						print(indent.."["..tostring(pos).."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	sub_print_r(t," ")
end

function BLCD:ClassColorString (class)
	return string.format ("|cFF%02x%02x%02x",
		RAID_CLASS_COLORS[class].r * 255,
		RAID_CLASS_COLORS[class].g * 255,
		RAID_CLASS_COLORS[class].b * 255)
end

function BLCD:print_raid()
	return BLCD:print_r(BLCD['raidRoster'])
end

function BLCD:sec2Min(secs)
	return secs
end

local function print(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cffc41f3bBLCD|r: " .. table.concat({...}, " "))
end
--------------------------------------------------------

--------------------------------------------------------
-- Display Bar Functions --
--------------------------------------------------------
local function barSorter(a, b)
	local caster1 = a:Get("raidcooldowns:caster")
	local caster2 = b:Get("raidcooldowns:caster")
	if a.remaining == b.remaining then
		return caster1 < caster2
	else
		return a.remaining < b.remaining
	end
end

function BLCD:RearrangeBars(anchor) -- frameicon
	if not anchor then return end
	if not next(anchor.bars) then
		if anchor:IsVisible() then
			BLCD:BLHeight(anchor:GetParent(), 28*BLCD.profileDB.scale)
		end
	return end
	local frame = anchor:GetParent()
	local scale = BLCD.profileDB.scale
	local growth = BLCD.profileDB.growth
	local currBars = {}
	
	for bar in pairs(anchor.bars) do
		if bar:IsVisible() then
			currBars[#currBars + 1] = bar
		else	
			anchor.bars[bar] = nil
			bar:Stop()
		end
	end
	
	if(#currBars > 2)then
		BLCD:BLHeight(frame, (14*#currBars)*scale);
	else
		BLCD:BLHeight(frame, 28*scale);
	end

	table.sort(currBars, barSorter)
	
	for i, bar in ipairs(currBars) do
		local spacing = (((-14)*(i-1))-2)
		bar:ClearAllPoints()
		if(growth  == "right") then
			BLCD:BLPoint(bar, "TOPLEFT", anchor, "TOPRIGHT", 5, spacing)
		elseif(growth  == "left") then
			BLCD:BLPoint(bar, "TOPRIGHT", anchor, "TOPLEFT", -5, spacing)
		end
	end
end

local backdropBorder = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	tile = false, tileSize = 0, edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local function styleBar(bar)
	local bd = bar.candyBarBackdrop

	if Elv and false then
		bd:SetTemplate("Transparent")
		bd:SetOutside(bar)
		if not E.PixelMode and bd.iborder then
			bd.iborder:Show()
			bd.oborder:Show()
		end
	else
		bd:SetBackdrop(backdropBorder)
		bd:SetBackdropColor(0.06, 0.06, 0.06, 1)
		bd:SetBackdropBorderColor(0, 0, 0)

		bd:ClearAllPoints()
		bd:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
		bd:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
		
		bar.candyBarLabel:SetTextColor(1,1,1,1)
		bar.candyBarLabel:SetJustifyH("CENTER")
		bar.candyBarLabel:SetJustifyV("MIDDLE")
		bar.candyBarLabel:SetFont("Interface\\AddOns\\BL_Cooldown\\media\\PT_Sans_Narrow.ttf", _fontSize)
		bar.candyBarLabel:SetShadowOffset(_fontShadowX, _fontShadowY)
		bar.candyBarLabel:SetShadowColor(_fontShadowR, _fontShadowG, _fontShadowB, _fontShadowA)

		bar.candyBarDuration:SetTextColor(1,1,1,1)
		bar.candyBarDuration:SetJustifyH("CENTER")
		bar.candyBarDuration:SetJustifyV("MIDDLE")
		bar.candyBarDuration:SetFont("Interface\\AddOns\\BL_Cooldown\\media\\PT_Sans_Narrow.ttf", _fontSize)
		bar.candyBarDuration:SetShadowOffset(_fontShadowX, _fontShadowY)
		bar.candyBarDuration:SetShadowColor(_fontShadowR, _fontShadowG, _fontShadowB, _fontShadowA)
	end
	bd:Show()
end

function BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration,spell)
	local bar = CB:New(BLCD:BLTexture(), 100, 9)
	styleBar(bar)
	frameicon.bars[bar] = true
	bar:Set("raidcooldowns:module", "raidcooldowns")
	bar:Set("raidcooldowns:anchor", frameicon)
	bar:Set("raidcooldowns:key", guid)
	bar:Set("raidcooldowns:spell", spell)
	bar:Set("raidcooldowns:caster", caster)
	bar:Set("raidcooldowns:cooldown", cooldown)
	bar:SetParent(frameicon)
	bar:SetFrameStrata("MEDIUM")
	if BLCD.profileDB.classcolorbars then
		local color = RAID_CLASS_COLORS[cooldown['class']] or {r=0.5; g=0.5; b=0.5}
		bar:SetColor(color.r,color.g,color.b,1)
	else
		bar:SetColor(.5,.5,.5,1)
	end	
	bar:SetDuration(duration)
	bar:SetScale(BLCD.profileDB.scale)
	bar:SetClampedToScreen(true)
	
	local caster = strsplit("-",caster)
	bar:SetLabel(caster)
	
	bar.candyBarLabel:SetJustifyH("LEFT")
	return bar
end	

function BLCD:CancelBars(spellID)
	for guid, bar in pairs(BLCD.curr[spellID]) do
		bar:Stop()
	end
end

function BLCD:restyleBar(self)
	self.candyBarBar:SetPoint("TOPLEFT", self)
	self.candyBarBar:SetPoint("BOTTOMLEFT", self)
	self.candyBarIconFrame:Hide()
	if self.candyBarLabel:GetText() then self.candyBarLabel:Show()
	else self.candyBarLabel:Hide() end
	self.candyBarDuration:Hide()
end

function BLCD:StopPausedBar(cooldown,guid)
	if BLCD.curr[cooldown['spellID']] and BLCD.curr[cooldown['spellID']][guid] then
		local bar = BLCD.curr[cooldown['spellID']][guid]
		if not bar.updater:IsPlaying() then
			bar:Stop()
		end
	end
end

function BLCD:CheckPausedBars(cooldown,unit)
	if BLCD.profileDB.availablebars then
		local unitDead = UnitIsDeadOrGhost(unit) and true
		local unitOnline = (UnitIsConnected(unit) or false)
		local name = UnitName(unit)
		local guid = UnitGUID(unit)
		
		if BLCD.curr[cooldown['spellID']] and BLCD.curr[cooldown['spellID']][guid] then
			local bar = BLCD.curr[cooldown['spellID']][guid]
			if unitDead or not unitOnline then
				if not bar.updater:IsPlaying() then
					bar:Stop()
				end
			end
		end
		if BLCD.profileDB.cooldown[cooldown.name] and BLCD.cooldownRoster[cooldown['spellID']][guid] and not (BLCD.curr[cooldown['spellID']] and BLCD.curr[cooldown['spellID']][guid]) then
			if not unitDead and unitOnline then
				BLCD:CreatePausedBar(cooldown,guid)
			end
		end
		if not unitDead and unitOnline then
			BLCD:ScheduleTimer( function() BLCD.tmp[name] = 0 end, 1)
		end
	end
end

--------------------------------------------------------

--------------------------------------------------------
-- Visibility Functions --
--------------------------------------------------------
function BLCD:CheckVisibility()
	local frame = BLCooldownBase_Frame
	local grouptype = BLCD:GetPartyType()
	if(BLCD.profileDB.show == "always") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "never") then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "solo" and grouptype == "none") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "solo" and grouptype ~= "none") then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "raid" and (grouptype =="raid" or grouptype == "instance")) then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "raid" and not (grouptype =="raid" or grouptype == "instance")) then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "raidorparty" and (grouptype =="raid" or grouptype == "instance" or grouptype=="party")) then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "raidorparty" and not (grouptype =="raid" or grouptype == "instance" or grouptype=="party")) then
		frame:Hide()
		BLCD.show = nil	
	elseif(BLCD.profileDB.show == "party" and grouptype =="party") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "party" and grouptype ~="party") then
		frame:Hide()
		BLCD.show = nil
	end
end

function BLCD:ToggleVisibility()
	local frame = BLCooldownBase_Frame
	if(BLCD.show) then
		frame:Hide()
		BLCD.show = nil
	else
		frame:Show()
		BLCD.show = true
	end
end

function BLCD:ToggleMoversLock()
	local raidcdbasemover = BLCooldownBaseMover_Frame
	if(BLCD.locked) then
		raidcdbasemover:EnableMouse(true)
		raidcdbasemover:RegisterForDrag("LeftButton")
		raidcdbasemover:Show()
		BLCD.locked = nil
		print("unlocked")
	else
		raidcdbasemover:EnableMouse(false)
		raidcdbasemover:RegisterForDrag(nil)
		raidcdbasemover:Hide()
		BLCD.locked = true
		print("locked")
		local point,_,relPoint,xOfs,yOfs = raidcdbasemover:GetPoint(1)
		BLCD.profileDB.framePoint = point
		BLCD.profileDB.relativePoint = relPoint
		BLCD.profileDB.xOffset = xOfs
		BLCD.profileDB.yOffset = yOfs
	end
end
--------------------------------------------------------

--------------------------------------------------------
-- Frame Functions --
--------------------------------------------------------
function BLCD:OnEnter(self, cooldown, rosterCD, onCD)
	--local parent = self:GetParent()
	--local allCD = BLCD:shallowcopy(rosterCD)
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",3, 14)
	GameTooltip:ClearLines()
	GameTooltip:AddSpellByID(cooldown['spellID'])

	local guid,bar,i,v
	--for guid,bar in pairs(onCD) do
		--print('on: ', guid,bar)
		--allCD[guid] = 0
	--end
	if next(rosterCD) ~= nil then
		GameTooltip:AddLine(' ')
		for i,v in pairs(rosterCD) do
		-- guid, name
		--print(i,v)
			if not (onCD[i] and onCD[i]['updater']:IsPlaying()) then
				local unitAlive = not (UnitIsDeadOrGhost(v) or false)
				local unitOnline = (UnitIsConnected(v) or false)
				if unitAlive and unitOnline then
					GameTooltip:AddLine(v .. ' Ready!', 0, 1, 0)
				elseif not unitOnline then
					GameTooltip:AddLine(v .. ' OFFLINE but ready!', 1, 0, 0)
				else
					GameTooltip:AddLine(v .. ' DEAD but Ready!', 1, 0, 0)
				end
			end
		end
	end
	GameTooltip:Show()
end

function BLCD:OnLeave(self)
   GameTooltip:Hide()
end

function BLCD:PostClick(self, cooldown, rosterCD, onCD)
	if(BLCD.profileDB.clickannounce) then
		--local allCD = BLCD:shallowcopy(rosterCD)
		--local grouptype = BLCD:GetPartyType()
		--for i,v in pairs(onCD) do
			--allCD[i] = 0
		--end
		
		if next(rosterCD) ~= nil then
			local name = GetSpellInfo(cooldown['spellID'])
			if IsInRaid() or IsInGroup(2) then
				SendChatMessage('----- '..name..' -----',IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
			elseif IsInGroup() then
				SendChatMessage('----- '..name..' -----','PARTY')
			end
			
			for i,v in pairs(rosterCD) do
				if not (onCD[i] and onCD[i]['updater']:IsPlaying()) then
					local unitalive = not (UnitIsDeadOrGhost(v) or false)
					local unitOnline = (UnitIsConnected(v) or false)
					if IsInRaid() or IsInGroup(2) then
						if unitalive then
							SendChatMessage(v..' ready!',IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
						elseif not unitOnline then
							SendChatMessage(v..' OFFLINE but ready!',IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
						else
							SendChatMessage(v..' DEAD but ready!',IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
						end
					elseif IsInGroup() then
						if unitalive then
							SendChatMessage(v..' ready!','PARTY')
						elseif not unitOnline then
							SendChatMessage(v..' OFFLINE but ready!', 'PARTY')
						else
							SendChatMessage(v..' DEAD but ready!','PARTY')
						end	
					end
				end
			end
		end
	end
end
--------------------------------------------------------

--------------------------------------------------------
-- Frame Appearance Functions --
--------------------------------------------------------
function BLCD:Scale()
	local raidcdbase = BLCooldownBase_Frame
	local raidcdbasemover = BLCooldownBaseMover_Frame
	BLCD:BLSize(raidcdbase,32*BLCD.profileDB.scale,(32*BLCD.active)*BLCD.profileDB.scale)
	BLCD:BLSize(raidcdbasemover,32*BLCD.profileDB.scale,(32*BLCD.active)*BLCD.profileDB.scale)
	local i,cooldown
	for i,cooldown in pairs(BLCD.cooldowns) do
		i = cooldown.index
		if (BLCD.db.profile.cooldown[cooldown.name]) then
		BLCD:BLHeight(_G['BLCooldown'..i],28*BLCD.profileDB.scale);
		BLCD:BLWidth(_G['BLCooldown'..i],145*BLCD.profileDB.scale);	
		BLCD:BLSize(_G['BLCooldownIcon'..i],28*BLCD.profileDB.scale,28*BLCD.profileDB.scale);
		BLCD:BLFontTemplate(_G['BLCooldownIcon'..i].text, 20*BLCD.profileDB.scale, 'OUTLINE')
		end
	end
end

function BLCD:SetBarGrowthDirection(frame, frameicon, index)
	if(BLCD.profileDB.growth == "left") then
		if index == nil then
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldownBase_Frame', 'TOPRIGHT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldown'..(index), 'BOTTOMRIGHT', 0, -2);
		end
		BLCD:BLPoint(frameicon,'TOPRIGHT', frame, 'TOPRIGHT');
	elseif(BLCD.profileDB.growth  == "right") then
		--[[if index == nil then
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldown'..(index), 'BOTTOMLEFT', 0, -2);
		end]]
		BLCD:BLPoint(frameicon,'TOPLEFT', frame, 'TOPLEFT');
	end
end

function BLCD:RepositionFrames(frame, index, cooldownFrames)
	if(BLCD.profileDB.growth == "left") then
		if index == nil then
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldownBase_Frame', 'TOPRIGHT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldown'..(index), 'BOTTOMRIGHT', 0, -2);
		end
	elseif(BLCD.profileDB.growth  == "right") then
		if index == nil then
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldown'..(index), 'BOTTOMLEFT', 0, -2);
		end
	end
end

function BLCD:InsertFrame(frame, prevIndex, nextIndex, cooldownFrames)
	if prevIndex == nil then
		BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2); 
		frame:Show()
		if nextIndex ~= nil then BLCD:BLPoint(cooldownFrames[nextIndex],'TOPLEFT', frame, 'BOTTOMLEFT', 0, -2); end
	else
		BLCD:BLPoint(frame,'TOPLEFT', cooldownFrames[prevIndex], 'BOTTOMLEFT', 0, -2);
		frame:Show()
		if nextIndex ~= nil then BLCD:BLPoint(cooldownFrames[nextIndex],'TOPLEFT', frame, 'BOTTOMLEFT', 0, -2); end
	end
end

function BLCD:RemoveFrame(frame, prevIndex, nextIndex, cooldownFrames)
	if prevIndex == nil then
		frame:Hide()
		if nextIndex ~= nil then BLCD:BLPoint(cooldownFrames[nextIndex],'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2); end
	else
		frame:Hide()
		if nextIndex ~= nil then BLCD:BLPoint(cooldownFrames[nextIndex],'TOPLEFT', cooldownFrames[prevIndex], 'BOTTOMLEFT', 0, -2); end
	end
end
	
function BLCD:BLHeight(frame, height)
	if(Elv) then
		frame:Height(height)
	else
		frame:SetHeight(height)
	end
end

function BLCD:BLWidth(frame, width)
	if(Elv) then
		frame:Width(width)
	else
		frame:SetWidth(width)
	end
end

function BLCD:BLSize(frame, height, width)
	if(Elv) then
		frame:Size(height, width)
	else
		frame:SetSize(height, width)
	end
end

function BLCD:BLPoint(obj, arg1, arg2, arg3, arg4, arg5)
	if(Elv) then
		obj:Point(arg1, arg2, arg3, arg4, arg5)
	else
		obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
	end
end

function BLCD:BLTexture()
	if(Elv and false) then
		return E["media"].normTex
	else
		return "Interface\\AddOns\\BL_Cooldown\\media\\bar15.tga"
	end
end

function BLCD:BLFontTemplate(frame, x, y)
	if(Elv) then
		frame:FontTemplate(nil, x, y)
	else
		frame:SetFont("Interface\\AddOns\\BL_Cooldown\\media\\PT_Sans_Narrow.ttf", x, y)
		frame:SetShadowColor(0, 0, 0, 0.2)
		frame:SetShadowOffset(1, -1)
	end
end
--------------------------------------------------------