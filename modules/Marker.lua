local A, L = unpack(select(2, ...))
local M = A:NewModule("Marker")
A.marker = M

local tmp1, tmp2, tmp3 = {}, {}, {}
local min, sort, tinsert, wipe = math.min, sort, table.insert, wipe

function M:FixParty()
  if IsInRaid() then
    return
  end
  local party = wipe(tmp1)
  local unitID, p
  for i = 1, 5 do
    unitID = (i == 5) and "player" or ("party"..i)
    if UnitExists(unitID) then
      p = {unitID=unitID, key=UnitGroupRolesAssigned(unitID)}
      if p.key == "TANK" then
        p.key = "a"
      elseif p.key == "HEALER" then
        p.key = "b"
      else
        p.key = "c"
      end
      p.key = p.key..(UnitName(unitID) or "Unknown")
      tinsert(party, p)
    end
  end
  sort(party, function(a, b) return a.key < b.key end)
  local mark
  local allMarked = true
  for i = 1, min(#party, #A.options.partyMarkIcons) do
    mark = A.options.partyMarkIcons[i]
    if mark > 0 and mark <= 8 and GetRaidTargetIndex(party[i].unitID) ~= mark then
      SetRaidTarget(party[i].unitID, mark)
      allMarked = false
    end
  end
  if allMarked then
    -- Clear marks.
    for i = 1, min(#party, #A.options.partyMarkIcons) do
      SetRaidTarget(party[i].unitID, 0)
    end
  end
end

function M:FixRaid(isRequestFromAssist)
  if not A.util:IsLeaderOrAssist() or not IsInRaid() then
    return
  end

  local marks = wipe(tmp1)
  local unsetTanks = wipe(tmp2)
  local setNonTanks = wipe(tmp3)
  local name, rank, subgroup, rank, online, raidRole, isML, _, unitID, unitRole
  for i = 1, GetNumGroupMembers() do
    name, rank, subgroup, _, _, _, _, online, _, raidRole, isML = GetRaidRosterInfo(i)
    if A.util:IsLeader() and A.options.fixOfflineML and isML and not online then
      SetLootMethod("master", "player")
    end
    if subgroup >= 1 and subgroup <= A.util:GetMaxGroupsForInstance() then
      name = name or "Unknown"
      unitID = "raid"..i
      unitRole = UnitGroupRolesAssigned(unitID)
      if IsInRaid() and A.util:IsLeader() and A.options.tankAssist and (unitRole == "TANK" or isML) and (not rank or rank < 1) then
        PromoteToAssistant(unitID)
      end
      if unitRole == "TANK" then
        tinsert(marks, {key=name, unitID=unitID})
        if raidRole ~= "MAINTANK" then
          -- Can't call protected func: SetPartyAssignment("MAINTANK", unitID)
          tinsert(unsetTanks, A.util:UnitNameWithColor(unitID))
        end
      elseif raidRole == "MAINTANK" then
        -- Can't call protected func: SetPartyAssignment(nil, unitID)
        tinsert(setNonTanks, A.util:UnitNameWithColor(unitID))
      end
    end
  end

  if isRequestFromAssist then
    return
  elseif not A.util:IsLeader() and (A.options.fixOfflineML or A.options.tankAssist) then
    -- There is no guarantee that the raid leader is running the addon as well
    -- and has the same fixOfflineML/tankAssist options set, but send the
    -- request regardless.
    A.addonChannel:Broadcast("f")
  end

  if A.options.tankMark then
    sort(marks, function(a, b) return a.key < b.key end)
    local mark
    for i = 1, min(#marks, #A.options.tankMarkIcons) do
      mark = A.options.tankMarkIcons[i]
      if mark > 0 and mark <= 8 and GetRaidTargetIndex(marks[i].unitID) ~= mark then
        SetRaidTarget(marks[i].unitID, mark)
      end
    end
  end

  if A.options.tankMainTankAlways or (A.options.tankMainTankPRN and IsInInstance()) then
    local bad
    if #unsetTanks > 0 then
      bad = true
      if #unsetTanks == 1 then
        A.console:Print(format(L["%s is not set as main tank!"], A.util:tconcat2(unsetTanks)))
      else
        A.console:Print(format(L["%s are not set as main tanks!"], A.util:tconcat2(unsetTanks)))
      end
    end
    if #setNonTanks > 0 then
      bad = true
      if #setNonTanks == 1 then
        A.console:Print(format(L["%s is incorrectly set as main tank!"], A.util:tconcat2(setNonTanks)))
      else
        A.console:Print(format(L["%s are incorrectly set as main tanks!"], A.util:tconcat2(setNonTanks)))
      end
    end
    if bad then
      if A.options.openRaidTabPRN then
        A.console:Print(L["To fix tanks, use the raid tab. WoW addons cannot set main tanks."])
        A.gui:OpenRaidTab()
        return
      end
      A.console:Print(L["To fix tanks, press O to open the raid tab. WoW addons cannot set main tanks."])
    end
  end
end
