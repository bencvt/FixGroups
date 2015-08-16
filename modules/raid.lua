local A, L = unpack(select(2, ...))
local M = A:NewModule("raid", "AceEvent-3.0")
A.raid = M
M.private = {
  roster = {},
  rosterArray = {},
  prevRoster = {},
  prevRosterArray = {},
  prevComp = "0/0/0",
  size = 0,
  groupSizes = {0, 0, 0, 0, 0, 0, 0, 0},
  roleCounts = {0, 0, 0, 0, 0},
  tmp1 = {},
}
local R = M.private

M.ROLES = {TANK=1, MELEE=2, UNKNOWN=3, RANGED=4, HEALER=5}
local CLASS_DPS_ROLES = {
  ROGUE       = M.ROLES.MELEE,
  HUNTER      = M.ROLES.RANGED, -- will change in Legion
  DRUID       = M.ROLES.UNKNOWN,
  SHAMAN      = M.ROLES.UNKNOWN,
  MONK        = M.ROLES.MELEE,
  PALADIN     = M.ROLES.MELEE,
  PRIEST      = M.ROLES.RANGED,
  WARRIOR     = M.ROLES.MELEE,
  DEATHKNIGHT = M.ROLES.MELEE,
  DEMONHUNTER = M.ROLES.MELEE,
  MAGE        = M.ROLES.RANGED,
  WARLOCK     = M.ROLES.RANGED,
}

for i = 1, 40 do
  R.rosterArray[i] = {}
  R.prevRosterArray[i] = {}
end

local format, ipairs, pairs, tconcat, tinsert, tostring, wipe = format, ipairs, pairs, table.concat, table.insert, tostring, wipe
local GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned = GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned

function M:OnEnable()
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
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
  -- we build the roster.
  tmp = R.prevRosterArray
  R.prevRosterArray = R.rosterArray
  R.rosterArray = tmp
  -- The individual tables are wiped on demand. There will be leftover data
  -- whenever a player drops, but it's harmless, not indexed in R.roster.
end

local function buildRoster()
  wipeRoster()
  R.size = GetNumGroupMembers()
  local p, _, unitRole
  for i = 1, R.size do
    p = wipe(R.rosterArray[i])
    p.index, p.unitID = i, "raid"..i
    p.name, p.rank, p.group, _, _, p.class = GetRaidRosterInfo(i)
    if not p.name then
      p.isUnknown = true
      p.name = p.unitID
    end
    R.groupSizes[p.group] = R.groupSizes[p.group] + 1
    unitRole = UnitGroupRolesAssigned(p.unitID)
    local role
    if unitRole == "TANK" then
      p.role = M.ROLES.TANK
    elseif unitRole == "HEALER" then
      p.role = M.ROLES.HEALER
    else
      p.role = p.class and CLASS_DPS_ROLES[p.class] or M.ROLES.UNKNOWN
      p.isDPS = true
    end
    R.roleCounts[p.role] = R.roleCounts[p.role] + 1
    R.roster[p.name] = p
  end
end

function M:GROUP_ROSTER_UPDATE(event)
  M:ForceBuildRoster()
end

function M:ForceBuildRoster()
  if not IsInRaid() then
    R.prevComp = "0/0/0"
    wipeRoster()
    return
  end
  buildRoster()
  local comp = M:GetCompTHD()
  if A.debug >= 4 then M:DebugPrintRoster() end
  
  local prevGroup
  for name, p in pairs(R.roster) do
    if R.prevRoster[name] then
      prevGroup = R.prevRoster[name].group
      if p.group ~= prevGroup then
        if A.debug >= 3 then A.console:Debug(format("RAID_GROUP_CHANGED %s %d -> %d", name, prevGroup, p.group)) end
        M:SendMessage("FIXGROUPS_RAID_GROUP_CHANGED", name, prevGroup, p.group)
      end
    end
  end
  
  for name, p in pairs(R.prevRoster) do
    if not p.isUnknown and not R.roster[name] then
      if A.debug >= 3 then A.console:Debug(format("RAID_LEFT %s", name)) end
      M:SendMessage("FIXGROUPS_RAID_LEFT", p)
    end
  end
  
  for name, p in pairs(R.roster) do
    if not p.isUnknown and not R.prevRoster[name] then
      if A.debug >= 3 then A.console:Debug(format("RAID_JOINED %s", name)) end
      M:SendMessage("FIXGROUPS_RAID_JOINED", p)
    end
  end
  
  if R.prevComp ~= comp then
    if A.debug >= 2 then A.console:Debug(format("RAID_COMP_CHANGED %s -> %s", tostring(R.prevComp), comp)) end
    M:SendMessage("FIXGROUPS_RAID_COMP_CHANGED", tostring(R.prevComp), comp)
  end
  R.prevComp = comp
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

function M:DebugPrintRoster()
  A.console:Debug(format("roster size=%d groupSizes=%s compTHD=%s compTMURH=%s:", R.size, tconcat(R.groupSizes, ","), M:GetCompTHD(), M:GetCompTMURH()))
  local p, sorted, line
  for i = 1, 40 do
    p = R.roster[i]
    if not p.name then
      return
    end
    sorted = A.util:SortedKeys(p, R.tmp1)
    line = " "
    for _, k in ipairs(sorted) do
      line = line.." "..k.."="..tostring(p[k])
    end
    A.console:DebugMore(line)
  end
end
