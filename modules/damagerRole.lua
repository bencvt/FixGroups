local A, L = unpack(select(2, ...))
local M = A:NewModule("damagerRole", "AceEvent-3.0", "AceTimer-3.0")
A.damagerRole = M
M.private = {
  needToInspect = {},
  sessionCache = {melee={}, ranged={}},
  dbCleanedUp = false,
}
local R = M.private

local CLASS_DAMAGER_ROLES = {
  WARRIOR     = "melee",
  DEATHKNIGHT = "melee",
  PALADIN     = "melee",
  MONK        = "melee",
  PRIEST      = "ranged",
  -- SHAMAN
  -- DRUID
  ROGUE       = "melee",
  MAGE        = "ranged",
  WARLOCK     = "ranged",
  HUNTER      = "ranged", -- comment out for Legion
  DEMONHUNTER = "melee",
}
local SPECID_ROLES = {
  [262] = "ranged",  -- Elemental Shaman
  [263] = "melee",   -- Enhancement Shaman
  [102] = "ranged",  -- Balance Druid
  [103] = "melee",   -- Feral Druid
  -- Uncomment Hunter specs for Legion:
  --[253] = "ranged",  -- Beast Mastery Hunter
  --[254] = "ranged",  -- Marksmanship Hunter
  --[255] = "melee",   -- Survival Hunter
}
local DELAY_DB_CLEANUP = 20.0
local DB_CLEANUP_MAX_AGE_DAYS = 21
local DB_CLEANUP_PUG_PENALTY = 60*60*24*(DB_CLEANUP_MAX_AGE_DAYS - 1)

local format, pairs, select, tconcat, time, tostring = format, pairs, select, table.concat, time, tostring
local GetInspectSpecialization, GetPlayerInfoByGUID, GetSpecialization, GetSpecializationInfo, InCombatLockdown, UnitExists, UnitIsInMyGuild, UnitIsUnit = GetInspectSpecialization, GetPlayerInfoByGUID, GetSpecialization, GetSpecializationInfo, InCombatLockdown, UnitExists, UnitIsInMyGuild, UnitIsUnit

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
    fullName = A.util:NameAndRealm(name)
    if not fullName then
      return
    end
    if A.debug >= 2 then A.console:Debugf(M, "unsolicited inspect ready for %s", name) end
  end

  -- Remove from needToInspect and add to sessionCache.
  R.needToInspect[name] = nil
  local roleYes, roleNo
  if SPECID_ROLES[specId] == "melee" then
    roleYes, roleNo = "melee", "ranged"
  elseif SPECID_ROLES[specId] == "ranged" then
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
  local ts = time()
  if not UnitIsInMyGuild(name) then
    -- Non-guildies (i.e., PUGs) are cached for a much shorter time.
    ts = ts - DB_CLEANUP_PUG_PENALTY
  end
  A.db.faction.dpsRoleCache[roleYes][fullName] = ts
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

function M:GetDamagerRole(player)
  -- Check for unambiguous classes.
  if player.class and CLASS_DAMAGER_ROLES[player.class] then
    return (CLASS_DAMAGER_ROLES[player.class] == "melee") and A.raid.ROLES.MELEE or A.raid.ROLES.RANGED
  end

  -- Sanity check unit name.
  if player.isUnknown or not player.name or not UnitExists(player.name) then
    return A.raid.ROLES.UNKNOWN
  end

  -- Ambiguous class, need to check spec.
  if UnitIsUnit(player.name, "player") then
    local specId = GetSpecializationInfo(GetSpecialization())
    if specId then
      if SPECID_ROLES[specId] == "melee" then
        return A.raid.ROLES.MELEE
      elseif SPECID_ROLES[specId] == "ranged" then
        return A.raid.ROLES.RANGED
      end
    end
    return A.raid.ROLES.UNKNOWN
  end

  -- We're looking at another player. Try the session cache first.
  -- If that's no help, look up the player's specId using the inspect module.
  -- If the db cache has data, use it for the time being, until the inspect
  -- request is complete.
  local fullName = A.util:NameAndRealm(player.name)
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
