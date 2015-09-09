local A, L = unpack(select(2, ...))
local M = A:NewModule("utilGui")
A.utilGui = M

local strmatch = strmatch
local CreateFrame, ChatFrame_OpenChat, GetBindingFromClick, GetCurrentKeyBoardFocus, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, ToggleFriendsFrame = CreateFrame, ChatFrame_OpenChat, GetBindingFromClick, GetCurrentKeyBoardFocus, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, OpenFriendsFrame, ToggleFriendsFrame
-- GLOBALS: ElvUI

function M:OpenRaidTab()
  OpenFriendsFrame(4)
end

function M:ToggleRaidTab()
  ToggleFriendsFrame(4)
end

function M:OpenConfig()
  InterfaceOptionsFrame_OpenToCategory(A.NAME)
  InterfaceOptionsFrame_OpenToCategory(A.NAME)
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

function M:AddCloseButton(aceGuiWindow, closeButtonTable, closeFunc)
  -- AceGUI puts the close button on the bottom right, which is fine.
  -- However for consistency's sake we also want an X in the upper right.
  -- We also have the close button catch the escape key.
  local C = closeButtonTable
  local skin = M:GetElvUISkinModule()

  C.frame = C.frame or CreateFrame("FRAME")
  C.frame:SetParent(aceGuiWindow.frame)
  C.frame:SetWidth(17)
  C.frame:SetHeight(40)
  C.frame:SetPoint("TOPRIGHT", skin and 0 or -16, 12)

  C.button = C.button or CreateFrame("BUTTON")
  C.button:SetParent(C.frame)
  C.button:SetWidth(30)
  C.button:SetHeight(30)
  C.button:SetPoint("CENTER", C.frame, "CENTER", 1, -1)
  C.button:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up.blp")
  C.button:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Down.blp")
  C.button:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight.blp")
  C.button:SetScript("OnClick", closeFunc)
  C.button:SetScript("OnKeyDown", function (button, key)
    if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
      closeFunc()
    end
  end)
  C.button:SetPropagateKeyboardInput(true)

  if skin then
    skin:HandleCloseButton(C.button)
  else
    C.borderTB = C.borderTB or C.frame:CreateTexture(nil, "BACKGROUND")
    C.borderTB:SetParent(C.frame)
    C.borderTB:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    C.borderTB:SetTexCoord(0.31, 0.67, 0, 0.63)
    C.borderTB:SetAllPoints(C.frame)

    C.borderL = C.borderL or C.frame:CreateTexture(nil, "BACKGROUND")
    C.borderL:SetParent(C.frame)
    C.borderL:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    C.borderL:SetTexCoord(0.235, 0.275, 0, 0.63)
    C.borderL:SetPoint("RIGHT", C.borderTB, "LEFT")
    C.borderL:SetWidth(10)
    C.borderL:SetHeight(40)

    C.borderR = C.borderR or C.frame:CreateTexture(nil, "BACKGROUND")
    C.borderR:SetParent(C.frame)
    C.borderR:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    C.borderR:SetTexCoord(0.72, 0.76, 0, 0.63)
    C.borderR:SetPoint("LEFT", C.borderTB, "RIGHT")
    C.borderR:SetWidth(10)
    C.borderR:SetHeight(40)
  end
end
