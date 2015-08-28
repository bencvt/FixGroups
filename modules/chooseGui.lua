local A, L = unpack(select(2, ...))
local M = A:NewModule("chooseGui")
A.chooseGui = M
M.private = {
  window = false,
  mockSession = false,
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

local format, tinsert = format, tinsert
local tconcat = table.concat

local AceGUI = LibStub("AceGUI-3.0")

local function onCloseWindow(widget)
  R.window = false
  AceGUI:Release(widget)
end

local function addPadding(frame)
  local padding = AceGUI:Create("Label")
  padding:SetText(" ")
  padding:SetFullWidth(true)
  frame:AddChild(padding)
  return padding
end

local function onLeaveButton(widget)
  -- TODO hide tooltip
  R.window:SetStatusText("")
end

local function addModeButton(frame, mode, modeType)
  local button = AceGUI:Create("Button")
  button:SetText(mode)
  button:SetCallback("OnEnter", function(widget)
    -- TODO show a tooltip with localized description and list of aliases
    R.window:SetStatusText(H("/choose "..mode))
  end)
  button:SetCallback("OnLeave", onLeaveButton)
  button:SetWidth(104)
  frame:AddChild(button)
  return button
end

local function resetWindowSize()
  R.window:ClearAllPoints()
  R.window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  R.window:SetWidth(700)
  R.window:SetHeight(569)
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

  local c = AceGUI:Create("ScrollFrame")
  c:SetLayout("Flow")
  R.window:AddChild(c)

  local widget = AceGUI:Create("Label")
  widget:SetFontObject(GameFontHighlight)
  widget:SetText(format(L["choose.gui.intro"], H("/choose")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  widget = AceGUI:Create("Heading")
  widget:SetText(format(L["choose.gui.header.buttons"], H("/choose")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  -- TODO localize
  addModeButton(c, "any")
  addModeButton(c, "tank")
  addModeButton(c, "healer")
  addModeButton(c, "damager")
  addModeButton(c, "melee")
  addModeButton(c, "ranged")
  addModeButton(c, "any+sitting")
  addModeButton(c, "sitting")
  addModeButton(c, "dead")
  addModeButton(c, "alive")
  addModeButton(c, "guildmate")
  addModeButton(c, "notMe")
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
  addModeButton(c, "cloth", "armorType")
  addModeButton(c, "leather", "armorType")
  addModeButton(c, "mail", "armorType")
  addModeButton(c, "plate", "armorType")
  addPadding(c)
  addModeButton(c, "g1", "fromGroup")
  addModeButton(c, "g2", "fromGroup")
  addModeButton(c, "g3", "fromGroup")
  addModeButton(c, "g4", "fromGroup")
  addModeButton(c, "g5", "fromGroup")
  addModeButton(c, "g6", "fromGroup")
  addModeButton(c, "g7", "fromGroup")
  addModeButton(c, "g8", "fromGroup")
  addModeButton(c, "group")
  addPadding(c)
  addModeButton(c, "A or B")
  addModeButton(c, "A, B, C, ...")
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
