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
local GameFontHighlight, GameTooltip, GetBindingFromClick, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent = GameFontHighlight, GameTooltip, GetBindingFromClick, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent
local CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_MALE = CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_MALE

local AceGUI = LibStub("AceGUI-3.0")

local function onLeaveButton(widget)
  GameTooltip:Hide()
  R.window:SetStatusText("")
end

local function getCommand(cmd, mode, modeType)
  return format("/%s %s", cmd, mode)
end

local function addModeButton(frame, cmd, mode, modeType)
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
      A.utilGui:InsertText(getCommand(cmd, mode, modeType))
      return
    end
    A.chooseCommand:Command(cmd, mode)
    if IsControlKeyDown() then
      R.window:Hide()
    end
  end)
  button:SetCallback("OnEnter", function(widget)
    M:SetupTooltip(widget, cmd, mode, modeType)
  end)
  button:SetCallback("OnLeave", onLeaveButton)
  button:SetWidth(104)
  frame:AddChild(button)
  return button
end

local function addPadding(frame)
  local padding = AceGUI:Create("Label")
  padding:SetText(" ")
  padding:SetFullWidth(true)
  frame:AddChild(padding)
  return padding
end

local function onCloseWindow(widget)
  R.window = false
  AceGUI:Release(widget)
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

function M:Open(cmd)
  if A.DEBUG >= 1 then A.console:Debugf(M, "open") end
  if R.window then
    resetWindowSize()
    return
  end
  R.window = AceGUI:Create("Frame")
  R.window:SetTitle(A.NAME.." "..format(L["gui.title"], "/"..cmd))
  resetWindowSize()
  R.window:SetStatusText("")
  R.window:SetCallback("OnClose", onCloseWindow)
  R.window:SetLayout("Fill")

  A.utilGui:AddCloseButton(R.window, R.closeButton, M.Close)

  local c = AceGUI:Create("ScrollFrame")
  c:SetLayout("Flow")
  R.window:AddChild(c)

  local widget = AceGUI:Create("Label")
  if cmd == "choose" then
    widget:SetImage("Interface\\BUTTONS\\UI-GroupLoot-Dice-Up")
    widget:SetText(format(L["gui.choose.intro"], H("/"..cmd)))
  elseif cmd == "list" then
    widget:SetImage("Interface\\BUTTONS\\UI-GuildButton-MOTD-Up")
    widget:SetText(L["gui.fixGroups.help.list"].." "..format(L["gui.list.intro"], H("/"..cmd), H("/choose")))
  elseif cmd == "listself" then
    widget:SetImage("Interface\\BUTTONS\\UI-GuildButton-MOTD-Disabled")
    widget:SetText(L["gui.fixGroups.help.listself"].." "..format(L["gui.list.intro"], H("/"..cmd), H("/choose")))
  else
    A.console:Errorf(M, "invalid cmd %s!", tostring(cmd))
    return
  end
  widget:SetImageSize(64, 64)
  widget:SetFontObject(GameFontHighlight)
  widget:SetFullWidth(true)
  c:AddChild(widget)

  widget = AceGUI:Create("Heading")
  widget:SetText(format(L["gui.header.buttons"], H("/"..cmd)))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  addModeButton(c, cmd, "any")
  addModeButton(c, cmd, "tank")
  addModeButton(c, cmd, "healer")
  addModeButton(c, cmd, "damager")
  addModeButton(c, cmd, "melee")
  addModeButton(c, cmd, "ranged")
  addModeButton(c, cmd, "notMe")
  addModeButton(c, cmd, "guildmate")
  addModeButton(c, cmd, "dead")
  addModeButton(c, cmd, "alive")
  addPadding(c)
  for i, class in ipairs(CLASS_SORT_ORDER) do
    addModeButton(c, cmd, strlower(class), "class")
  end
  addPadding(c)
  addModeButton(c, cmd, "conqueror", "tierToken")
  addModeButton(c, cmd, "protector", "tierToken")
  addModeButton(c, cmd, "vanquisher", "tierToken")
  addPadding(c)
  addModeButton(c, cmd, "intellect", "primaryStat")
  addModeButton(c, cmd, "agility", "primaryStat")
  addModeButton(c, cmd, "strength", "primaryStat")
  addPadding(c)
  addModeButton(c, cmd, "cloth", "armor")
  addModeButton(c, cmd, "leather", "armor")
  addModeButton(c, cmd, "mail", "armor")
  addModeButton(c, cmd, "plate", "armor")
  addPadding(c)
  addModeButton(c, cmd, "g1", "fromGroup")
  addModeButton(c, cmd, "g2", "fromGroup")
  addModeButton(c, cmd, "g3", "fromGroup")
  addModeButton(c, cmd, "g4", "fromGroup")
  addModeButton(c, cmd, "g5", "fromGroup")
  addModeButton(c, cmd, "g6", "fromGroup")
  addModeButton(c, cmd, "g7", "fromGroup")
  addModeButton(c, cmd, "g8", "fromGroup")
  addModeButton(c, cmd, "sitting")
  addModeButton(c, cmd, "anyIncludingSitting")
  addModeButton(c, cmd, "group")
  addPadding(c)
  addModeButton(c, cmd, "last")

  if cmd == "choose" then
    addModeButton(c, cmd, "option2", "option")
    addModeButton(c, cmd, "option3+", "option")
    addPadding(c)

    widget = AceGUI:Create("Heading")
    widget:SetText(format(L["gui.header.examples"], "/"..cmd))
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
end

function M:SetupTooltip(widget, cmd, mode, modeType)
  R.window:SetStatusText(H(getCommand(cmd, mode, modeType)))
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
    local example = format("/%s %s/%s", cmd, A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["MAGE"]), A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["DRUID"]))
    t:AddLine(format(L["gui.choose.note.multipleClasses"], H(example)), 1,1,1, true)
  end
  t:AddLine(" ")
  if modeType == "option" then
    t:AddLine(format(L["gui.choose.note.option.1"], H("/"..cmd)), 1,1,1, true)
    t:AddLine(" ")
    t:AddLine(L["gui.choose.note.option.2"], 1,1,1, true)
  else
    -- Aliases.
    t:AddDoubleLine(A.chooseCommand.MODE_ALIAS[mode].left, A.chooseCommand.MODE_ALIAS[mode].right, 1,1,1, 1,1,1)
  end
  t:Show()
end
