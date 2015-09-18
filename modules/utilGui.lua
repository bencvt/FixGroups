--- Utility functions useful for defining GUIs.
local A, L = unpack(select(2, ...))
local M = A:NewModule("utilGui", "AceTimer-3.0")
A.utilGui = M
M.private = {
  openRaidTabTimer = false,
}
local R = M.private

local DELAY_OPEN_RAID_TAB = 0.01
local ChatFrame_OpenChat, GameFontHighlightLarge, GetCurrentKeyBoardFocus, GetBindingFromClick, InterfaceOptionsFrame, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, PlaySound, ToggleFriendsFrame = ChatFrame_OpenChat, GameFontHighlightLarge, GetCurrentKeyBoardFocus, GetBindingFromClick, InterfaceOptionsFrame, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, PlaySound, ToggleFriendsFrame
local format, max, strmatch = format, max, strmatch

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

function M:AddTexturedButton(registry, button, style)
  if M:GetElvUISkinModule() then
    button.frame:SetNormalTexture(format("Interface\\Addons\\%s\\media\\button%sFlat.tga", A.NAME, style))
    button.frame:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)
  else
    button.frame:SetNormalTexture(format("Interface\\Addons\\%s\\media\\button%sUp.tga", A.NAME, style))
    button.frame:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)
    button.frame:SetHighlightTexture(format("Interface\\Addons\\%s\\media\\button%sHighlight.tga", A.NAME, style))
    button.frame:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.71875)
  end
  registry[button] = true
end

--- Remove the custom button textures from AceGUI button objects. This should
-- be called prior to releasing button widgets back into the pool (i.e.,
-- calling AceGUI:Release).
function M:CleanupTexturedButton(registry)
  for button, _ in pairs(registry) do
    registry[button] = nil
    button.frame:SetNormalTexture(nil)
    button.frame:SetHighlightTexture(nil)
  end
end

local FILL_PLUS_STATUS_BAR = A.NAME.."FillPlusStatusBar"
local AceGUI = LibStub("AceGUI-3.0")
local noop = function() return 0 end
local dummy = {
  [1] = {
    SetWidth = noop,
    SetHeight = noop,
    frame = {
      SetAllPoints = noop,
      Show = noop,
    },
  },
}
AceGUI:RegisterLayout(FILL_PLUS_STATUS_BAR, function(content, children)
  if #children < 2 or #children[2].children < 2 then
    return
  end
  local top, bottom = children[1], children[2]
  local statusBar, closeButton = bottom.children[1], bottom.children[2]
  local barHeight = max(statusBar.frame:GetHeight(), closeButton.frame:GetHeight())

	top.frame:SetPoint("TOPLEFT")
  top:SetWidth(content:GetWidth() or 0)
  top:SetHeight((content:GetHeight() or 0) - barHeight)
  top.frame:Show()

  statusBar:SetWidth((content:GetWidth() or 0) - closeButton.frame:GetWidth() - 4)
	bottom.frame:SetPoint("BOTTOMLEFT")
  bottom:SetWidth(content:GetWidth() or 0)
  bottom:SetHeight(barHeight)
  bottom.frame:Show()

  -- Ensure content.obj:LayoutFinished gets called
  dummy[1].frame.GetHeight = function() return top.frame:GetHeight() + barHeight end
  AceGUI.LayoutRegistry.FILL(content, dummy)
end)

function M:SetupWindow(window)
  window.frame:SetPropagateKeyboardInput(true)
  window.frame:SetScript("OnKeyDown", function(frame, key)
    if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
      frame:SetPropagateKeyboardInput(false)
      window:CloseWithSound()
    end
  end)
  window:SetLayout("Fill")

  local container = AceGUI:Create("SimpleGroup")
  container:SetLayout(FILL_PLUS_STATUS_BAR)
  -- Explicitly set an empty backdrop so ElvUI won't skin this frame.
  container.frame:SetBackdrop(nil)
  window:AddChild(container)

  local top = AceGUI:Create("ScrollFrame")
  top:SetLayout("Flow")
  container:AddChild(top)

  local bottom = AceGUI:Create("SimpleGroup")
  bottom:SetLayout("Flow")
  -- Explicitly set an empty backdrop so ElvUI won't skin this frame.
  bottom.frame:SetBackdrop(nil)
  container:AddChild(bottom)

  local statusBar = AceGUI:Create("Label")
  statusBar:SetFontObject(GameFontHighlightLarge)
  statusBar:SetText(" ")
  bottom:AddChild(statusBar)

  -- Add custom functions to window.
  window.CloseWithSound = function()
    PlaySound("gsTitleOptionExit")
    window.frame:Hide()
  end
  window.SetStatusText = function(_, text)
    statusBar:SetText("  "..text)
  end

  local closeButton = AceGUI:Create("Button")
  closeButton:SetText(L["button.close.text"])
  closeButton:SetWidth(104)
  closeButton:SetCallback("OnClick", window.CloseWithSound)
  bottom:AddChild(closeButton)

  return top
end
