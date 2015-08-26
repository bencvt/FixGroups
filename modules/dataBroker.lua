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
local IsAddOnLoaded = IsAddOnLoaded
-- GLOBALS: C_LFGList, LibStub

-- TODO: localization

local function groupCompOnClick(frame, button)
  if A.DEBUG >= 2 then A.console:Debugf(M, "groupComp_Click frame=%s button=%s", tostring(frame or "<nil>"), tostring(button or "<nil>")) end
  A.gui:OpenRaidTab()
end

local function groupCompOnTooltipShow(tooltip)
  if A.DEBUG >= 1 then A.console:Debugf(M, "groupComp_OnTooltipShow tooltip=%s", tostring(tooltip or "<nil>")) end
  local t, h, m, r, u = A.group:GetRoleCountsTHMRU()
  if IsInGroup() then
    tooltip:AddDoubleLine(format("%s (%s):"L["dataBroker.groupComp.name"], (IsInRaid() and L["word.raid"] or L["word.party"])), A.group:GetComp(), 1,1,0, 1,1,0)
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.TANK.." Tanks",        tostring(t), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.HEALER.." Healers",    tostring(h), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.DAMAGER.." Damagers",  tostring(m+r+u), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine("        Melee",   HD(tostring(m)), 1,1,1, 1,1,0)
    tooltip:AddDoubleLine("        Ranged",  HD(tostring(r)), 1,1,1, 1,1,0)
    if u > 0 then
      tooltip:AddDoubleLine("        Unknown", HD(tostring(u)), 1,1,1, 1,1,0)
      tooltip:AddLine(" ")
      tooltip:AddLine(format("Waiting on data from the server for %s.", ((u > 1) and "|n" or "")..A.group:GetUnknownNames()))
    end
    local sitting = A.group:NumSitting()
    if sitting > 0 then
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine(format("Sitting in groups %d-8", A.util:GetMaxGroupsForInstance() + 1), HD(tostring(sitting)), 1,1,1, 1,1,0)
    end
  else
    tooltip:AddDoubleLine(format("%s:", L["dataBroker.groupComp.name"]), NOT_IN_GROUP, 1,1,0, 1,1,0)
  end
  if C_LFGList.GetActiveEntryInfo() then
    tooltip:AddLine(" ")
    tooltip:AddLine("Your group is queued in LFG.", 0,1,0)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine("Left Click:", "Open Raid Tab", 1,1,1, 1,1,0)
  tooltip:Show()
end

function M:OnEnable()
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
end

function M:FIXGROUPS_COMP_CHANGED(message)
  M:RefreshGroupComp()
end

function M:RefreshGroupComp()
  local compTHD, compMRU = A.group:GetComp()
  local t, h, m, r, u = A.group:GetRoleCountsTHMRU()
  R.groupComp.text = A.util:FormatGroupComp(A.options.dataBrokerGroupCompStyle, compTHD, compMRU, t, h, m, r, u)
end
