local A, L = unpack(select(2, ...))
local M = A:NewModule("raid", "AceEvent-3.0")
A.raid = M
M.private = {
  roster = {},
  rosterArray = {},
  prevRoster = {},
  prevRosterArray = {},
  prevCompTHD = "0/0/0",
  prevCompTMURH = "0,0,0,0,0",
  size = 0,
  groupSizes = {0, 0, 0, 0, 0, 0, 0, 0},
  roleCounts = {0, 0, 0, 0, 0},
}
local R = M.private

M.ROLES = {TANK=1, MELEE=2, UNKNOWN=3, RANGED=4, HEALER=5}

for i = 1, 40 do
  R.rosterArray[i] = {}
  R.prevRosterArray[i] = {}
end

local format, ipairs, pairs, tconcat, tinsert, tostring, wipe = format, ipairs, pairs, table.concat, table.insert, tostring, wipe
local GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned, UnitName = GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned, UnitName

function M:OnEnable()
  local f = function () M:ForceBuildRoster() end
  M:RegisterEvent("GROUP_ROSTER_UPDATE", f)
  M:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", f)
  M:RegisterEvent("ZONE_CHANGED", f)
  M:RegisterEvent("ZONE_CHANGED_INDOORS", f)
  M:RegisterEvent("ZONE_CHANGED_NEW_AREA", f)
end

local function wipeRoster()
  R.size = 0
  for g = 1, 8 do
    R.groupSizes[g] = 0
  end
  for i = 1, 5 do
    R.roleCounts[i] = 0
  end

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

local function buildRoster()
  wipeRoster()
  R.size = GetNumGroupMembers()
  local lastGroup = A.util:GetMaxGroupsForInstance()
  local p, _, unitRole
  for i = 1, R.size do
    p = wipe(R.rosterArray[i])
    p.index, p.unitID = i, "raid"..i
    p.name, p.rank, p.group, _, _, p.class, p.zone = GetRaidRosterInfo(i)
    if not p.name then
      p.isUnknown = true
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
      p.role = A.dpsRole:GetDpsRole(p)
      p.isDPS = true
    end
    R.roleCounts[p.role] = R.roleCounts[p.role] + 1
    R.roster[p.name] = p
  end
end

function M:ForceBuildRoster()
  if not IsInRaid() then
    R.prevCompTHD = "0/0/0"
    R.prevCompTMURH = "0,0,0,0,0"
    wipeRoster()
    return
  end
  buildRoster()
  local compTHD = M:GetCompTHD()
  local compTMURH = M:GetCompTMURH()
  if A.debug >= 2 then M:DebugPrintRoster() end
  
  local prevGroup, group
  for name, player in pairs(R.roster) do
    if R.prevRoster[name] then
      prevGroup = R.prevRoster[name].group
      group = player.group
      if prevGroup ~= group then
        if A.debug >= 1 then A.console:Debugf(M, "RAID_GROUP_CHANGED %s %d->%d", name, prevGroup, group) end
        M:SendMessage("FIXGROUPS_RAID_GROUP_CHANGED", name, prevGroup, group)
      end
    end
  end
  
  for name, player in pairs(R.prevRoster) do
    if not player.isUnknown and not R.roster[name] then
      if A.debug >= 1 then A.console:Debugf(M, "RAID_LEFT %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_RAID_LEFT", player)
    end
  end
  
  for name, player in pairs(R.roster) do
    if not player.isUnknown and not R.prevRoster[name] then
      if A.debug >= 1 then A.console:Debugf(M, "RAID_JOINED %s", name) end
      -- Message consumers should not modify the player table.
      M:SendMessage("FIXGROUPS_RAID_JOINED", player)
    end
  end
  
  if R.prevCompTMURH ~= compTMURH or R.prevCompTHD ~= compTHD then
    if A.debug >= 1 then A.console:Debugf(M, "RAID_COMP_CHANGED %s->%s (%s->%s)", R.prevCompTHD, compTHD, R.prevCompTMURH, compTMURH) end
    M:SendMessage("FIXGROUPS_RAID_COMP_CHANGED", R.prevCompTHD, compTHD, R.prevCompTMURH, compTMURH)
  end
  R.prevCompTMURH = compTMURH
  R.prevCompTHD = compTHD
end

function M:NumSitting()
  local t = 0
  for i = (A.util:GetMaxGroupsForInstance() + 1), 8 do
    t = t + R.groupSizes[i]
  end
  return t
end

function M:GetSize()
  return R.size
end

function M:GetGroupSize(group)
  return R.groupSizes[group]
end

function M:GetCompTHD()
  return tostring(R.roleCounts[M.ROLES.TANK]).."/"..tostring(R.roleCounts[M.ROLES.HEALER]).."/"..tostring(R.roleCounts[M.ROLES.MELEE]+R.roleCounts[M.ROLES.UNKNOWN]+R.roleCounts[M.ROLES.RANGED])
end

function M:GetCompTMURH()
  return tconcat(R.roleCounts, ",")
end

function M:GetPlayer(name)
  return name and R.roster[name]
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

function M:IsDPS(name)
  return name and R.roster[name] and R.roster[name].isDPS and true or false
end

function M:IsInSameZone(name)
  if IsInRaid() and R.roster[name] then
    return R.roster[name].zone == R.roster[UnitName("player")].zone
  end
end

function M:DebugPrintRoster()
  A.console:Debugf(M, "roster size=%d groupSizes=%s compTHD=%s compTMURH=%s:", R.size, tconcat(R.groupSizes, ","), M:GetCompTHD(), M:GetCompTMURH())
  local p, line
  for i = 1, R.size do
    p = R.rosterArray[i]
    line = " "
    for _, k in ipairs(A.util:SortedKeys(p)) do
      line = line.." "..k.."="..tostring(p[k])
    end
    A.console:DebugMore(M, line)
  end
end
