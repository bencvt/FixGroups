local A, L = unpack(select(2, ...))
local M = A:NewModule("dataText", "AceTimer-3.0")
A.dataText = M
local H, HA, HD = A.util.Highlight, A.util.HighlightAddon, A.util.HighlightDim

local DELAY_REFRESH = 0.01
local NOT_IN_RAID = HD(L["dataText.raidComp.notInRaid"])
local ICON_TANK, ICON_HEALER, ICON_DAMAGER = A.util.TEXT_ICON.ROLE.TANK, A.util.TEXT_ICON.ROLE.HEALER, A.util.TEXT_ICON.ROLE.DAMAGER
local DT

local format, tostring = format, tostring
local IsAddOnLoaded = IsAddOnLoaded
-- GLOBALS: ElvUI, C_LFGList

-- TODO: localization
-- TODO: research DataBroker stuff, see if any of this can be made ElvUI-independent

local function raidComp_OnEvent(self, event, ...)
  if A.DEBUG >= 1 then A.console:Debugf(M, "DT_OnEvent event=%s comp=%s unknown=%s", event, A.raid:GetComp(), A.raid:GetUnknownNames()) end
  -- We need a short delay to ensure that the raid module has a chance to
  -- process the event as well, otherwise A.raid:GetComp() may be wrong.
  local frame, style = self, A.options.dataTextRaidCompStyle
  M:ScheduleTimer(function ()
    local c1, c2 = A.raid:GetCompParts()
    local txt
    if not c1 then
      txt = NOT_IN_RAID
    elseif style == 2 then
      local t, m, u, r, h = A.raid:GetRoleCounts()
      txt = format("%d%s %d%s %d%s", t, ICON_TANK, h, ICON_HEALER, m+u+r, ICON_DAMAGER)
    elseif style == 3 then
      txt = format("Raid: %s", H(A.raid:GetComp()))
    elseif style == 4 then
      txt = format("Raid: %s", H(c1))
    elseif style == 5 then
      txt = A.raid:GetComp()
    elseif style == 6 then
      txt = format("2%s 4%s 14%s%s", A.util.TEXT_ICON.ROLE.TANK, A.util.TEXT_ICON.ROLE.HEALER, A.util.TEXT_ICON.ROLE.DAMAGER, HD("(6+8)"))
    else
      local t, m, u, r, h = A.raid:GetRoleCounts()
      txt = format("%d%s %d%s %d%s%s", t, ICON_TANK, h, ICON_HEALER, m+u+r, ICON_DAMAGER, HD(c2))
    end
    frame.text:SetFormattedText(txt)
  end, DELAY_REFRESH)
end

local function raidComp_Click(self, button)
  if A.DEBUG >= 1 then A.console:Debugf(M, "DT_Click button=%s", button) end
  A.gui:OpenRaidTab()
end

local function raidComp_OnEnter(self)
  if A.DEBUG >= 1 then A.console:Debug(M, "DT_OnEnter") end
  DT:SetupTooltip(self)
  local t, m, u, r, h = A.raid:GetRoleCounts()
  DT.tooltip:AddDoubleLine(L["dataText.raidComp.name"]..":", (A.raid:GetSize() > 0) and A.raid:GetComp() or NOT_IN_RAID, 1,1,0, 1,1,0)
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.TANK.." Tanks",        tostring(t), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.HEALER.." Healers",    tostring(h), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine(A.util.TEXT_ICON.ROLE.DAMAGER.." Damagers",  tostring(m+u+r), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("        Melee",   HD(tostring(m)), 1,1,1, 1,1,0)
  DT.tooltip:AddDoubleLine("        Ranged",  HD(tostring(r)), 1,1,1, 1,1,0)
  if u > 0 then
    DT.tooltip:AddDoubleLine("        Unknown", HD(tostring(u)), 1,1,1, 1,1,0)
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddLine(format("Waiting on data from the server for %s.", ((u > 1) and "|n" or "")..A.raid:GetUnknownNames()))
  end
  local sitting = A.raid:NumSitting()
  if sitting > 0 then
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddDoubleLine(format("Sitting in groups %d-8", A.util:GetMaxGroupsForInstance() + 1), HD(tostring(sitting)), 1,1,1, 1,1,0)
  end
  if C_LFGList.GetActiveEntryInfo() then
    DT.tooltip:AddLine(" ")
    DT.tooltip:AddLine("Your raid group is queued in LFG.", 0,1,0)
  end
  DT.tooltip:AddLine(" ")
  DT.tooltip:AddDoubleLine("Left Click:", "Open Raid Tab", 1,1,1, 1,1,0)
  DT.tooltip:Show()
end

function M:OnEnable()
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
    name = format("%s (%s)", name, A.NAME)
  end
  -- Ideally we'd be triggering on the FIXGROUPS_RAID_COMP_CHANGED message,
  -- but DataTexts only trigger on Blizzard events. So we listen for all events
  -- that could possibly result in a FIXGROUPS_RAID_COMP_CHANGED message.
  local events = {"INSPECT_READY", "GROUP_ROSTER_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA"}
  DT:RegisterDatatext(name, events, raidComp_OnEvent, nil, raidComp_Click, raidComp_OnEnter)
end
