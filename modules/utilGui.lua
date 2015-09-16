--- Utility functions useful for defining GUIs.
local A, L = unpack(select(2, ...))
local M = A:NewModule("utilGui", "AceTimer-3.0")
A.utilGui = M
M.private = {
  openRaidTabTimer = false,
}
local R = M.private

local DELAY_OPEN_RAID_TAB = 0.01
local ChatFrame_OpenChat, GetCurrentKeyBoardFocus, InterfaceOptionsFrame, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, ToggleFriendsFrame = ChatFrame_OpenChat, GetCurrentKeyBoardFocus, InterfaceOptionsFrame, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, ToggleFriendsFrame
local strmatch = strmatch

-- GLOBALS: ElvUI

function M:OpenRaidTab()
  if not R.openRaidTabTimer then
    -- In case we just called SetRaidSubgroup or SwapRaidSubgroup, add in a
    -- short delay to avoid confusing the Blizzard UI addon.
    R.openRaidTabTimer = M:ScheduleTimer(function()
      R.openRaidTabTimer = false
      OpenFriendsFrame(4)
    end, DELAY_OPEN_RAID_TAB)
  end
end

function M:ToggleRaidTab()
  ToggleFriendsFrame(4)
end

function M:OpenConfig()
  InterfaceOptionsFrame_OpenToCategory(A.NAME)
  InterfaceOptionsFrame_OpenToCategory(A.NAME)
end

function M:CloseConfig()
  if InterfaceOptionsFrame:IsShown() then
    InterfaceOptionsFrame:Hide()
  end
end

function M:InsertText(text)
  local editBox = GetCurrentKeyBoardFocus()
  if editBox then
    if not strmatch(editBox:GetText(), "%s$") then
      text = " "..text
    end
    editBox:Insert(text)
  else
    ChatFrame_OpenChat(text)
  end
end

function M:GetElvUISkinModule()
  if IsAddOnLoaded("ElvUI") and ElvUI then
    local E = ElvUI[1]
    if E.private.skins.blizzard.enable and E.private.skins.blizzard.nonraid then
      return E:GetModule("Skins")
    end
  end
end
