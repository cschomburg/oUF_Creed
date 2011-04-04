oUF_Creed_ = oUF_Creed or {units={}}

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local siValue = function(val)
	if(val >= 1e6) then
		return ('%.1f'):format(val / 1e6):gsub('%.', 'm')
	elseif(val >= 1e3) then
		return ("%.1f"):format(val / 1e3):gsub('%.', 'k')
	else
		return val
	end
end

local updateName = function(self, event, unit)
	if(self.unit == unit) then
		if(self.level) then
			self.level:SetText(UnitLevel(unit))
		end
	end
end

local OverrideUpdateHealth = function(self, event, unit, bar, min, max)
	if(UnitIsDead(unit)) then
		bar:SetValue(0)
		bar.value:SetText"[d]"
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText"[g]"
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"[x]"
	else
		if(not UnitIsFriend('player', unit)) then
			bar.value:SetFormattedText('%s', siValue(min))
		elseif(min ~= 0 and min ~= max) then
			bar.value:SetFormattedText("-%s", siValue(max - min))
		else
			bar.value:SetText(siValue(max))
		end
	end

	return updateName(self, event, unit)
end

local function delimeter(self, unit, text)
	local class, reaction = select(2, UnitClass(unit)), UnitReaction("player", unit)
	local r,g,b = 1,1,1
	if(class and UnitIsPlayer(unit)) then
		r, g, b = unpack(oUF.colors.class[class])
	elseif(reaction) then
		r, g, b = unpack(oUF.colors.reaction[reaction])
	end
	r,g,b = r*255,g*255,b*255

	if(self.Mirrored) then
		return ("|cff%2x%2x%2x\\\\|r %s"):format(r,g,b, text)
	else
		return ("%s |cff%2x%2x%2x//|r"):format(text, r,g,b)
	end
end

local PostCastStart = function(self, event, unit, spell, spellrank, castid)
	if(not self.Name) then return end

	self.Name:SetText(delimeter(self, unit, spell))
end

local PostCastStop = function(self, event, unit)
	-- Needed as we use it as a general update function.
	if(unit ~= self.unit or not self.Name) then return end

	local class, reaction = select(2, UnitClass(unit)), UnitReaction("player", unit)
	local r,g,b = 1,1,1
	if(class and UnitIsPlayer(unit)) then
		r, g, b = unpack(oUF.colors.class[class])
	elseif(reaction) then
		r, g, b = unpack(oUF.colors.reaction[reaction])
	end
	self.Name:SetText(delimeter(self, unit, UnitName(unit)))
end

local PostCreateAuraIcon = function(self, button)
	local count = button.count
	count:ClearAllPoints()
	count:SetPoint"BOTTOM"

	button.icon:SetTexCoord(.07, .93, .07, .93)
end

local PostUpdateAuraIcon = function(self, icons, unit, icon, index, offset, filter, isDebuff)
	icon.icon:SetDesaturated(true)
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if(min == 0 or max == 0 or not UnitIsConnected(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then
		bar.value:SetText()
		bar:SetValue(0)
	else
		bar.value:SetText(delimeter(self, unit, format("%.0f", min/max*100)))
	end
end

local RAID_TARGET_UPDATE = function(self, event)
	local index = GetRaidTargetIndex(self.unit)
	if(index) then
		self.RIcon:SetText(ICON_LIST[index].."22|t")
	else
		self.RIcon:SetText()
	end
end

local UnitSpecific = {
	pet = function(self)
		self:RegisterEvent("UNIT_HAPPINESS", updateName)
	end,

	party = function(self)
		local hp, pp = self.Health, self.Power
		local auras = CreateFrame("Frame", nil, self)
		auras:SetHeight(hp:GetHeight() + pp:GetHeight())
		auras:SetPoint("LEFT", self, "RIGHT")

		auras.showDebuffType = true

		auras:SetWidth(9 * 22)
		auras.size = 22
		auras.gap = true
		auras.numBuffs = 4
		auras.numDebuffs = 4

		self.Auras = auras

		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .5
	end,
}
UnitSpecific.focus = UnitSpecific.target

local Shared = function(self, unit)
	self.menu = menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	local leader = self:CreateTexture(nil, "OVERLAY")
	leader:SetHeight(16)
	leader:SetWidth(16)
	leader:SetPoint("BOTTOM", hp, "TOP", 0, -5)

	self.Leader = leader

	local masterlooter = self:CreateTexture(nil, 'OVERLAY')
	masterlooter:SetHeight(16)
	masterlooter:SetWidth(16)
	masterlooter:SetPoint('LEFT', leader, 'RIGHT')

	self.MasterLooter = masterlooter

	local ricon = self:CreateFontString(nil, "OVERLAY")
	ricon:SetPoint("LEFT", 2, 4)
	ricon:SetJustifyH"LEFT"
	ricon:SetFontObject(GameFontNormalSmall)
	ricon:SetTextColor(1, 1, 1)

	self.RIcon = ricon
	self:RegisterEvent("RAID_TARGET_UPDATE", RAID_TARGET_UPDATE)
	table.insert(self.__elements, RAID_TARGET_UPDATE)

	-- We inject our fake name element early in the cycle, in-case there is a
	-- spell cast in progress on the unit we target.
	self:RegisterEvent('UNIT_NAME_UPDATE', PostCastStop)
	table.insert(self.__elements, 2, PostCastStop)

	self.PostChannelStart = PostCastStart
	self.PostCastStart = PostCastStart

	self.PostCastStop = PostCastStop
	self.PostChannelStop = PostCastStop

	self.PostCreateAuraIcon = PostCreateAuraIcon
	self.PostUpdateAuraIcon = PostUpdateAuraIcon

	self.PostUpdatePower = PostUpdatePower

	self.OverrideUpdateHealth = OverrideUpdateHealth

	-- Small hack are always allowed...
	local unit = unit or 'party'
	if(oUF_Creed.units[unit]) then
		oUF_Creed.units[unit](self, unit)
	end
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF:RegisterStyle("Creed", Shared)

--[[
-- oUF does to this for, but only for the first layout registered. I'm mainly
-- adding it here so people know about it, especially since it's required for
-- layouts using different styles between party/partypet/raid/raidpet. It is
-- however smart to execute this function regardless.
--
-- There is a possibility that another layout has been registered before yours.
--]]
oUF:SetActiveStyle"Creed"

-- :Spawn(unit, frame_name, isPet) --isPet is only used on headers.
oUF:Spawn'pet':SetPoint('CENTER', 0, -450)
oUF:Spawn"player":SetPoint("RIGHT", UIParent, "CENTER", 50, -400)
oUF:Spawn"target":SetPoint("LEFT", UIParent, "CENTER", 50, -400)

--local party = oUF:Spawn("header", "oUF_Party")
--party:SetPoint("TOPLEFT", 30, -30)
--party:SetManyAttributes("showParty", true, 'showPlayer', true, "yOffset", -25)
--party:Show()
