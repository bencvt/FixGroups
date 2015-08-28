local A, L = unpack(select(2, ...))
local M = A:NewModule("dataBroker", "AceEvent-3.0")
A.dataBroker = M
M.private = {
  groupComp = false,
}
local R = M.private
local H, HA, HD = A.util.Highlight, A.util.HighlightAddon, A.util.HighlightDim

local NOT_IN_GROUP = HD(L["dataBroker.groupComp.notInGroup"])
local ICON_TANK, ICON_HEALER, ICON_DAMAGER = A.util.TEXT_ICON.ROLE.TANK, A.util.TEXT_ICON.ROLE.HEALER, A.util.TEXT_ICON.ROLE.DAMAGER

local format, tostring = format, tostring
local IsAddOnLoaded, IsInGroup, IsInRaid, IsShiftKeyDown = IsAddOnLoaded, IsInGroup, IsInRaid, IsShiftKeyDown
-- GLOBALS: C_LFGList, LibStub

local function groupCompOnClick(frame, button)
  if A.DEBUG >= 2 then A.console:Debugf(M, "groupCompOnClick frame=%s button=%s", tostring(frame or "<nil>"), tostring(button or "<nil>")) end
  if IsShiftKeyDown() then
    A.util:InsertText(A.group:GetComp(5))
  else
    A.util:ToggleRaidTab()
  end
end

local function groupCompOnTooltipShow(tooltip)
  if A.DEBUG >= 1 then A.console:Debugf(M, "groupCompOnTooltipShow tooltip=%s", tostring(tooltip or "<nil>")) end
  if IsInGroup() then
    local t, h, m, r, u = A.group:GetRoleCountsTHMRU()
    tooltip:AddDoubleLine(format("%s (%s):", L["dataBroker.groupComp.name"], (IsInRaid() and L["word.raid"] or L["word.party"])), A.util:FormatGroupComp(6, t, h, m, r, u), 1,1,0, 1,1,0)
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.TANK.." "..L["word.tank.plural"],       tostring(t), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.HEALER.." "..L["word.healer.plural"],   tostring(h), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.DAMAGER.." "..L["word.damager.plural"], tostring(m+r+u), 1,1,1, 1,1,0)
    local indent = "        "
    tooltip:AddDoubleLine(indent..L["word.melee.plural"],   HD(tostring(m)), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine(indent..L["word.ranged.plural"],  HD(tostring(r)), 1,1,1, 1,1,0)
    if u > 0 then
      tooltip:AddDoubleLine(indent..L["word.unknown.plural"], HD(tostring(u)), 1,1,1, 1,1,0)
      tooltip:AddLine(" ")
      tooltip:AddLine(format(L["phrase.waitingOnDataFromServerFor"], ((u > 1) and "|n" or "")..A.group:GetUnknownNames()))
    end
    local sitting = A.group:NumSitting()
    if sitting > 0 then
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine(format(L["dataBroker.groupComp.sitting"], A.util:GetMaxGroupsForInstance() + 1), HD(tostring(sitting)), 1,1,1, 1,1,0)
    end
  else
    tooltip:AddDoubleLine(format("%s:", L["dataBroker.groupComp.name"]), NOT_IN_GROUP, 1,1,0, 1,1,0)
  end
  if C_LFGList.GetActiveEntryInfo() then
    tooltip:AddLine(" ")
    tooltip:AddLine(L["dataBroker.groupComp.groupQueued"], 0,1,0)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(format("%s:", L["phrase.mouse.clickLeft"]), L["dataBroker.groupComp.openRaidTab"], 1,1,1, 1,1,0)
  tooltip:Show()
end

function M:OnEnable()
  -- See also: the buttonGui module, which defines another LDB DataObject for the
  -- minimap icon (type="launcher").
  local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
  R.groupComp = {
    type = "data source",
    text = NOT_IN_GROUP,
    label = L["dataBroker.groupComp.name"],
    OnClick = groupCompOnClick,
    OnTooltipShow = groupCompOnTooltipShow,
  }
  if not LDB:NewDataObject(R.groupComp.label, R.groupComp) then
    -- Some other addon has already registered the name. Disambiguate.
    LDB:NewDataObject(format("%s (%s)", R.groupComp.label, A.NAME), R.groupComp)
  end
  M:RegisterMessage("FIXGROUPS_COMP_CHANGED")
  M:RefreshGroupComp()
end

function M:FIXGROUPS_COMP_CHANGED(message)
  M:RefreshGroupComp()
end

function M:RefreshGroupComp()
  if IsInGroup() and A.group:GetSize() > 0 then
    R.groupComp.text = A.group:GetComp(A.options.dataBrokerGroupCompStyle)
  else
    R.groupComp.text = NOT_IN_GROUP
  end
end
