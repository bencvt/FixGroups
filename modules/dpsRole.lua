local A, L = unpack(select(2, ...))
local M = A:NewModule("dpsRole", "AceEvent-3.0", "AceTimer-3.0")
A.dpsRole = M
M.private = {
  needToInspect = {},
  sessionCache = {melee={}, ranged={}},
  dbCleanedUp = false,
}
local R = M.private

local ROLE_MELEE, ROLE_RANGED = 1, 2
local CLASS_DPS_ROLES = {
  ROGUE       = ROLE_MELEE,
  HUNTER      = ROLE_RANGED, -- remove for Legion
  MONK        = ROLE_MELEE,
  PALADIN     = ROLE_MELEE,
  PRIEST      = ROLE_RANGED,
  WARRIOR     = ROLE_MELEE,
  DEATHKNIGHT = ROLE_MELEE,
  DEMONHUNTER = ROLE_MELEE,
  MAGE        = ROLE_RANGED,
  WARLOCK     = ROLE_RANGED,
}
local SPECID_ROLES = {
  [102] = ROLE_RANGED,  -- Balance Druid
  [103] = ROLE_MELEE,   -- Feral Druid
  [253] = ROLE_RANGED,  -- Beast Mastery Hunter
  [254] = ROLE_RANGED,  -- Marksmanship Hunter
  [255] = ROLE_RANGED,  -- Survival Hunter - change to MELEE for Legion
  [262] = ROLE_RANGED,  -- Elemental Shaman
  [263] = ROLE_MELEE,   -- Enhancement Shaman
}
local DELAY_DB_CLEANUP = 20.0
local DB_CLEANUP_MAX_AGE_DAYS = 21

local format, pairs, select, tconcat, time, tostring = format, pairs, select, table.concat, time, tostring
local GetInspectSpecialization, GetPlayerInfoByGUID, GetSpecialization, GetSpecializationInfo, InCombatLockdown, UnitExists, UnitIsUnit = GetInspectSpecialization, GetPlayerInfoByGUID, GetSpecialization, GetSpecializationInfo, InCombatLockdown, UnitExists, UnitIsUnit

local function cleanDbCache(role)
  local earliest = time() - (60*60*24*DB_CLEANUP_MAX_AGE_DAYS)
  local cache = A.db.faction.dpsRoleCache[role]
  local total, removed = 0, 0
  for fullName, when in pairs(cache) do
    total = total + 1
    if when < earliest then
      cache[fullName] = nil
      removed = removed + 1
    end
  end
  if A.debug >= 1 then A.console:Debugf(M, "cleanDbCache removed %d/%d %s older than %d days", removed, total, role, DB_CLEANUP_MAX_AGE_DAYS) end
end

function M:OnEnable()
  M:RegisterEvent("INSPECT_READY")
  M:RegisterMessage("FIXGROUPS_RAID_LEFT")
  -- TODO: handle events for when the player or another raid member changes spec?
  if not A.db.faction.dpsRoleCache then
    A.db.faction.dpsRoleCache = {melee={}, ranged={}}
  end
  if not R.dbCleanedUp and not InCombatLockdown() then
    R.dbCleanedUp = M:ScheduleTimer(function ()
      R.dbCleanedUp = true
      if InCombatLockdown() or A.sorter:IsProcessing() then
        -- Don't worry about trying to reschedule the timer. DB cleanup is
        -- very low priority. Another session will get it done eventually.
        return
      end
      cleanDbCache("melee")
      cleanDbCache("ranged")
    end, DELAY_DB_CLEANUP)
  end
end

function M:INSPECT_READY(event, guid)
  -- Look up name, fullName, and specId.
  local name, realm = select(6, GetPlayerInfoByGUID(guid))
  if name and realm then
    name = name.."-"..realm
  end

  -- Ignore any garbage responses from the server.
  local specId = GetInspectSpecialization(name)
  if not specId or not name then
    return
  end

  local fullName = R.needToInspect[name]
  if not fullName then
    -- We didn't request this inspect, but let's see if we can make use of it.
    if not SPECID_ROLES[specId] then
      return
    end
    fullName = A.util:GetFullName(name)
    if not fullName then
      return
    end
    if A.debug >= 2 then A.console:Debugf(M, "unsolicited inspect ready for %s", name) end
  end

  -- Remove from needToInspect and add to sessionCache.
  R.needToInspect[name] = nil
  local roleYes, roleNo
  if SPECID_ROLES[specId] == ROLE_MELEE then
    roleYes, roleNo = "melee", "ranged"
  elseif SPECID_ROLES[specId] == ROLE_RANGED then
    roleYes, roleNo = "ranged", "melee"
  else
    -- Shouldn't ever happen.
    A.console:Errorf(M, "unknown specId %s for %s!", specId, fullName)
    return
  end
  R.sessionCache[roleYes][fullName] = true
  R.sessionCache[roleNo][fullName] = nil
  if A.debug >= 2 then A.console:Debugf(M, "sessionCache.%s add %s", roleYes, fullName) end

  -- Add to dbCache.
  -- TODO: exclude (or expire sooner) random PUGs, preferring friends and guildies.
  A.db.faction.dpsRoleCache[roleYes][fullName] = time()
  A.db.faction.dpsRoleCache[roleNo][fullName] = nil
  if A.debug >= 1 then A.console:Debugf(M, "dbCache.%s add %s", roleYes, fullName) end

  -- Rebuild roster.
  A.raid:ForceBuildRoster()
end

function M:FIXGROUPS_RAID_LEFT(player)
  if not player.isUnknown and player.name then
    if A.debug >= 2 then A.console:Debugf(M, "cancelled needToInspect %s", player.name) end
    R.needToInspect[player.name] = false
  end
end

local function requestInspect(name, fullName)
  R.needToInspect[name] = fullName
  A.inspect:Request(name)
end

function M:GetDpsRole(player)
  -- Check for unambiguous classes.
  if player.class and CLASS_DPS_ROLES[player.class] then
    return (CLASS_DPS_ROLES[player.class] == ROLE_MELEE) and A.raid.ROLES.MELEE or A.raid.ROLES.RANGED
  end

  -- Sanity check unit name.
  if player.isUnknown or not player.name or not UnitExists(player.name) then
    return A.raid.ROLES.UNKNOWN
  end

  -- Ambiguous class, need to check spec.
  if UnitIsUnit(player.name, "player") then
    local specId = GetSpecializationInfo(GetSpecialization())
    if specId then
      if SPECID_ROLES[specId] == ROLE_MELEE then
        return A.raid.ROLES.MELEE
      elseif SPECID_ROLES[specId] == ROLE_RANGED then
        return A.raid.ROLES.RANGED
      end
    end
    return A.raid.ROLES.UNKNOWN
  end

  -- We're looking at another player. Try the session cache first.
  -- If that's no help, look up the player's specId using the inspect module.
  -- If the db cache has data, use it for the time being, until the inspect
  -- request is complete.
  local fullName = A.util:UnitNameWithRealm(player.name)
  if R.sessionCache.melee[fullName] then
    return A.raid.ROLES.MELEE
  elseif R.sessionCache.ranged[fullName] then
    return A.raid.ROLES.RANGED
  elseif A.db.faction.dpsRoleCache.melee[fullName] then
    if A.debug >= 1 then A.console:Debugf(M, "dbCache.melee found %s", fullName) end
    requestInspect(player.name, fullName)
    return A.raid.ROLES.MELEE
  elseif A.db.faction.dpsRoleCache.ranged[fullName] then
    if A.debug >= 1 then A.console:Debugf(M, "dbCache.ranged found %s", fullName) end
    requestInspect(player.name, fullName)
    return A.raid.ROLES.RANGED
  else
    requestInspect(player.name, fullName)
    return A.raid.ROLES.UNKNOWN
  end
end
