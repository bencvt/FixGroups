-- Defines FixGroups:SetupUI, :FlashRaidTabButton, and :UpdateUI

local function setTooltip(tooltip, isRaidTab)
  -- Commented-out lines are undocumented shortcuts that are subject to
  -- change or removal in a future version of this addon.
  tooltip:ClearLines()
  if not isRaidTab then
    tooltip:AddLine(FixGroups.name)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine("Left Click", "Fix groups", 1, 1, 1, 1, 1, 0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine("Right Click", "Split raid into two sides based on", 1, 1, 1, 1, 1, 0)
  tooltip:AddDoubleLine(" ",           "overall damage/healing done", 1, 1, 1, 1, 1, 0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine("Hold Shift + Left Click", "Open config", 1, 1, 1, 1, 1, 0)
  --tooltip:AddLine(" ")
  --tooltip:AddDoubleLine("Hold Shift + Right Click", "Fix groups, sorting by", 1, 1, 1, 1, 1, 0)
  --tooltip:AddDoubleLine(" ",                        "overall damage/healing done", 1, 1, 1, 1, 1, 0)
  --tooltip:AddLine(" ")
  --tooltip:AddDoubleLine("Hold Ctrl + Left Click", "Fix tanks and ML only, no sorting", 1, 1, 1, 1, 1, 0)
  if not isRaidTab then
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine("Hold Left Click + Drag", "Move minimap icon", 1, 1, 1, 1, 1, 0)
  end
  tooltip:Show()
end

local function handleClick(_, button)
  if button == "RightButton" then
    if IsShiftKeyDown() then
      FixGroups:Command("meter")
    else
      FixGroups:Command("split")
    end
  else
    if IsShiftKeyDown() then
      FixGroups:Command("config")
    elseif IsControlKeyDown() then
      FixGroups:Command("nosort")
    else
      FixGroups:Command("default")
    end
  end
end

function FixGroups:SetupUI()
  if self.ui then
    self:UpdateUI()
    return
  end
  self.ui = {}

  -- Create minimap icon
  self.ui.iconLDB = LibStub("LibDataBroker-1.1"):NewDataObject(self.name, {
    type = "launcher",
    text = self.name,
    icon = "Interface\\ICONS\\INV_Misc_GroupLooking",
    OnClick = handleClick,
    OnTooltipShow = setTooltip,
  })
  self.ui.icon = LibStub("LibDBIcon-1.0")
  self.ui.icon:Register(self.name, self.ui.iconLDB, self.options.minimapIcon)

  -- Create button on raid tab
  local b = CreateFrame("BUTTON", nil, RaidFrame, "UIPanelButtonTemplate")
  b:SetPoint("TOPRIGHT", RaidFrameRaidInfoButton, "TOPLEFT", 0, 0)
  b:SetSize(RaidFrameRaidInfoButton:GetWidth(), RaidFrameRaidInfoButton:GetHeight())
  b:GetFontString():SetFont(RaidFrameRaidInfoButton:GetFontString():GetFont())
  b:SetText("Fix Groups")
  b:RegisterForClicks("AnyUp")
  b:SetScript("OnClick", handleClick)
  b:SetScript("OnEnter", function (self) GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT") setTooltip(GameTooltip, true) end)
  b:SetScript("OnLeave", function () GameTooltip:Hide() end)
  if IsAddOnLoaded("ElvUI") then
    local E = unpack(ElvUI)
    if E.private.skins.blizzard.enable == true and E.private.skins.blizzard.nonraid == true then
      local S = E:GetModule("Skins")
      b:StripTextures()
      S:HandleButton(b)
    end
  end
  if self.options.addButtonToRaidTab then
    b:Show()
  else
    b:Hide()
  end
  self.ui.raidTabButton = b

  -- Done.
  self:UpdateUI()
end

local function setUI(buttonEnable, buttonText, iconTexture)
  FixGroups.ui.iconLDB.icon = iconTexture
  FixGroups.ui.raidTabButton:SetText(buttonText)
  if buttonEnable then
    FixGroups.ui.raidTabButton:Enable()
  else
    FixGroups.ui.raidTabButton:Disable()
  end
end

function FixGroups:FlashRaidTabButton()
  if self.ui.flashTimer or not self.options.addButtonToRaidTab then
    return
  end
  local count = 6
  local function flash()
    count = count - 1
    if count % 2 == 0 then
      self.ui.raidTabButton:UnlockHighlight()
    else
      self.ui.raidTabButton:LockHighlight()
    end
    if count > 0 then
      self.ui.flashTimer = self:ScheduleTimer(flash, 0.5)
    else
      self.ui.flashTimer = nil
    end
  end
  flash()
end

function FixGroups:UpdateUI()
  if not self.enabled then
    self.ui.icon:Hide(self.name)
    self.ui.raidTabButton:Hide()
    return
  end
  if self:IsProcessing() then
    setUI(false, "Rearranging...", "Interface\\TIMEMANAGER\\FFButton")
  elseif self:IsPaused() then
    setUI(false, "In Combat...", "Interface\\TIMEMANAGER\\PauseButton")
  elseif self:IsLeader() then
    setUI(true, "Fix Groups", "Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  elseif self:IsLeaderOrAssist() then
    setUI(true, "Fix Groups", "Interface\\GROUPFRAME\\UI-GROUP-ASSISTANTICON")
  else
    setUI(true, "Fix Groups", "Interface\\ICONS\\INV_Misc_GroupLooking")
  end
  if self.options.showMinimapIconAlways or (self.options.showMinimapIconPRN and self:IsLeaderOrAssist()) then
    self.ui.icon:Show(self.name)
  else
    self.ui.icon:Hide(self.name)
  end
  if self.options.addButtonToRaidTab then
    self.ui.raidTabButton:Show()
  else
    self.ui.raidTabButton:Hide()
  end
end
