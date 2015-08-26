local A, L = unpack(select(2, ...))
local M = A:NewModule("group", "AceEvent-3.0", "AceTimer-3.0")
A.group = M
M.private = {
  roster = {},
  rosterArray = {},
  compTHD = false,
  compMRU = false,
  prevRoster = {},
  prevRosterArray = {},
  prevCompTHD = false,
  prevCompMRU = false,
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

local format, ipairs, pairs, select, tinsert, tostring, unpack, wipe = format, ipairs, pairs, select, tinsert, tostring, unpack, wipe
local tconcat = table.concat
local GetNumGroupMembers, GetSpecialization, GetSpecializationInfo, GetRaidRosterInfo, IsInGroup, IsInRaid, UnitClass, UnitGroupRolesAssigned, UnitIsUnit, UnitName = GetNumGroupMembers, GetSpecialization, GetSpecializationInfo, GetRaidRosterInfo, IsInGroup, IsInRaid, UnitClass, UnitGroupRolesAssigned, UnitIsUnit, UnitName

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
  R.prevCompTHD = R.compTHD
  R.prevCompMRU = R.compMRU
  R.compTHD = false
  R.compMRU = false

  local tmp = wipe(R.prevRoster)
  R.prevRoster = R.roster
  R.roster = tmp

  -- Maintain rosterArray to avoid creating up to 40 new tables every time
  -- we build the roster. The individual tables are wiped on demand.
  -- There will be leftover data whenever a player drops, but it's harmless.
  -- The leftover table is not indexed in R.roster and will be re-used if the
  -- group refills.
  tmp = R.prevRosterArray
  R.prevRosterArray = R.rosterArray
  R.rosterArray = tmp
end

local function rebuildTimerDone()
  R.rebuildTimer = false
  M:ForceBuildRoster()
end

local function buildSoloRoster(rindex)
  local p = R.rosterArray[rindex]
  p.rindex = rindex
  p.unitID = "player"
  p.name = UnitName("player")
  p.rank = 2
  p.group = 1
  p.class = select(2, UnitClass("player"))
  -- p.zone not set
  R.groupSizes[1] = R.groupSizes[1] + 1
  local unitRole = select(6, GetSpecializationInfo(GetSpecialization()))
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
  R.roleCounts[p.role] = R.roleCounts[p.role] + 1
  R.roster[p.name] = p
end

local function findPartyUnitID(name, nextGuess)
  local unitID
  if name then
    if UnitIsUnit(name, "player") then
      return "player", nextGuess
    end
    for i = 1, 4 do
      unitID = "party"..i
      if UnitIsUnit(name, unitID) then
        return unitID, nextGuess
      end
    end
  end
  -- The server hasn't sent us this player's name yet!
  -- Getting the party unit ID will take some extra work.
  local existing = wipe(R.tmp1)
  for i = 1, R.size do
    name = GetRaidRosterInfo(i)
    if name then
      for j = 1, 4 do
        unitID = "party"..j
        if UnitIsUnit(name, unitID) then
          existing[unitID] = true
        end
      end
    end
  end
  for j = nextGuess, 4 do
    unitID = "party"..j
    if not existing[unitID] then
      return unitID, nextGuess + 1
    end
  end
  A.console:Errorf(M, "invalid party unitIDs")
  return "Unknown"..nextGuess, nextGuess + 1
end

local function buildRoster()
  wipeRoster()
  local isRaid = IsInRaid()
  local areAnyUnknown
  if IsInGroup() then
    R.size = GetNumGroupMembers()
    local p, _, unitRole
    local lastGroup = A.util:GetMaxGroupsForInstance()
    local nextGuess = 1
    for i = 1, R.size do
      p = wipe(R.rosterArray[i])
      p.rindex = i
      p.name, p.rank, p.group, _, _, p.class, p.zone = GetRaidRosterInfo(i)
      if isRaid then
        p.unitID = "raid"..i
      else
        -- The number in party unit IDs (party1, party2, party3, party4)
        -- does NOT correspond to the GetRaidRosterInfo index.
        -- We have to check names to get the proper unit ID.
        p.unitID, nextGuess = findPartyUnitID(p.name, nextGuess)
      end
      if not p.name then
        p.isUnknown = true
        areAnyUnknown = true
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
  else
    R.size = 1
    buildSoloRoster(1)
  end

  -- Build comp strings.
  local t, h, m, r, u = unpack(R.roleCounts)
  R.compTHD = format("%d/%d/%d", t, h, m+r+u)
  if u > 0 then
    R.compMRU = format("%d+%d+%d", m, r, u)
  else
    R.compMRU = format("%d+%d", m, r)
  end
  -- Schedule rebuild if there are any unknown players.
  if areAnyUnknown then
    if not R.rebuildTimer then
      if A.DEBUG >= 1 then A.console:Debugf(M, "unknown player(s) in group, scheduling ForceBuildRoster") end
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
  buildRoster()
  if A.DEBUG >= 2 then M:DebugPrintRoster() end
  
  local prevGroup, group
  for name, player in pairs(R.roster) do
    if R.prevRoster[name] then
      prevGroup = R.prevRoster[name].group
      group = player.group
      if prevGroup ~= group then
        if A.DEBUG >= 1 then A.console:Debugf(M, "PLAYER_CHANGED_GROUP %s %d->%d", name, prevGroup, group) end
        M:SendMessage("FIXGROUPS_PLAYER_CHANGED_GROUP", name, prevGroup, group)
      end
    end
  end
  
  for name, player in pairs(R.prevRoster) do
    if not player.isUnknown and not R.roster[name] then
      if A.DEBUG >= 1 then A.console:Debugf(M, "PLAYER_LEFT %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_PLAYER_LEFT", player)
    end
  end
  
  for name, player in pairs(R.roster) do
    if not player.isUnknown and not R.prevRoster[name] then
      if A.DEBUG >= 1 then A.console:Debugf(M, "PLAYER_JOINED %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_PLAYER_JOINED", player)
    end
  end
  
  if R.prevCompTHD ~= R.compTHD or R.prevCompMRU ~= R.compMRU then
    if A.DEBUG >= 1 then A.console:Debugf(M, "COMP_CHANGED %s (%s) -> %s (%s)", tostring(R.prevCompTHD), tostring(R.prevCompMRU), R.compTHD, R.compMRU) end
    M:SendMessage("FIXGROUPS_COMP_CHANGED", R.prevCompTHD, R.prevCompMRU, R.compTHD, R.compMRU)
  end
end

function M:NumSitting()
  local t = 0
  for i = (A.util:GetMaxGroupsForInstance() + 1), 8 do
    t = t + R.groupSizes[i]
  end
  return t
end

function M:GetRoleCountsTHMRU()
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
  return R.compTHD, R.compMRU
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
  A.console:Debugf(M, "roster size=%d groupSizes={%s} roleCounts={%s} comp=%s (%s):", R.size, tconcat(R.groupSizes, ","), tconcat(R.roleCounts, ","), R.compTHD, R.compMRU)
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