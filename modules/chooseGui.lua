local A, L = unpack(select(2, ...))
local M = A:NewModule("chooseGui")
A.chooseGui = M
M.private = {
  window = false,
  closeButton = {},
  mockSession = false,
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

local format, gsub, ipairs, strlower, tinsert = format, gsub, ipairs, strlower, tinsert
local tconcat = table.concat
local CreateFrame, GameFontHighlight, GameTooltip, GetBindingFromClick, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent = CreateFrame, GameFontHighlight, GameTooltip, GetBindingFromClick, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent
local CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_MALE = CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_MALE

local AceGUI = LibStub("AceGUI-3.0")

local function onCloseWindow(widget)
  R.window = false
  AceGUI:Release(widget)
end

local function onKeyDownCloseButton(button, key)
  if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
    M:Close()
  end
end

local function addPadding(frame)
  local padding = AceGUI:Create("Label")
  padding:SetText(" ")
  padding:SetFullWidth(true)
  frame:AddChild(padding)
  return padding
end

local function onLeaveButton(widget)
  GameTooltip:Hide()
  R.window:SetStatusText("")
end

local function getCommand(mode, modeType)
  return "/choose "..mode
end

local function addModeButton(frame, mode, modeType)
  local button = AceGUI:Create("Button")
  local label
  if mode == "option2" then
    mode = format("%s %s %s", L["letter.1"], L["word.or"], L["letter.2"])
    label = mode
  elseif mode == "option3+" then
    mode = format("%s, %s, %s", L["letter.1"], L["letter.2"], L["letter.3"])
    label = mode..", ..."
  else
    label = A.chooseCommand.MODE_ALIAS[mode].primary
    if modeType == "tierToken" then
      label = A.util:LocaleLowerNoun(label)
    end
  end
  button:SetText(label)
  button:SetCallback("OnClick", function(widget)
    if IsShiftKeyDown() then
      A.util:InsertText(getCommand(mode, modeType))
      return
    end
    --TODO right-click to /list instead of /choose. Do a /listself in the tooltip.
    A.chooseCommand:Command("choose", mode)
    if IsControlKeyDown() then
      R.window:Hide()
    end
  end)
  button:SetCallback("OnEnter", function(widget)
    M:SetupTooltip(widget, mode, modeType)
  end)
  button:SetCallback("OnLeave", onLeaveButton)
  button:SetWidth(104)
  frame:AddChild(button)
  return button
end

local function addCloseButton()
  -- AceGUI puts the close button on the bottom right, which is fine.
  -- However for consistency's sake we also want an X in the upper right.
  -- We also have the close button catch the escape key.
  local C = R.closeButton
  local skin = A.util:GetElvUISkinModule()

  C.frame = C.frame or CreateFrame("FRAME")
  C.frame:SetParent(R.window.frame)
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
  C.button:SetScript("OnClick", M.Close)
  C.button:SetScript("OnKeyDown", onKeyDownCloseButton)
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

local function resetWindowSize()
  R.window:ClearAllPoints()
  R.window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  R.window:SetWidth(700)
  R.window:SetHeight(569)
end

function M:Close()
  if R.window then
    PlaySound("gsTitleOptionExit")
    R.window.frame:Hide()
  end
end

function M:Open()
  if A.DEBUG >= 1 then A.console:Debugf(M, "open") end
  if R.window then
    resetWindowSize()
    return
  end
  R.window = AceGUI:Create("Frame")
  R.window:SetTitle(A.NAME.." "..format(L["choose.gui.title"], "/choose"))
  resetWindowSize()
  R.window:SetStatusText("")
  R.window:SetCallback("OnClose", onCloseWindow)
  R.window:SetLayout("Fill")

  addCloseButton()

  local c = AceGUI:Create("ScrollFrame")
  c:SetLayout("Flow")
  R.window:AddChild(c)

  local widget = AceGUI:Create("Label")
  widget:SetImage("Interface\\Addons\\"..A.NAME.."\\media\\cubeIcon1_64.tga")
  widget:SetImageSize(64, 64)
  widget:SetFontObject(GameFontHighlight)
  widget:SetText(format(L["choose.gui.intro"], H("/choose")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  widget = AceGUI:Create("Heading")
  widget:SetText(format(L["choose.gui.header.buttons"], H("/choose")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  addModeButton(c, "any")
  addModeButton(c, "tank")
  addModeButton(c, "healer")
  addModeButton(c, "damager")
  addModeButton(c, "melee")
  addModeButton(c, "ranged")
  addModeButton(c, "notMe")
  addModeButton(c, "guildmate")
  addModeButton(c, "dead")
  addModeButton(c, "alive")
  addPadding(c)
  for i, class in ipairs(CLASS_SORT_ORDER) do
    addModeButton(c, strlower(class), "class")
  end
  addPadding(c)
  addModeButton(c, "conqueror", "tierToken")
  addModeButton(c, "protector", "tierToken")
  addModeButton(c, "vanquisher", "tierToken")
  addPadding(c)
  addModeButton(c, "intellect", "primaryStat")
  addModeButton(c, "agility", "primaryStat")
  addModeButton(c, "strength", "primaryStat")
  addPadding(c)
  addModeButton(c, "cloth", "armor")
  addModeButton(c, "leather", "armor")
  addModeButton(c, "mail", "armor")
  addModeButton(c, "plate", "armor")
  addPadding(c)
  addModeButton(c, "g1", "fromGroup")
  addModeButton(c, "g2", "fromGroup")
  addModeButton(c, "g3", "fromGroup")
  addModeButton(c, "g4", "fromGroup")
  addModeButton(c, "g5", "fromGroup")
  addModeButton(c, "g6", "fromGroup")
  addModeButton(c, "g7", "fromGroup")
  addModeButton(c, "g8", "fromGroup")
  addModeButton(c, "sitting")
  addModeButton(c, "anyIncludingSitting")
  addModeButton(c, "group")
  addPadding(c)
  addModeButton(c, "option2", "option")
  addModeButton(c, "option3+", "option")
  addModeButton(c, "last")
  addPadding(c)

  widget = AceGUI:Create("Heading")
  widget:SetText(format(L["choose.gui.header.examples"], "/choose"))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  addPadding(c)

  if not R.mockSession then
    R.mockSession = {}
    A.chooseCommand:Mockup(function(line) tinsert(R.mockSession, line) end)
    R.mockSession = tconcat(R.mockSession, "|n")
  end
  widget = AceGUI:Create("Label")
  widget:SetFontObject(GameFontHighlight)
  widget:SetText(R.mockSession)
  widget:SetFullWidth(true)
  c:AddChild(widget)
end

function M:SetupTooltip(widget, mode, modeType)
  R.window:SetStatusText(H(getCommand(mode, modeType)))
  local t = GameTooltip
  t:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
  t:ClearLines()
  -- Title, split into two lines if too long.
  local title = A.chooseCommand:GetChoosingDesc(mode, modeType, true)
  if modeType == "tierToken" or modeType == "armor" or modeType == "primaryStat" then
    title = gsub(title, " %(", "|n(")
  end
  t:AddLine(title)
  if modeType == "class" then
    t:AddLine(" ")
    local example = format("/choose %s/%s", A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["MAGE"]), A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["DRUID"]))
    t:AddLine(format(L["choose.gui.note.multipleClasses"], H(example)), 1,1,1, true)
  end
  t:AddLine(" ")
  if modeType == "option" then
    t:AddLine(format(L["choose.gui.note.option.1"], H("/choose")), 1,1,1, true)
    t:AddLine(" ")
    t:AddLine(L["choose.gui.note.option.2"], 1,1,1, true)
  else
    -- Aliases.
    t:AddDoubleLine(A.chooseCommand.MODE_ALIAS[mode].left, A.chooseCommand.MODE_ALIAS[mode].right, 1,1,1, 1,1,1)
  end
  t:Show()
end
