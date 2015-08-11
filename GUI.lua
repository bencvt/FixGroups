local A, L = unpack(select(2, ...))
local M = A:NewModule("GUI")
A.gui = M

local function handleClick(_, button)
  if button == "RightButton" then
    if IsShiftKeyDown() then
      A.console:Command("meter")
    else
      A.console:Command("split")
    end
  else
    if IsShiftKeyDown() then
      A.console:Command("config")
    elseif IsControlKeyDown() then
      A.console:Command("nosort")
    else
      A.console:Command("default")
    end
  end
end

local function setTooltip(tooltip, isRaidTab)
  -- Commented-out lines are undocumented shortcuts that are subject to
  -- change or removal in a future version of this addon.
  tooltip:ClearLines()
  if not isRaidTab then
    tooltip:AddLine(FixGroups.name)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["Left Click"], L["Fix groups"], 1, 1, 1, 1, 1, 0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["Right Click"], L["Split raid into two sides based on"], 1, 1, 1, 1, 1, 0)
  tooltip:AddDoubleLine(" ",              L["overall damage/healing done"], 1, 1, 1, 1, 1, 0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["Hold Shift + Left Click"], L["Open config"], 1, 1, 1, 1, 1, 0)
  --tooltip:AddLine(" ")
  --tooltip:AddDoubleLine(L["Hold Shift + Right Click"], L["Fix groups, sorting by"], 1, 1, 1, 1, 1, 0)
  --tooltip:AddDoubleLine(" ",                        L["overall damage/healing done"], 1, 1, 1, 1, 1, 0)
  --tooltip:AddLine(" ")
  --tooltip:AddDoubleLine(L["Hold Ctrl + Left Click"], L["Fix tanks and ML only, no sorting"], 1, 1, 1, 1, 1, 0)
  if not isRaidTab then
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(L["Hold Left Click + Drag"], L["Move minimap icon"], 1, 1, 1, 1, 1, 0)
  end
  tooltip:Show()
end

function M:OnEnable()
  if not M.icon then
    -- Create minimap icon
    M.iconLDB = LibStub("LibDataBroker-1.1"):NewDataObject(A.name, {
      type = "launcher",
      text = A.name,
      icon = "Interface\\ICONS\\INV_Misc_GroupLooking",
      OnClick = handleClick,
      OnTooltipShow = setTooltip,
    })
    M.icon = LibStub("LibDBIcon-1.0")
    M.icon:Register(A.name, M.iconLDB, A.options.minimapIcon)
  end

  if not M.raidTabButton then
    -- Create button on raid tab
    local b = CreateFrame("BUTTON", nil, RaidFrame, "UIPanelButtonTemplate")
    b:SetPoint("TOPRIGHT", RaidFrameRaidInfoButton, "TOPLEFT", 0, 0)
    b:SetSize(RaidFrameRaidInfoButton:GetWidth(), RaidFrameRaidInfoButton:GetHeight())
    b:GetFontString():SetFont(RaidFrameRaidInfoButton:GetFontString():GetFont())
    b:SetText(L["Fix Groups"])
    b:RegisterForClicks("AnyUp")
    b:SetScript("OnClick", handleClick)
    b:SetScript("OnEnter", function (frame) GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT") setTooltip(GameTooltip, true) end)
    b:SetScript("OnLeave", function () GameTooltip:Hide() end)
    if IsAddOnLoaded("ElvUI") then
      local E = unpack(ElvUI)
      if E.private.skins.blizzard.enable == true and E.private.skins.blizzard.nonraid == true then
        local S = E:GetModule("Skins")
        b:StripTextures()
        S:HandleButton(b)
      end
    end
    if A.options.addButtonToRaidTab then
      b:Show()
    else
      b:Hide()
    end
    M.raidTabButton = b
  end

  M:Refresh()
end

function M:OnDisable()
  M:Refresh()
end

function M:OpenRaidTab()
  OpenFriendsFrame(4)
end

function M:OpenConfig()
  InterfaceOptionsFrame_OpenToCategory(A.name)
  InterfaceOptionsFrame_OpenToCategory(A.name)
end

function M:FlashRaidTabButton()
  if M.flashTimer or not A.options.addButtonToRaidTab then
    return
  end
  local count = 6
  local function flash()
    count = count - 1
    if count % 2 == 0 then
      M.raidTabButton:UnlockHighlight()
    else
      M.raidTabButton:LockHighlight()
    end
    if count > 0 then
      M.flashTimer = A:ScheduleTimer(flash, 0.5)
    else
      M.flashTimer = nil
    end
  end
  flash()
end

local function setUI(buttonEnable, buttonText, iconTexture)
  M.iconLDB.icon = iconTexture
  M.raidTabButton:SetText(buttonText)
  if buttonEnable then
    M.raidTabButton:Enable()
  else
    M.raidTabButton:Disable()
  end
end

function M:Refresh()
  if not M:IsEnabled() then
    M.icon:Hide(A.name)
    M.raidTabButton:Hide()
    return
  end
  if A.sorter:IsProcessing() then
    setUI(false, L["Rearranging..."], "Interface\\TIMEMANAGER\\FFButton")
  elseif A.sorter:IsPaused() then
    setUI(false, L["In Combat..."], "Interface\\TIMEMANAGER\\PauseButton")
  elseif A.util:IsLeader() then
    setUI(true, L["Fix Groups"], "Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  elseif A.util:IsLeaderOrAssist() then
    setUI(true, L["Fix Groups"], "Interface\\GROUPFRAME\\UI-GROUP-ASSISTANTICON")
  else
    setUI(true, L["Fix Groups"], "Interface\\ICONS\\INV_Misc_GroupLooking")
  end
  if A.options.showMinimapIconAlways or (A.options.showMinimapIconPRN and A.util:IsLeaderOrAssist()) then
    M.icon:Show(A.name)
  else
    M.icon:Hide(A.name)
  end
  if A.options.addButtonToRaidTab then
    M.raidTabButton:Show()
  else
    M.raidTabButton:Hide()
  end
end
