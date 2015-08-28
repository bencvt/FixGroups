local A, L = unpack(select(2, ...))
local M = A:NewModule("buttonGui", "AceEvent-3.0", "AceTimer-3.0")
A.buttonGui = M
M.private = {
  icon = false,
  iconLDB = false,
  raidTabButton = false,
  flashTimer = false,
}
local R = M.private

local NUM_FLASHES = 3
local DELAY_FLASH = 0.5

local format, strfind, strlower = format, strfind, strlower
local CreateFrame, IsAddOnLoaded, InCombatLockdown, IsControlKeyDown, IsInGroup, IsShiftKeyDown, UnitName = CreateFrame, IsAddOnLoaded, InCombatLockdown, IsControlKeyDown, IsInGroup, IsShiftKeyDown, UnitName
-- GLOBALS: LibStub, ElvUI, GameTooltip, RaidFrame, RaidFrameRaidInfoButton

local LOCALE_KW_1 = strlower(string.trim(L["chatKeyword.fixGroups"]))
local LOCALE_KW_2 = strlower(string.trim(L["chatKeyword.markTanks"]))

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

local function watchChat(event, message, sender)
  if A.DEBUG >= 1 then A.console:Debugf(M, "watchChat event=%s message=[%s] sender=%s", event, A.util:Escape(message), sender) end
  if A.options.watchChat and sender ~= UnitName("player") and message and A.sorter:CanBegin() then
    -- Search for both the default and the localized keywords.
    message = strlower(message)
    if strfind(message, "fix group") or strfind(message, "mark tank") or strfind(message, LOCALE_KW_1) or strfind(message, LOCALE_KW_2) then
      M:FlashRaidTabButton()
    end
  end
end

local function refresh()
  M:Refresh()
end

local function setupMinimapIcon()
  if R.icon then
    return
  end
  R.iconLDB = LibStub("LibDataBroker-1.1"):NewDataObject(A.NAME, {
    type = "launcher",
    text = A.NAME,
    icon = "Interface\\ICONS\\INV_Misc_GroupLooking",
    OnClick = handleClick,
    OnTooltipShow = function (tooltip) M:SetupTooltip(tooltip, true) end,
  })
  R.icon = LibStub("LibDBIcon-1.0")
  R.icon:Register(A.NAME, R.iconLDB, A.options.minimapIcon)
end

local function setupRaidTabButton()
  if R.raidTabButton then
    return
  end
  local b = CreateFrame("BUTTON", nil, RaidFrame, "UIPanelButtonTemplate")
  b:SetPoint("TOPRIGHT", RaidFrameRaidInfoButton, "TOPLEFT", 0, 0)
  b:SetSize(RaidFrameRaidInfoButton:GetWidth(), RaidFrameRaidInfoButton:GetHeight())
  b:GetFontString():SetFont(RaidFrameRaidInfoButton:GetFontString():GetFont())
  b:SetText(L["button.fixGroups.text"])
  b:RegisterForClicks("AnyUp")
  b:SetScript("OnClick", handleClick)
  b:SetScript("OnEnter", function (frame) GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT") M:SetupTooltip(GameTooltip, false) end)
  b:SetScript("OnLeave", function () GameTooltip:Hide() end)
  if IsAddOnLoaded("ElvUI") and ElvUI then
    local E = ElvUI[1]
    if E.private.skins.blizzard.enable and E.private.skins.blizzard.nonraid then
      b:StripTextures()
      E:GetModule("Skins"):HandleButton(b)
    end
  end
  if A.options.addButtonToRaidTab then
    b:Show()
  else
    b:Hide()
  end
  R.raidTabButton = b
end

function M:OnEnable()
  M:RegisterEvent("PLAYER_ENTERING_WORLD",          refresh)
  M:RegisterEvent("GROUP_ROSTER_UPDATE",            refresh)
  M:RegisterEvent("CHAT_MSG_INSTANCE_CHAT",         watchChat)
  M:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER",  watchChat)
  M:RegisterEvent("CHAT_MSG_RAID",                  watchChat)
  M:RegisterEvent("CHAT_MSG_RAID_LEADER",           watchChat)
  M:RegisterEvent("CHAT_MSG_SAY",                   watchChat)
  M:RegisterEvent("CHAT_MSG_WHISPER",               watchChat)
  setupMinimapIcon()
  setupRaidTabButton()
end

function M:SetupTooltip(tooltip, isMinimapIcon)
  tooltip:ClearLines()
  if IsInGroup() then
    tooltip:AddDoubleLine(A.NAME, A.group:GetComp(1))
  else
    tooltip:AddLine(A.NAME)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["phrase.mouse.clickLeft"],        L["tooltip.right.fixGroups"], 1,1,1, 1,1,0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["phrase.mouse.clickRight"],       L["tooltip.right.split.1"],   1,1,1, 1,1,0)
  tooltip:AddDoubleLine(" ",                                L["tooltip.right.split.2"],   1,1,1, 1,1,0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["phrase.mouse.shiftClickLeft"],   L["tooltip.right.config"],    1,1,1, 1,1,0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(L["phrase.mouse.shiftClickRight"],  L["tooltip.right.meter.1"],   1,1,1, 1,1,0)
  tooltip:AddDoubleLine(" ",                                L["tooltip.right.meter.2"],   1,1,1, 1,1,0)
  -- Ctrl + Left Click is an undocumented shortcut, subject to change or removal
  -- in a future version of this addon.
  --tooltip:AddLine(" ")
  --tooltip:AddDoubleLine(L["phrase.mouse.ctrlClickLeft"],    L["tooltip.right.nosort"],    1,1,1, 1,1,0)
  if isMinimapIcon then
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(L["phrase.mouse.drag"],           L["tooltip.right.moveMinimapIcon"], 1,1,1, 1,1,0)
  end
  tooltip:Show()
end

function M:OnDisable()
  M:Refresh()
end

function M:ButtonPress(button)
  handleClick(button)
end

function M:FlashRaidTabButton()
  A.util:OpenRaidTab()
  if R.flashTimer or not A.options.addButtonToRaidTab then
    return
  end
  local count = NUM_FLASHES * 2
  local function flash()
    count = count - 1
    if count % 2 == 0 then
      R.raidTabButton:UnlockHighlight()
    else
      R.raidTabButton:LockHighlight()
    end
    if count > 0 then
      R.flashTimer = M:ScheduleTimer(flash, DELAY_FLASH)
    else
      R.flashTimer = false
    end
  end
  flash()
end

local function setUI(buttonText, iconTexture)
  R.iconLDB.icon = iconTexture
  R.raidTabButton:SetText(L[buttonText])
  if buttonText == "button.fixGroups.text" then
    R.raidTabButton:Enable()
  else
    R.raidTabButton:Disable()
  end
end

function M:Refresh()
  if not M:IsEnabled() then
    R.icon:Hide(A.NAME)
    R.raidTabButton:Hide()
    return
  end
  if A.sorter:IsProcessing() then
    setUI("button.fixGroups.working.text", "Interface\\TIMEMANAGER\\FFButton")
  elseif A.sorter:IsPaused() then
    setUI("button.fixGroups.paused.text", "Interface\\TIMEMANAGER\\PauseButton")
  elseif A.util:IsLeader() then
    setUI("button.fixGroups.text", "Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  elseif A.util:IsLeaderOrAssist() then
    setUI("button.fixGroups.text", "Interface\\GROUPFRAME\\UI-GROUP-ASSISTANTICON")
  else
    setUI("button.fixGroups.text", "Interface\\ICONS\\INV_Misc_GroupLooking")
  end
  if A.options.showMinimapIconAlways or (A.options.showMinimapIconPRN and A.util:IsLeaderOrAssist()) then
    R.icon:Show(A.NAME)
  else
    R.icon:Hide(A.NAME)
  end
  if A.options.addButtonToRaidTab then
    R.raidTabButton:Show()
  else
    R.raidTabButton:Hide()
  end
end
