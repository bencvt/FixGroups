--- Define a GUI for the /fg (/fixgroups) console command.
local A, L = unpack(select(2, ...))
local M = A:NewModule("fgGui")
A.fgGui = M
M.private = {
  window = false,
  label = false,
  closeButton = {},
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

local ceil, format, ipairs, min, type = ceil, format, ipairs, min, type
local GameFontHighlight, GameTooltip, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent = GameFontHighlight, GameTooltip, IsControlKeyDown, IsShiftKeyDown, PlaySound, UIParent

local AceGUI = LibStub("AceGUI-3.0")

local CUBE_ICON_0 = "Interface\\Addons\\"..A.NAME.."\\media\\cubeIcon0_64.tga"
local CUBE_ICON_1 = "Interface\\Addons\\"..A.NAME.."\\media\\cubeIcon1_64.tga"
local CUBE_ICON_BW = "Interface\\Addons\\"..A.NAME.."\\media\\cubeIconBW_64.tga"

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

local function getCommand(cmd)
  return "/fg "..cmd
end

local function addButton(frame, cmd, forceClose, aliases)
  local button = AceGUI:Create("Button")
  button:SetText(cmd)
  button:SetCallback("OnClick", function(widget)
    if IsShiftKeyDown() then
      A.utilGui:InsertText(getCommand(cmd))
      return
    end
    A.fgCommand:Command(cmd)
    if IsControlKeyDown() or forceClose then
      R.window:Hide()
    end
  end)
  if not aliases then
    local sortMode = A.sortModes:GetMode(cmd)
    if sortMode then
      aliases = sortMode.aliases
    end
  end
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
  R.label = false
  AceGUI:Release(widget)
end

local function resetWindowSize()
  R.window:ClearAllPoints()
  R.window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  R.window:SetWidth(540)
  R.window:SetHeight(A.options.showExtraSortModes and 430 or 380)
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

  R.label = AceGUI:Create("Label")
  M:Refresh()
  R.label:SetImageSize(64, 64)
  R.label:SetFontObject(GameFontHighlight)
  R.label:SetText(format(L["gui.fixGroups.intro"], H("/fg"), H("/fixgroups")))
  R.label:SetFullWidth(true)
  c:AddChild(R.label)

  local header = AceGUI:Create("Heading")
  header:SetText(format(L["gui.header.buttons"], H("/fg")))
  header:SetFullWidth(true)
  c:AddChild(header)

  addButton(c, "sort")
  addButton(c, "split")
  addButton(c, "cancel")
  addPadding(c)
  addIndent(c)
  addButton(c, "clear1")
  addButton(c, "clear2")
  addButton(c, "skip1")
  addButton(c, "skip2")
  addPadding(c)
  addIndent(c)
  addButton(c, "tmrh")
  addButton(c, "thmr")
  addButton(c, "meter")
  addButton(c, "nosort")
  addPadding(c)
  addIndent(c)
  addButton(c, "core")
  addPadding(c)
  if A.options.showExtraSortModes then
    addIndent(c)
    addButton(c, "alpha")
    addButton(c, "ralpha")
    addButton(c, "class")
    addButton(c, "random")
    addPadding(c)
  end
  addButton(c, "config", true, {"options"})
  addButton(c, "choose", true)
  addButton(c, "list", true)
  addButton(c, "listself", true)
end

local function addTooltipLines(t, cmd)
  if cmd == "config" then
    t:AddLine(format(L["gui.fixGroups.help.config"], A.util:GetBindingKey("TOGGLEGAMEMENU", "ESCAPE"), A.NAME), 1,1,0, false)
  elseif cmd == "choose" or cmd == "list" or cmd == "listself" or cmd == "cancel" then
    t:AddLine(L["gui.fixGroups.help."..cmd], 1,1,0, true)
  else
    local sortMode = A.sortModes:GetMode(cmd)
    if sortMode.desc then
      if type(sortMode.desc) == "function" then
        sortMode.desc(t)
      else
        t:AddLine(sortMode.desc, 1,1,0, true)
      end
    end
  end
end

function M:SetupTooltip(widget, cmd, aliases)
  R.window:SetStatusText(H(getCommand(cmd)))
  local t = GameTooltip
  t:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
  t:ClearLines()
  addTooltipLines(t, cmd)

  -- List aliases, if any.
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

function M:Refresh()
  if R.label then
    if A.sorter:IsPaused() then
      R.label:SetImage(CUBE_ICON_BW)
    elseif A.sorter:IsProcessing() and time() % 2 == 0 then
      R.label:SetImage(CUBE_ICON_0)
    else
      R.label:SetImage(CUBE_ICON_1)
    end
  end
end
