local A, L = unpack(select(2, ...))
local M = A:NewModule("raid", "AceEvent-3.0")
A.raid = M
M.private = {
  roster = {},
  players = {},
  prevPlayers = {},
  prevRoster = {},
  prevComp = false,
  size = 0,
  groupSizes = {0, 0, 0, 0, 0, 0, 0, 0},
  roleCounts = {0, 0, 0, 0, 0},
  tmp1 = {},
}
local R = M.private

M.ROLES = {TANK=1, MELEE=2, UNKNOWN=3, RANGED=4, HEALER=5}
local CLASS_DPS_ROLES = {
  ROGUE       = M.ROLES.MELEE,
  PALADIN     = M.ROLES.MELEE,
  MONK        = M.ROLES.MELEE,
  WARRIOR     = M.ROLES.MELEE,
  DEATHKNIGHT = M.ROLES.MELEE,
  DEMONHUNTER = M.ROLES.MELEE,
  DRUID       = M.ROLES.UNKNOWN,
  SHAMAN      = M.ROLES.UNKNOWN,
  HUNTER      = M.ROLES.RANGED, -- will change in Legion
  PRIEST      = M.ROLES.RANGED,
  MAGE        = M.ROLES.RANGED,
  WARLOCK     = M.ROLES.RANGED,
}

for i = 1, 40 do
  R.roster[i] = {}
  R.prevRoster[i] = {}
end

local format, ipairs, pairs, tconcat, tinsert, tostring, wipe = format, ipairs, pairs, table.concat, table.insert, tostring, wipe
local GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned = GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitGroupRolesAssigned

local wipeRoster, buildRoster -- func defined below

function M:OnEnable()
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function M:GROUP_ROSTER_UPDATE(event)
  if not IsInRaid() then
    wipeRoster()
    return
  end
  buildRoster()
  
  for name, _ in pairs(R.prevPlayers) do
    if not R.players[name] then
      --A.console:Debug("RAID_LEFT name=%s", name)
      M:SendMessage("FIXGROUPS_RAID_LEFT", name)
    end
  end
  
  for name, _ in pairs(R.players) do
    if not R.prevPlayers[name] then
      --A.console:Debug("RAID_JOINED name=%s", name)
      M:SendMessage("FIXGROUPS_RAID_JOINED", name)
    end
  end
  
  local group, prevGroup
  for name, _ in pairs(R.players) do
    if R.prevPlayers[name] then
      group = R.roster[R.players[name]].group
      prevGroup = R.prevRoster[R.prevPlayers[name]].group
      if group ~= prevGroup then
        --A.console:Debug("RAID_GROUP_CHANGED name=%s group=%d prevGroup=%d", name, group, prevGroup)
        M:SendMessage("FIXGROUPS_RAID_GROUP_CHANGED", name, group, prevGroup)
      end
    end
  end
  
  local comp = M:GetCompTMURH()
  if R.prevComp ~= comp then
    --A.console:Debug("RAID_COMP_CHANGED comp=%s oldComp=%s", comp, R.prevComp)
    M:SendMessage("FIXGROUPS_RAID_COMP_CHANGED", comp, R.prevComp)
  end
  R.prevComp = comp
end

function M:GetCompTHD()
  return tostring(R.roleCounts[M.ROLES.TANK]).."/"..tostring(R.roleCounts[M.ROLES.HEALER]).."/"..tostring(R.roleCounts[M.ROLES.MELEE]+R.roleCounts[M.ROLES.UNKNOWN]+R.roleCounts[M.ROLES.RANGED])
end

function M:GetCompTMURH()
  return tconcat(R.roleCounts, ",")
end

local function wipeRoster()
  local tmp = wipe(R.prevPlayers)
  R.prevPlayers = R.players
  R.players = tmp
  R.size = 0
  for g = 1, 8 do
    R.groupSizes[g] = 0
  end
  for i = 1, 5 do
    R.roleCounts[i] = 0
  end
  tmp = R.prevRoster
  R.prevRoster = R.roster
  R.roster = tmp
  for i = 1, 40 do
    if not R.roster[i].name then
      -- Should never be holes in the roster.
      return
    end
    wipe(R.roster[i])
  end
end

local function buildRoster()
  wipeRoster()
  R.size = GetNumGroupMembers()
  local p, _, unitRole
  for i = 1, R.size do
    p = R.roster[i]
    p.name, p.rank, p.group, _, _, p.class = GetRaidRosterInfo(i)
    if not p.name then
      --TODO remove
      A.console:Debug("GetRaidRosterInfo(%d): name=<nil> rank=%s group=%s class=%s", i, tostring(p.rank or "<nil>"), tostring(p.group or "<nil>"), tostring(p.class or "<nil>"))
      p.name = "Unknown"
    end
    R.groupSizes[p.group] = R.groupSizes[p.group] + 1
    p.unitID = "raid"..i
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
    R.players[p.name] = i
  end
end

function M:DebugPrintRoster()
  A.console:Debug(format("roster size=%d groupSizes=%s compTHD=%s comp=%s:", R.size, tconcat(R.groupSizes, ","), M:GetCompTHD(), M:GetCompTMURH()))
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
    A.console:Debug(line)
  end
end
