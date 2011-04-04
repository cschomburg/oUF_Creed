oUF_Creed = oUF_Creed or {units={}}

local function baseFrame(self, unit, mirrored)
	self:SetAttribute('initial-height', 40)
	self:SetAttribute('initial-width', 220)
	self.Mirrored = mirrored

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture[[Interface\AddOns\oUF_Creed\textures\background-white]]
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("TOPRIGHT")
	bg:SetHeight(80)
	if(mirrored) then
		bg:SetTexCoord(1, 0, 0, 1)
	end
	self.bg = bg

	local cb = CreateFrame("StatusBar", nil, self)
	cb:SetStatusBarTexture[[Interface\AddOns\oUF_Creed\textures\dna]]
	cb:SetStatusBarColor(0.8, 0.95, 1, .3)
	if(mirrored) then
		cb:SetPoint("TOPRIGHT", -45, -11)
	else
		cb:SetPoint("TOPLEFT", 45, -11)
	end
	cb:SetWidth(160)
	cb:SetHeight(35)
	self.Castbar = cb

	local hp = CreateFrame("StatusBar", nil, self)
	hp:SetWidth(160)
	hp:SetHeight(16)
	hp:SetStatusBarTexture[[Interface\AddOns\oUF_Creed\textures\bar-blue]]
	hp.frequentUpdates = true
	if(mirrored) then
		hp:SetPoint("TOPRIGHT", -45, -14)
	else
		hp:SetPoint("TOPLEFT", 45, -14)
	end
	self.Health = hp

	local hpp = self:CreateFontString(nil, "OVERLAY")
	if(mirrored) then
		hpp:SetPoint("LEFT", self, "RIGHT", 5, 0)
	else
		hpp:SetPoint("RIGHT", self, "LEFT", -5, 0)
	end
	hpp:SetFont([[Interface\AddOns\oUF_Creed\textures\font.ttf]], 16)
	hpp:SetTextColor(1, 1, 1)
	hpp:SetShadowOffset(1, -1)
	hp.value = hpp

	local pp = CreateFrame("StatusBar", nil, self)
	pp.frequentUpdates = true
	pp:SetParent(self)
	self.Power = pp

	local ppp = self:CreateFontString(nil, "OVERLAY")
	if(mirrored) then
		ppp:SetPoint("LEFT", hpp, "RIGHT")
	else
		ppp:SetPoint("RIGHT", hpp, "LEFT")
	end
	ppp:SetFont([[Interface\AddOns\oUF_Creed\textures\font.ttf]], 16)
	ppp:SetTextColor(1, 1, 1)
	ppp:SetShadowOffset(1, -1)
	pp.value = ppp

	local name = self:CreateFontString(nil, "OVERLAY")
	if(mirrored) then
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 15, 0)
	else
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -15, 0)
	end
	name:SetFont([[Interface\AddOns\oUF_Creed\textures\font.ttf]], 16)
	name:SetTextColor(1, 1, 1)
	name:SetShadowOffset(1, -1)
	self.Name = name
end

oUF_Creed.units.player = function(self, unit)
	baseFrame(self, unit)

	local triangle = self:CreateTexture(nil, "OVERLAY")
	triangle:SetTexture[[Interface\AddOns\oUF_Creed\textures\triangle-small-blue]]
	triangle:SetPoint("TOPLEFT", 8, -4)
	triangle:SetWidth(30)
	triangle:SetHeight(30)
	self.triangle = triangle
end

oUF_Creed.units.target = function(self, unit)
	baseFrame(self, unit, true)

	local combo = self:CreateFontString(nil, "OVERLAY")
	combo:SetPoint("TOP", self, "TOPRIGHT", -24, -12)
	combo:SetFont([[Interface\AddOns\oUF_Creed\textures\font.ttf]], 16)
	self.CPoints = combo

	local buffs = CreateFrame("Frame", nil, self)
	buffs.initialAnchor = "TOPRIGHT"
	buffs["growth-x"] = "LEFT"
	buffs:SetPoint("TOPRIGHT", self, "BOTTOM", 0, -2)

	buffs:SetHeight(16)
	buffs:SetWidth(8 * 24)
	buffs.onlyShowPlayer = true
	buffs.disableCooldown = true
	buffs.spacing = 2
	buffs.num = 8
	buffs.size = 22
	buffs:SetAlpha(0.5)

	self.Buffs = buffs

	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetPoint("TOPLEFT", self, "BOTTOM", 0, -2)
	debuffs.showDebuffType = true
	debuffs.initialAnchor = "TOPLEFT"

	debuffs:SetHeight(16)
	debuffs:SetWidth(8 * 24)
	debuffs.disableCooldown = true
	debuffs.spacing = 2
	debuffs.num = 8
	debuffs.size = 22
	debuffs:SetAlpha(0.5)

	self.Debuffs = debuffs
end