local A, L = unpack(select(2, ...))
local M = A:NewModule("dataText", "AceTimer-3.0")
A.dataText = M

local DELAY_REFRESH = 0.01
local NOT_IN_RAID = "|cff999999"..L["dataText.raidComp.notInRaid"].."|r"
local DT
local H

local format, tostring = string.format, tostring

-- TODO: localization
-- TODO: include role icons in the tooltip
-- TODO: add options.dataTextShort, hidden if ElvUI not running

local function raidComp_OnEvent(self, event, ...)
  if A.debug >= 1 then A.console:Debugf(M, "DT_OnEvent event=%s", event) end
  -- We need a short delay to ensure that the raid module has a chance to
  -- process the event as well, otherwise A.raid:GetComp() may be wrong.
  local frame = self
  if A.options.dataTextShort then
    M:ScheduleTimer(function ()
      frame.text:SetFormattedText(A.raid:GetComp() or NOT_IN_RAID)
    end, DELAY_REFRESH)
  else
    M:ScheduleTimer(function ()
      local c = A.raid:GetComp()
      frame.text:SetFormattedText(c and ("Raid: "..H(c)) or NOT_IN_RAID)
    end, DELAY_REFRESH)
  end
end

local function raidComp_Click(self, button)
  if A.debug >= 1 then A.console:Debugf(M, "DT_Click button=%s", button) end
  A.gui:OpenRaidTab()
end

local function raidComp_OnEnter(self)
  if A.debug >= 1 then A.console:Debug(M, "DT_OnEnter") end
  DT:SetupTooltip(self)
  local t, m, u, r, h = A.raid:GetRoleCounts()
  local s = A.raid:NumSitting()
  if A.raid:GetSize() > 0 then
    DT.tooltip:AddDoubleLine(L["dataText.raidComp.name"]..":", A.raid:GetComp(), 1,1,0, 1,1,0)
  else
    DT.tooltip:AddLine(L["dataText.raidComp.name"]..":")
  end
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddDoubleLine("Tanks",     tostring(t), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("Healers",   tostring(h), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("DPS",       tostring(m+u+r), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("  Melee",   tostring(m), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("  Ranged",  tostring(r), 1,1,1, 1,1,0)
  if u > 0 then
    DT.tooltip:AddDoubleLine("  Unknown", tostring(r), 1,1,1, 1,1,0)
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddLine(format("Still need to inspect %s.", A.raid:GetUnknownNames()))
  end
  if s > 0 then
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddDoubleLine("Sitting", tostring(s), 1,1,1, 1,1,0)
  end
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddLine("Left click: open raid tab")
  DT.tooltip:Show()
end

function M:OnEnable()
  H = A.util.Highlight
  if not IsAddOnLoaded("ElvUI") or not ElvUI then
    return
  end
  DT = ElvUI[1]:GetModule("DataTexts")
  if not DT then
    return
  end
  DT:RegisterDatatext(L["dataText.raidComp.name"], A.raid.REBUILD_EVENTS, raidComp_OnEvent, nil, raidComp_Click, raidComp_OnEnter)
end
