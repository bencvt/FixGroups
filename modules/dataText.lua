local A, L = unpack(select(2, ...))
local M = A:NewModule("dataText", "AceTimer-3.0")
A.dataText = M

local DELAY_REFRESH = 0.01
local NOT_IN_RAID = "|cff999999"..L["dataText.raidComp.notInRaid"].."|r"
local DT
local H

local format, tostring = string.format, tostring

-- TODO: localization
-- TODO: add another dataTextRaidCompStyle or two, including role icons in the datatext
-- TODO: add an option to include BattlenetWorking0 icon if queued in LFG tool, in datatext. Use leader/assist/member icon if not queued? Also show in tooltip. Will need to listen to more events.
-- TODO: add options.dataTextShort, hidden if ElvUI not running. Actually make it options.dataTextStyle, several options.
-- TODO: research DataBroker stuff, see if any of this can be made ElvUI-independent
-- TODO: figure out why so many ?s are showing up in testing. Is there is a "player data ready" event?

local function raidComp_OnEvent(self, event, ...)
  if A.debug >= 1 then A.console:Debugf(M, "DT_OnEvent event=%s comp=%s unknown=%s", event, A.raid:GetComp(), A.raid:GetUnknownNames()) end
  -- We need a short delay to ensure that the raid module has a chance to
  -- process the event as well, otherwise A.raid:GetComp() may be wrong.
  local frame = self
  M:ScheduleTimer(function ()
    if A.options.dataTextRaidCompStyle == 2 then
      frame.text:SetFormattedText(A.raid:GetComp() or NOT_IN_RAID)
    else
      local c1, c2 = A.raid:GetCompParts()
      frame.text:SetFormattedText(c1 and format("Raid: |cff1784d1%s |cff105c92%s|r", c1, c2) or NOT_IN_RAID)
    end
  end, DELAY_REFRESH)
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
  DT.tooltip:AddDoubleLine(L["dataText.raidComp.name"]..":", (A.raid:GetSize() > 0) and A.raid:GetComp() or NOT_IN_RAID, 1,1,0, 1,1,0)
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddDoubleLine(A.util.TEXT_ROLE_ICON["TANK"].." Tanks",     tostring(t), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine(A.util.TEXT_ROLE_ICON["HEALER"].." Healers", tostring(h), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine(A.util.TEXT_ROLE_ICON["DAMAGER"].." DPS",    tostring(m+u+r), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("        Melee",   tostring(m), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("        Ranged",  tostring(r), 1,1,1, 1,1,0)
  if u > 0 then
    DT.tooltip:AddDoubleLine("        Unknown", tostring(r), 1,1,1, 1,1,0)
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddLine(format("Still need to inspect %s.", A.raid:GetUnknownNames()))
  end
  if s > 0 then
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddDoubleLine("Sitting", tostring(s), 1,1,1, 1,1,0)
  end
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddDoubleLine("Left Click:", "Open Raid Tab", 1,1,1, 1,1,0)
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
  local name = L["dataText.raidComp.name"]
  if DT.RegisteredDataTexts[name] then
    -- Some other addon or plugin has already registered the name. Disambiguate.
    name = format("%s (%s)", name, A.name)
  end
  -- Ideally we'd be triggering on the FIXGROUPS_RAID_COMP_CHANGED message,
  -- but DataTexts only trigger on Blizzard events. So we listen for all events
  -- that could possibly result in a FIXGROUPS_RAID_COMP_CHANGED message.
  local events = {"INSPECT_READY", "GROUP_ROSTER_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA"}
  DT:RegisterDatatext(name, events, raidComp_OnEvent, nil, raidComp_Click, raidComp_OnEnter)
end
