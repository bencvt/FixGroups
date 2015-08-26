local A, L = unpack(select(2, ...))
local M = A:NewModule("dataBroker", "AceEvent-3.0")
A.dataBroker = M
M.private = {
}
local R = M.private
local H, HA, HD = A.util.Highlight, A.util.HighlightAddon, A.util.HighlightDim

local NOT_IN_RAID = HD(L["dataBroker.raidComp.notInRaid"])
local ICON_TANK, ICON_HEALER, ICON_DAMAGER = A.util.TEXT_ICON.ROLE.TANK, A.util.TEXT_ICON.ROLE.HEALER, A.util.TEXT_ICON.ROLE.DAMAGER

local format, tostring = format, tostring
local IsAddOnLoaded = IsAddOnLoaded
-- GLOBALS: C_LFGList, LibStub

-- TODO: localization

local function raidCompOnClick(frame, button)
  if A.DEBUG >= 2 then A.console:Debugf(M, "raidComp_Click frame=%s button=%s", tostring(frame or "<nil>"), tostring(button or "<nil>")) end
  A.gui:OpenRaidTab()
end

local function raidCompOnTooltipShow(tooltip)
  if A.DEBUG >= 1 then A.console:Debugf(M, "raidComp_OnTooltipShow tooltip=%s", tostring(tooltip or "<nil>")) end
  local t, h, m, r, u = A.raid:GetRoleCounts()
  tooltip:AddDoubleLine(L["dataBroker.raidComp.name"]..":", (A.raid:GetSize() > 0) and A.raid:GetComp() or NOT_IN_RAID, 1,1,0, 1,1,0)
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.TANK.." Tanks",        tostring(t), 1,1,1, 1,1,0)
  tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.HEALER.." Healers",    tostring(h), 1,1,1, 1,1,0)
  tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.DAMAGER.." Damagers",  tostring(m+r+u), 1,1,1, 1,1,0)
  tooltip:AddDoubleLine("        Melee",   HD(tostring(m)), 1,1,1, 1,1,0)
  tooltip:AddDoubleLine("        Ranged",  HD(tostring(r)), 1,1,1, 1,1,0)
  if u > 0 then
    tooltip:AddDoubleLine("        Unknown", HD(tostring(u)), 1,1,1, 1,1,0)
    tooltip:AddLine(" ")
    tooltip:AddLine(format("Waiting on data from the server for %s.", ((u > 1) and "|n" or "")..A.raid:GetUnknownNames()))
  end
  local sitting = A.raid:NumSitting()
  if sitting > 0 then
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(format("Sitting in groups %d-8", A.util:GetMaxGroupsForInstance() + 1), HD(tostring(sitting)), 1,1,1, 1,1,0)
  end
  if C_LFGList.GetActiveEntryInfo() then
    tooltip:AddLine(" ")
    tooltip:AddLine("Your raid group is queued in LFG.", 0,1,0)
  end
  tooltip:AddLine(" ")
  tooltip:AddDoubleLine("Left Click:", "Open Raid Tab", 1,1,1, 1,1,0)
  tooltip:Show()
end

function M:OnEnable()
  local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
  R.raidComp = {
    type = "data source",
    text = NOT_IN_RAID,
    label = L["dataBroker.raidComp.name"],
    OnClick = raidCompOnClick,
    OnTooltipShow = raidCompOnTooltipShow,
  }
  if not LDB:NewDataObject(R.raidComp.label, R.raidComp) then
    -- Some other addon has already registered the name. Disambiguate.
    LDB:NewDataObject(format("%s (%s)", R.raidComp.label, A.NAME), R.raidComp)
  end
  M:RegisterMessage("FIXGROUPS_RAID_COMP_CHANGED")
end

function M:FIXGROUPS_RAID_COMP_CHANGED(message)
  M:RefreshRaidComp()
end

function M:RefreshRaidComp()
  local c1, c2 = A.raid:GetCompParts()
  local t, h, m, r, u = A.raid:GetRoleCounts()
  R.raidComp.text = A.util:FormatRaidComp(A.options.dataBrokerRaidCompStyle, c1, c2, t, h, m, r, u)
end
