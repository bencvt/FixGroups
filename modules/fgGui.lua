local A, L = unpack(select(2, ...))
local M = A:NewModule("fgGui")
A.fgGui = M
M.private = {
  window = false,
  closeButton = {},
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

local AceGUI = LibStub("AceGUI-3.0")

local function addPadding(frame)
  local padding = AceGUI:Create("Label")
  padding:SetText(" ")
  padding:SetFullWidth(true)
  frame:AddChild(padding)
  return padding
end

local function addIndent(frame)
  local indent = AceGUI:Create("Label")
  indent:SetText(" ")
  indent:SetWidth(52)
  frame:AddChild(indent)
  return indent
end

local function onLeaveButton(widget)
  GameTooltip:Hide()
  R.window:SetStatusText("")
end

local function getCommand(cmd, aliases)
  return "/fg "..cmd
end

local function addButton(frame, cmd, aliases, forceClose)
  local button = AceGUI:Create("Button")
  button:SetText(cmd)
  button:SetCallback("OnClick", function(widget)
    if IsShiftKeyDown() then
      A.utilGui:InsertText(getCommand(cmd, aliases))
      return
    end
    A.fgCommand:Command(cmd)
    if IsControlKeyDown() or forceClose then
      R.window:Hide()
    end
  end)
  button:SetCallback("OnEnter", function(widget)
    M:SetupTooltip(widget, cmd, aliases)
  end)
  button:SetCallback("OnLeave", onLeaveButton)
  button:SetWidth(104)
  frame:AddChild(button)
  return button
end

local function onCloseWindow(widget)
  R.window = false
  AceGUI:Release(widget)
end

local function resetWindowSize()
  R.window:ClearAllPoints()
  R.window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  R.window:SetWidth(540)
  R.window:SetHeight(380)
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
  R.window:SetTitle(A.NAME.." "..format(L["gui.title"], "/fg"))
  resetWindowSize()
  R.window:SetStatusText("")
  R.window:SetCallback("OnClose", onCloseWindow)
  R.window:SetLayout("Fill")

  A.utilGui:AddCloseButton(R.window, R.closeButton, M.Close)

  local c = AceGUI:Create("ScrollFrame")
  c:SetLayout("Flow")
  R.window:AddChild(c)

  local widget = AceGUI:Create("Label")
  widget:SetImage("Interface\\Addons\\"..A.NAME.."\\media\\cubeIcon1_64.tga")
  widget:SetImageSize(64, 64)
  widget:SetFontObject(GameFontHighlight)
  widget:SetText(format(L["gui.fixGroups.intro"], H("/fg"), H("/fixgroups")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  widget = AceGUI:Create("Heading")
  widget:SetText(format(L["gui.header.buttons"], H("/fg")))
  widget:SetFullWidth(true)
  c:AddChild(widget)

  addButton(c, "sort", {"default"})
  addButton(c, "split")
  addButton(c, "cancel")
  addPadding(c)
  addIndent(c)
  addButton(c, "clear1", {"c1"})
  addButton(c, "clear2", {"c0"})
  addButton(c, "skip1", {"s1"})
  addButton(c, "skip2", {"s2"})
  addPadding(c)
  addIndent(c)
  addButton(c, "thmr")
  addButton(c, "tmrh")
  addButton(c, "meter", {"dps"})
  addButton(c, "nosort")
  addPadding(c)
  addButton(c, "config", {"options"}, true)
  addPadding(c)
  addIndent(c)
  addButton(c, "choose", nil, true)
  addButton(c, "list", nil, true)
  addButton(c, "listself", nil, true)
end

local function addHelpLines(t, cmd, noSameAs)
  -- First line.
  if not noSameAs then
    if cmd == "sort" then
      t:AddLine(format(L["gui.fixGroups.help.note.sameAsLeftClicking"], H(L["button.fixGroups.text"])), 1,1,1, true)
      t:AddLine(" ")
    elseif cmd == "choose" or cmd == "list" or cmd == "listself" then
      t:AddLine(format(L["gui.fixGroups.help.note.sameAsCommand"], H("/"..cmd)), 1,1,1, false)
      t:AddLine(" ")
    end
  end
  -- Main line.
  if cmd == "config" then
    t:AddLine(format(L["gui.fixGroups.help."..cmd], A.NAME), 1,1,1, false)
  elseif cmd == "thmr" or cmd == "tmrh" or cmd == "meter" then
    t:AddLine(format(L["gui.fixGroups.help.mode"], L["sorter.mode."..cmd]), 1,1,1, false)
  else
    t:AddLine(L["gui.fixGroups.help."..cmd], 1,1,1, true)
  end
  -- Extra lines.
  if cmd == "sort" then
    t:AddLine(" ")
    t:AddLine(format(L["gui.fixGroups.help.note.defaultMode"], H(L["sorter.mode."..A.options.sortMode])), 1,1,1, true)
  elseif cmd == "split" or cmd == "meter" then
    t:AddLine(" ")
    t:AddLine(format(L["gui.fixGroups.help.note.meter.1"], A.meter:GetSupportedAddonList()), 1,1,1, true)
    t:AddLine(" ")
    t:AddLine(A.meter:TestInterop(), 1,1,1, true)
    if cmd == "meter" then
      t:AddLine(" ")
      t:AddLine(L["gui.fixGroups.help.note.meter.2"], 1,1,1, true)
    end
  elseif cmd == "clear1" or cmd == "clear2" or cmd == "skip1" or cmd == "skip2" then
    t:AddLine(" ")
    addHelpLines(t, "sort", true)
    t:AddLine(" ")
    t:AddLine(L["gui.fixGroups.help.note.clearSkip"], 1,1,1, true)
  end
end

function M:SetupTooltip(widget, cmd, aliases)
  R.window:SetStatusText(H(getCommand(cmd, aliases)))
  local t = GameTooltip
  t:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
  t:ClearLines()
  addHelpLines(t, cmd)
  if aliases and #aliases > 0 then
    local left, right
    if #aliases == 1 then
      left = L["word.alias.singular"]..":"
    else
      left = L["word.alias.plural"]..":"
    end
    for _, a in ipairs(aliases) do
      right = (right and (right..", ") or "")..H(a)
    end
    t:AddLine(" ")
    t:AddDoubleLine(left, right, 1,1,1, 1,1,1)
  end
  t:Show()
end