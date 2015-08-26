local A, L = unpack(select(2, ...))
local M = A:NewModule("raid", "AceEvent-3.0", "AceTimer-3.0")
A.raid = M
M.private = {
  roster = {},
  rosterArray = {},
  comp = false,
  comp1 = false,
  comp2 = false,
  prevRoster = {},
  prevRosterArray = {},
  prevComp = false,
  size = 0,
  groupSizes = {0, 0, 0, 0, 0, 0, 0, 0},
  roleCounts = {0, 0, 0, 0, 0},
  builtUniqueNames = false,
  rebuildTimer = false,
  tmp1 = {},
  tmp2 = {},
}
local R = M.private

local DELAY_REBUILD_FOR_UNKNOWN = 2.0

M.ROLES = {TANK=1, HEALER=2, MELEE=3, RANGED=4, UNKNOWN=5}

for i = 1, 40 do
  R.rosterArray[i] = {}
  R.prevRosterArray[i] = {}
end

local format, ipairs, pairs, tinsert, tostring, unpack, wipe = format, ipairs, pairs, tinsert, tostring, unpack, wipe
local tconcat = table.concat
local GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned, UnitName = GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned, UnitName

function M:OnEnable()
  local rebuild = function () M:ForceBuildRoster() end
  for _, event in ipairs({"GROUP_ROSTER_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA"}) do
    M:RegisterEvent(event, rebuild)
  end
end

local function wipeRoster()
  R.size = 0
  for g = 1, 8 do
    R.groupSizes[g] = 0
  end
  for i = 1, 5 do
    R.roleCounts[i] = 0
  end
  R.builtUniqueNames = false
  R.prevComp = R.comp
  R.comp = false
  R.comp1 = false
  R.comp2 = false

  local tmp = wipe(R.prevRoster)
  R.prevRoster = R.roster
  R.roster = tmp

  -- Maintain rosterArray to avoid creating up to 40 new tables every time
  -- we build the roster. The individual tables are wiped on demand.
  -- There will be leftover data whenever a player drops, but it's harmless.
  -- The leftover table is not indexed in R.roster and will be re-used if the
  -- raid refills.
  tmp = R.prevRosterArray
  R.prevRosterArray = R.rosterArray
  R.rosterArray = tmp
end

local function rebuildTimerDone()
  R.rebuildTimer = false
  M:ForceBuildRoster()
end

local function buildRoster()
  wipeRoster()
  R.size = GetNumGroupMembers()
  local lastGroup = A.util:GetMaxGroupsForInstance()
  local p, _, unitRole, hasUnknown
  for i = 1, R.size do
    p = wipe(R.rosterArray[i])
    p.index, p.unitID = i, "raid"..i
    p.name, p.rank, p.group, _, _, p.class, p.zone = GetRaidRosterInfo(i)
    if not p.name then
      p.isUnknown = true
      hasUnknown = true
      p.name = p.unitID
    end
    if p.group > lastGroup then
      p.isSitting = true
    end
    R.groupSizes[p.group] = R.groupSizes[p.group] + 1
    unitRole = UnitGroupRolesAssigned(p.unitID)
    if unitRole == "TANK" then
      p.role = M.ROLES.TANK
    elseif unitRole == "HEALER" then
      p.role = M.ROLES.HEALER
    else
      p.role = A.damagerRole:GetDamagerRole(p)
      if p.role ~= M.ROLES.TANK and p.role ~= M.ROLES.HEALER then
        p.isDamager = true
      end
    end
    if not p.isSitting then
      R.roleCounts[p.role] = R.roleCounts[p.role] + 1
    end
    R.roster[p.name] = p
  end
  local t, h, m, r, u = unpack(R.roleCounts)
  R.comp1 = format("%d/%d/%d", t, h, m+r+u)
  if u > 0 then
    R.comp2 = format("%d+%d+%d", m, r, u)
  else
    R.comp2 = format("%d+%d", m, r)
  end
  R.comp = format("%s (%s)", R.comp1, R.comp2)
  if hasUnknown then
    if not R.rebuildTimer then
      if A.DEBUG >= 1 then A.console:Debugf(M, "unknown player(s) in raid, scheduling ForceBuildRoster") end
      R.rebuildTimer = M:ScheduleTimer(rebuildTimerDone, DELAY_REBUILD_FOR_UNKNOWN)
    end
  elseif R.rebuildTimer then
    if A.DEBUG >= 1 then A.console:Debugf(M, "cancelling scheduled ForceBuildRoster") end
    M:CancelTimer(R.rebuildTimer)
    R.rebuildTimer = false
  end
end

function M:BuildUniqueNames()
  if R.builtUniqueNames then
    return
  end
  local nameCounts = wipe(R.tmp1)
  local p, onlyName
  -- First pass: build nameCounts.
  for i = 1, R.size do
    p = R.rosterArray[i]
    if not p.isUnknown then
      onlyName = A.util:StripRealm(p.name)
      nameCounts[onlyName] = (nameCounts[onlyName] or 0) + 1
    end
  end
  -- Second pass: set uniqueName for each player.
  for i = 1, R.size do
    p = R.rosterArray[i]
    if not p.isUnknown then
      onlyName = A.util:StripRealm(p.name)
      p.uniqueName = nameCounts[onlyName] > 1 and A.util:NameAndRealm(p.name) or onlyName
    end
  end
  R.builtUniqueNames = true
end

function M:ForceBuildRoster()
  if not IsInRaid() then
    wipeRoster()
    return
  end
  buildRoster()
  if A.DEBUG >= 2 then M:DebugPrintRoster() end
  
  local prevGroup, group
  for name, player in pairs(R.roster) do
    if R.prevRoster[name] then
      prevGroup = R.prevRoster[name].group
      group = player.group
      if prevGroup ~= group then
        if A.DEBUG >= 1 then A.console:Debugf(M, "RAID_GROUP_CHANGED %s %d->%d", name, prevGroup, group) end
        M:SendMessage("FIXGROUPS_RAID_GROUP_CHANGED", name, prevGroup, group)
      end
    end
  end
  
  for name, player in pairs(R.prevRoster) do
    if not player.isUnknown and not R.roster[name] then
      if A.DEBUG >= 1 then A.console:Debugf(M, "RAID_LEFT %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_RAID_LEFT", player)
    end
  end
  
  for name, player in pairs(R.roster) do
    if not player.isUnknown and not R.prevRoster[name] then
      if A.DEBUG >= 1 then A.console:Debugf(M, "RAID_JOINED %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_RAID_JOINED", player)
    end
  end
  
  if R.prevComp ~= R.comp then
    if A.DEBUG >= 1 then A.console:Debugf(M, "RAID_COMP_CHANGED %s -> %s", tostring(R.prevComp), R.comp) end
    M:SendMessage("FIXGROUPS_RAID_COMP_CHANGED", R.prevComp, R.comp)
  end
end

function M:NumSitting()
  local t = 0
  for i = (A.util:GetMaxGroupsForInstance() + 1), 8 do
    t = t + R.groupSizes[i]
  end
  return t
end

function M:GetRoleCounts()
  return unpack(R.roleCounts)
end

function M:GetUnknownNames()
  local names = wipe(R.tmp1)
  local p
  for _, name in ipairs(A.util:SortedKeys(R.roster, R.tmp2)) do
    p = R.roster[name]
    if p.role == M.ROLES.UNKNOWN then
      tinsert(names, A.util:UnitNameWithColor(name))
    end
  end
  return A.util:LocaleTableConcat(names)
end

function M:GetSize()
  return R.size
end

function M:GetGroupSize(group)
  return R.groupSizes[group]
end

function M:GetComp()
  return R.comp
end

function M:GetCompParts()
  return R.comp1, R.comp2
end

function M:GetPlayer(name)
  return name and R.roster[name]
end

function M:FindPlayer(name)
  local p = M:GetPlayer(name)
  if p then
    return p
  end
  local onlyName = A.util:StripRealm(name)
  p = M:GetPlayer(onlyName)
  if p then
    return p
  end
  p = M:GetPlayer(A.util:NameAndRealm(name))
  if p then
    return p
  end
  local found
  for i = 1, R.size do
    p = R.rosterArray[i]
    if not p.isUnknown then
      if onlyName == A.util:StripRealm(p.name) then
        if found then
          -- Multiple players match, ambiguous!
          return nil
        end
        found = p
      end
    end
  end
  return found
end

function M:GetRoster()
  return R.roster
end

function M:IsHealer(name)
  return name and R.roster[name] and (R.roster[name].role == M.ROLES.HEALER)
end

function M:IsTank(name)
  return name and R.roster[name] and (R.roster[name].role == M.ROLES.TANK)
end

function M:IsMelee(name)
  return name and R.roster[name] and (R.roster[name].role == M.ROLES.MELEE)
end

function M:IsRanged(name)
  return name and R.roster[name] and (R.roster[name].role == M.ROLES.RANGED)
end

function M:IsDamager(name)
  return name and R.roster[name] and R.roster[name].isDamager and true or false
end

function M:IsInSameZone(name)
  if IsInRaid() and R.roster[name] then
    return R.roster[name].zone == R.roster[UnitName("player")].zone
  end
end

function M:DebugPrintRoster()
  A.console:Debugf(M, "roster size=%d groupSizes={%s} roleCounts={%s} comp=%s:", R.size, tconcat(R.groupSizes, ","), tconcat(R.roleCounts, ","), R.comp)
  local p, line
  for i = 1, R.size do
    p = R.rosterArray[i]
    line = " "
    for _, k in ipairs(A.util:SortedKeys(p, R.tmp1)) do
      line = line.." "..k.."="..tostring(p[k])
    end
    A.console:DebugMore(M, line)
  end
end
