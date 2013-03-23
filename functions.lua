--------------------------------------------------------
-- Blood Legion Raidcooldowns - Functions --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local LGIST=LibStub:GetLibrary("LibGroupInSpecT-1.0")
local BLCB = LibStub("LibBlCandyBar-3.0")
local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

--------------------------------------------------------

--------------------------------------------------------
-- Helper Functions --
--------------------------------------------------------
function BLCD:GetPartyType()
    return ((select(2, IsInInstance()) == "pvp" and "battleground") or (select(2, IsInInstance()) == "arena" and "battleground") or (IsInRaid() and "raid") or (GetNumSubgroupMembers() > 0 and "party") or "none") 
end

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
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
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
--------------------------------------------------------

--------------------------------------------------------
-- Display Bar Functions --
--------------------------------------------------------
local function barSorter(a, b)
	return a.remaining < b.remaining and true or false
end

function BLCD:RearrangeBars(anchor)
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
			bar:Stop()
			anchor.bars[bar] = nil
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


function BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration,spell)
	local bar = BLCB:New(BLCD:BLTexture(), 100, 9)
	frameicon.bars[bar] = true
	bar:Set("raidcooldowns:module", "raidcooldowns")
	bar:Set("raidcooldowns:anchor", frameicon)
	bar:Set("raidcooldowns:key", guid)
	bar:Set("raidcooldowns:spell", spell)
	bar:Set("raidcooldowns:caster", caster)
	bar:Set("raidcooldowns:cooldown", cooldown)
	bar:SetParent(frameicon)
	bar:SetFrameStrata("MEDIUM")
	bar:SetColor(.5,.5,.5,1);	
	bar:SetDuration(duration)
	bar:SetScale(BLCD.profileDB.scale)
	bar:SetClampedToScreen(true)

	local caster = strsplit("-",caster)
	bar:SetLabel(caster)
	
	bar.blCandyBarLabel:SetJustifyH("LEFT")
	BLCD:BLCreateBG(bar)
	
	bar:Start()

	BLCD:RearrangeBars(frameicon)
	
	return bar
end

function BLCD:CancelBars(frameicon)
    for k in pairs(frameicon.bars) do
        k:Stop()
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
	elseif(grouptype == "none") then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "raid" and grouptype =="raid") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "raid" and grouptype ~="raid") then
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
		print("|cffc41f3bBlood Legion Cooldown|r: unlocked")
	else
		raidcdbasemover:EnableMouse(false)
		raidcdbasemover:RegisterForDrag(nil)
		raidcdbasemover:Hide()
		BLCD.locked = true
		print("|cffc41f3bBlood Legion Cooldown|r: locked")
	end
end
--------------------------------------------------------

--------------------------------------------------------
-- Frame Functions --
--------------------------------------------------------
function BLCD:OnEnter(self, cooldown)
   local parent = self:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",3, 14)
	GameTooltip:ClearLines()
	GameTooltip:AddSpellByID(cooldown['spellID'])
	GameTooltip:Show()
end

function BLCD:OnLeave(self)
   GameTooltip:Hide()
end

function BLCD:PostClick(self, cooldown, rosterCD, curr)
	if(BLCD.profileDB.clickannounce) then
		local allCD,onCD = rosterCD, curr
		local name = GetSpellInfo(cooldown['spellID'])
		for i,v in pairs(onCD) do
			allCD[i] = nil
		end
	
		if next(allCD) ~= nil then
			SendChatMessage('----- '..name..' -----','raid')
			for i,v in pairs(allCD) do
				SendChatMessage(v..' ready!','raid')
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
	for i=1,BLCD.active do
		BLCD:BLHeight(_G['BLCooldown'..i],28*BLCD.profileDB.scale);
		BLCD:BLWidth(_G['BLCooldown'..i],145*BLCD.profileDB.scale);	
		BLCD:BLSize(_G['BLCooldownIcon'..i],28*BLCD.profileDB.scale);
		BLCD:BLFontTemplate(_G['BLCooldownIcon'..i].text, 20*BLCD.profileDB.scale, 'OUTLINE')
	end
end

function BLCD:SetBarGrowthDirection(frame, frameicon, index)
	if(BLCD.profileDB.growth == "left") then
	    if index == 1 then
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldownBase_Frame', 'TOPRIGHT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldown'..(index-1), 'BOTTOMRIGHT', 0, -4);
		end
		BLCD:BLPoint(frameicon,'TOPRIGHT', frame, 'TOPRIGHT');
	elseif(BLCD.profileDB.growth  == "right") then
		if index == 1 then
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldown'..(index-1), 'BOTTOMLEFT', 0, -4);
		end
		BLCD:BLPoint(frameicon,'TOPLEFT', frame, 'TOPLEFT');
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
	if(Elv) then
		return E["media"].normTex
	else
		return "Interface\\AddOns\\BL_Cooldown\\statusbar"	
	end
end

function BLCD:BLFontTemplate(frame, x, y)
	if(Elv) then
		frame:FontTemplate(nil, x, y)
	else
		frame:SetFont("Fonts\\FRIZQT__.TTF", x, y)
	end
end
--------------------------------------------------------