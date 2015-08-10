local addonName = ...
FixGroups = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local FixGroups = FixGroups
FixGroups.name = addonName
FixGroups.version = GetAddOnMetadata(addonName, "Version")

local MAX_STEPS = 30
local MAX_TIMEOUTS = 20
local TIMEOUT_SECONDS = 1.0
local ACTION_DELAY_SECONDS = 0.1
local SR_TANK, SR_MELEE, SR_UNKNOWN, SR_RANGED, SR_HEALER = 1, 2, 3, 4, 5
local SORT_ROLES_TMURH = {"a", "b", "c", "d", "e"}
local SORT_ROLES_THMUR = {"a", "c", "d", "e", "b"}

local sortRoles = SORT_ROLES_TMURH
local prevGroups = {{}, {}, {}, {}, {}, {}, {}, {}}
local groups = {{}, {}, {}, {}, {}, {}, {}, {}}
local groupSizes = {0, 0, 0, 0, 0, 0, 0, 0}
local groupSizeTotal = 0
local sitting = 0
local meterSnapshot = {}
local delta = {}
local action = {}
local tmp1, tmp2, tmp3 = {}, {}, {}

-- -----------------------------------------------------------------------------
-- General utility
-- -----------------------------------------------------------------------------

local sort = table.sort
local tconcat = table.concat
local tinsert = table.insert
local floor = math.floor
local max = math.max
local min = math.min
local strsub = string.sub
local strsplit = string.split
local strfind = string.find
local strmatch = string.match
local format = string.format

local function tconcat2(t)
  local sz = #t
  if sz == 0 then
    return ""
  elseif sz == 1 then
    return t[1]
  elseif sz == 2 then
    return t[1].." ".."and".." "..t[2]
  end
  local tmp = t[sz]
  t[sz] = "and".." "..t[sz]
  local result = tconcat(t, ", ")
  t[sz] = tmp
  return result
end

-- -----------------------------------------------------------------------------
-- Basic WoW API helpers
-- -----------------------------------------------------------------------------

function FixGroups:IsLeader()
  return IsInGroup() and UnitIsGroupLeader("player")
end

function FixGroups:IsLeaderOrAssist()
  if IsInRaid() then
    return UnitIsRaidOfficer("player") or UnitIsGroupLeader("player")
  end
  return IsInGroup()  
end

local function getMaxGroupsForInstance()
  if not IsInInstance() then
    return 8
  end
  return max(6, floor(select(5, GetInstanceInfo()) / 5))
end

local function getAddonNameAndVersion(name)
  name = name or FixGroups.name
  local v = GetAddOnMetadata(name, "Version")
  if v then
    return name.." "..v
  end
  return name
end

local function openRaidTab()
  OpenFriendsFrame(4)
end

-- -----------------------------------------------------------------------------
-- Populate sortMode, prevGroups, groups, groupSizes, groupSizeTotal, and sitting
-- -----------------------------------------------------------------------------

local function saveGroups()
  local tmp = prevGroups
  prevGroups = groups
  groups = tmp -- will get wiped on next use
end

local function areGroupsDifferent()
  for g = 1, 8 do
    -- For each group, only compare keys (i.e., role+class+name).
    -- Changes in the unitID (raid1, raid2, etc.) are irrelevant.
    for key, _ in pairs(prevGroups[g]) do
      if not groups[g][key] then
        return true
      end
    end
    for key, _ in pairs(groups[g]) do
      if not prevGroups[g][key] then
        return true
      end
    end
  end
  return false
end

local function keyGetName(key)
  return strsub(key, 3)
end

local function keyIsTank(key)
  return strsub(key, 1, 1) == sortRoles[SR_TANK]
end

local function keyIsHealer(key)
  return strsub(key, 1, 1) == sortRoles[SR_HEALER]
end

local function keyIsDps(key)
  local role = strsub(key, 1, 1)
  return role == sortRoles[SR_MELEE] or role == sortRoles[SR_UNKNOWN] or role == sortRoles[SR_RANGED]
end

local function buildGroups()
  sortMode = (FixGroups.options.sortMode == "THMUR") and SORT_ROLES_THMUR or SORT_ROLES_TMURH
  for g = 1, 8 do
    wipe(groups[g])
    groupSizes[g] = 0
  end
  groupSizeTotal = 0
  sitting = 0
  local name, subgroup, class, unitRole, _
  for i = 1, GetNumGroupMembers() do
    name, _, subgroup, _, _, class = GetRaidRosterInfo(i)
    if subgroup > getMaxGroupsForInstance() then
      sitting = sitting + 1
    elseif subgroup >= 1 then
      unitRole = UnitGroupRolesAssigned("raid"..i)
      if unitRole == "TANK" then
        -- We don't care what class the tanks are.
        class = sortRoles[SR_TANK].."1"
      elseif unitRole == "HEALER" then
        if     class == "PALADIN"      then class = sortRoles[SR_HEALER].."1"
        elseif class == "MONK"         then class = sortRoles[SR_HEALER].."2"
        elseif class == "DRUID"        then class = sortRoles[SR_HEALER].."3"
        elseif class == "SHAMAN"       then class = sortRoles[SR_HEALER].."4"
        elseif class == "PRIEST"       then class = sortRoles[SR_HEALER].."5"
        else                                class = sortRoles[SR_HEALER].."9"
        end
      else
        -- UnitGroupRolesAssigned does not distinguish between melee and ranged.
        -- It's possible to determine based on class for 9 out of 11, so we just
        -- include the class in the sort key with melee > unknown > ranged.
        --
        -- We put the pure DPS classes at the far ends to avoid having, e.g.,
        -- shadow priests in the healer group.
        --
        -- And of course DPS shamans and druids can be either melee or ranged.
        -- Determining feral/balance and enhance/elemental is possible but
        -- non-trivial. Instead of doing that, just stick druids and shamans
        -- in the middle of the melee/ranged spectrum.
        if     class == "ROGUE"        then class = sortRoles[SR_MELEE].."1"
        elseif class == "PALADIN"      then class = sortRoles[SR_MELEE].."2"
        elseif class == "MONK"         then class = sortRoles[SR_MELEE].."3"
        elseif class == "WARRIOR"      then class = sortRoles[SR_MELEE].."4"
        elseif class == "DEATHKNIGHT"  then class = sortRoles[SR_MELEE].."5"
        elseif class == "DEMONHUNTER"  then class = sortRoles[SR_MELEE].."6"
        elseif class == "DRUID"        then class = sortRoles[SR_UNKNOWN].."1"
        elseif class == "SHAMAN"       then class = sortRoles[SR_UNKNOWN].."2"
        elseif class == "PRIEST"       then class = sortRoles[SR_RANGED].."1"
        elseif class == "HUNTER"       then class = sortRoles[SR_RANGED].."2"
        elseif class == "MAGE"         then class = sortRoles[SR_RANGED].."3"
        elseif class == "WARLOCK"      then class = sortRoles[SR_RANGED].."4"
        else                                class = sortRoles[SR_UNKNOWN].."9"
        end
      end
      groups[subgroup][class..(name or "Unknown")] = i
      groupSizes[subgroup] = groupSizes[subgroup] + 1
      groupSizeTotal = groupSizeTotal + 1
    end
  end
end

-- -----------------------------------------------------------------------------
-- Populate meterSnapshot (damage/healing meter addon integration)
-- -----------------------------------------------------------------------------

local function isSortingByMeter()
  return FixGroups.options.sortMode == "meter" or FixGroups.run.sortMode == "meter"
end

local function isSplittingRaid()
  return FixGroups.run.sortMode == "split"
end

local function calculateMeterAverages()
  local countDamage, totalDamage = 0, 0
  local countHealing, totalHealing = 0, 0
  for key, amount in pairs(meterSnapshot) do
    if keyIsDps(key) then
      countDamage = countDamage + 1
      totalDamage = totalDamage + amount
    elseif keyIsHealer(key) then
      countHealing = countHealing + 1
      totalHealing = totalHealing + amount
    end
  end
  meterSnapshot["_averageDamage"] = (countDamage > 0) and (totalDamage / countDamage) or 0
  meterSnapshot["_averageHealing"] = (countHealing > 0) and (totalHealing / countHealing) or 0
end

local function buildMeterSnapshot()
  wipe(meterSnapshot)
  if not isSortingByMeter() and not isSplittingRaid() then
    return
  end
  if Skada then
    if not Skada.total or not Skada.total.players then
      FixGroups:Print(format("There is currently no data available from %s.", getAddonNameAndVersion("Skada")))
      return
    end
    FixGroups:Print(format("Using damage/healing data from %s.", getAddonNameAndVersion("Skada")))
    -- Skada strips the realm name.
    -- For simplicity's sake, we do not attempt to handle cases where two
    -- players with the same name from different realms are in the same raid.
    local playerKeys = wipe(tmp1)
    local name
    for g = 1, 8 do
      for key, _ in pairs(groups[g]) do
        name = keyGetName(key)
        name = select(1, strsplit("-", name, 2)) or name
        playerKeys[name] = key
      end
    end
    for _, p in pairs(Skada.total.players) do
      if playerKeys[p.name] then
        meterSnapshot[playerKeys[p.name]] = (p.damage or 0) + (p.healing or 0)
      end
    end
  elseif Recount then
    if not Recount.db2 or not Recount.db2.combatants or not Recount.db2.combatants[GetUnitName("player")] then
      FixGroups:Print(format("There is currently no data available from %s.", getAddonNameAndVersion("Recount")))
      return
    end
    FixGroups:Print(format("Using damage/healing data from %s.", getAddonNameAndVersion("Recount")))
    local playerKeys = wipe(tmp1)
    local name, c
    for g = 1, 8 do
      for key, _ in pairs(groups[g]) do
        name = keyGetName(key)
        playerKeys[name] = key
        c = Recount.db2.combatants[name]
        if c and c.Fights and c.Fights.OverallData then
          -- Recount stores healings and absorbs separately internally.
          meterSnapshot[key] = (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
        else
          meterSnapshot[key] = 0
        end
      end
    end
    -- Merge pet data
    for _, c in pairs(Recount.db2.combatants) do
      if c.type == "Pet" and c.Fights and c.Fights.OverallData and c.Owner and playerKeys[c.Owner] then
        meterSnapshot[playerKeys[c.Owner]] = meterSnapshot[playerKeys[c.Owner]] + (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
      end
    end
  elseif Details then
    -- Details excludes certain segments from overall by default (i.e., trash
    -- and earlier bosses). So we fall back to the current segment if there is
    -- no usable overall data.
    local found
    local segments = wipe(tmp1)
    tinsert(segments, "overall")
    tinsert(segments, "current")
    for _, segment in ipairs(segments) do
      if not found and Details.GetActor and (Details:GetActor(segment, 1) or Details:GetActor(segment, 2)) then
        FixGroups:Print(format("Using %s damage/healing data from %s.", segment, getAddonNameAndVersion("Details")))
        found = true
        local name, damage, healing
        for g = 1, 8 do
          for key, _ in pairs(groups[g]) do
            name = keyGetName(key)
            damage = Details:GetActor(segment, 1, name)
            healing = Details:GetActor(segment, 2, name)
            meterSnapshot[key] = (damage and damage.total or 0) + (healing and healing.total or 0)
          end
        end
      end
    end
    if not found then
      FixGroups:Print(format("There is currently no data available from %s.", getAddonNameAndVersion("Details")))
    end
  else
    FixGroups:Print("No supported damage/healing meter addon found.")
  end
  calculateMeterAverages()
end

-- -----------------------------------------------------------------------------
-- Populate delta and action
-- -----------------------------------------------------------------------------

-- The delta table is an array of players who are in the wrong group.
local function buildDelta()
  -- Populate and sort a temporary array of players.
  local players = wipe(tmp1)
  for g = 1, 8 do
    for key, i in pairs(groups[g]) do
      tinsert(players, {key=key, index=i, oldGroup=g})
    end
  end
  if isSortingByMeter() or isSplittingRaid() then
    for _, p in ipairs(players) do
      if keyIsTank(p.key) then
        p.isTank = true
      elseif keyIsHealer(p.key) then
        p.isHealer = true
      end
      p.meter = meterSnapshot[p.key] or meterSnapshot[p.isHealer and "_averageHealing" or "_averageDamage"] or 0
    end 
    sort(players, function(a, b)
      if a.isTank or b.isTank or (a.meter == 0 and b.meter == 0) then
        -- Tanks get a pass, and fall back to default sort if no data.
        return a.key < b.key
      elseif a.isHealer ~= b.isHealer then
        -- Healers get compared to each other, not to dps.
        return b.isHealer and true or false
      end
      return a.meter > b.meter
    end)
  else
    sort(players, function(a, b) return a.key < b.key end)
  end

  -- Determine which group each player needs to be in.
  -- If they're in the wrong group, add them to the delta table.
  wipe(delta)
  local numGroups = floor((groupSizeTotal - 1) / 5) + 1
  if isSplittingRaid() and numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  for i, p in ipairs(players) do
    if isSplittingRaid() then
      if FixGroups.options.splitOddEven then
        -- Assign everyone in the raid to odd/even groups based on their ranking
        -- in the damage/healing meters. This is quick-and-dirty but it gets the
        -- job done. A better algorithm, perhaps for a future version of this
        -- addon, could attempt to balance ranged and melee.
        p.newGroup = floor((i - 1) / 10) * 2 + 1
        if i % 2 == 0 then
          p.newGroup = p.newGroup + 1
        end
      else
        -- Split using adjacent groups (1-2/3-4, 1-3/4-6, or 1-4/5-8) instead
        -- of odd/even.
        p.newGroup = floor((i - 1) / 10) + 1
        if i % 2 == 0 then
          p.newGroup = p.newGroup + floor(numGroups / 2)
        end
      end
    else
      -- Just sorting the raid, not splitting it.
      p.newGroup = floor((i - 1) / 5) + 1
    end
    if p.newGroup ~= p.oldGroup then
      tinsert(delta, p)
    end
  end  
end

local function getSplitGroups()
  local numGroups = floor((groupSizeTotal - 1) / 5) + 1
  if numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  if numGroups < 2 then
    return "1 and 2"
  end
  if FixGroups.options.splitOddEven then
    local split = wipe(tmp1)
    split[1] = wipe(tmp2)
    split[2] = wipe(tmp3)
    for i = 1, numGroups do
      tinsert(split[(i % 2) + 1], tostring(i))
    end
    return tconcat(split[2], "/").." and "..tconcat(split[1], "/")
  else
    numGroups = floor(numGroups / 2)
    return "1-"..numGroups.." and "..(numGroups + 1).."-"..(numGroups * 2)
  end
end

local function isDeltaEmpty()
  return #delta == 0
end

local function cancelAction(reason)
  if action.timer then
    FixGroups:CancelTimer(action.timer)
  end
  wipe(action)
  action.debug = reason or "cancelled"
end

local function startAction(key, group, func, desc)
  cancelAction()
  action.name = keyGetName(key)
  action.group = group
  action.timer = FixGroups:ScheduleTimer(func, ACTION_DELAY_SECONDS)
  action.debug = desc or "<nil>"
end

-- Move the first player in the delta table to their new group.
-- Populate action, which we'll be checking for in a future GROUP_ROSTER_UPDATE.
-- The action table contains the expected results of the WoW API call,
-- either SetRaidSubgroup or SwapRaidSubgroup.
-- We add in a slight delay to the API call to avoid confusing other addons
-- that rely on the GROUP_ROSTER_UPDATE event.
local function processDelta()
  if isDeltaEmpty() then
    cancelAction("done")
    return
  end
  local index = delta[1].index
  local ng = delta[1].newGroup
  action.name = keyGetName(delta[1].key)
  action.group = ng
  -- Simplest case: the new group has room.
  if groupSizes[ng] < 5 then
    startAction(delta[1].key, ng, function () SetRaidSubgroup(index, ng) end, "set "..index.." "..ng)
    return
  end
  -- Else find a partner to swap groups with.
  -- Best case: there is a one-to-one swap possible.
  for d = 2, #delta do
    if delta[d].oldGroup == ng and delta[d].newGroup == delta[1].oldGroup then
      local index2 = delta[d].index
      startAction(delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapO "..index.." "..index2)
      return
    end
  end
  -- Else there is no one-to-one swap possible for this step.
  -- Just put the partner in the wrong group for now.
  -- They'll get sorted correctly on another iteration.
  for d = 2, #delta do
    if delta[d].oldGroup == ng then
      local index2 = delta[d].index
      startAction(delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapX "..index.." "..index2)
      return
    end
  end
  -- Should never get here.
  FixGroups:Print(format("Internal error - unable to find slot for %s!", action.name))
  cancelAction("error")
end

local function didActionFinish()
  if not action.name or not action.group then
    return false
  end
  for key, _ in pairs(groups[action.group]) do
    if keyGetName(key) == action.name then
      return true
    end
  end
  return false
end

-- -----------------------------------------------------------------------------
-- Debug cruft
-- -----------------------------------------------------------------------------

local function debugPrintGroups()
  for g = 1, 8 do
    local line = g.."("..groupSizes[g].."):"
    for key, i in pairs(groups[g]) do
      line = line.." "..i..key
    end
    FixGroups:Debug(line)
  end
end

local function debugPrintMeterSnapshot()
  FixGroups:Debug("meterSnapshot:")
  for k, v in pairs(meterSnapshot) do
    FixGroups:Debug("  "..k..": "..v)
  end
end

local function debugPrintDelta()
  FixGroups:Debug(format("delta=%d players in incorrect groups:", #delta))
  for _, p in ipairs(delta) do
    FixGroups:Debug(p.oldGroup.."/"..p.newGroup.." raid"..p.index.." "..p.key)
  end
end

local function debugPrintAction()
  FixGroups:Debug(format("action: name=%s group=%s debug=%s", (action.name or "<nil>"), (action.group or "<nil>"), (action.debug or "<nil>")))
end

-- -----------------------------------------------------------------------------
-- Addon implementation
-- -----------------------------------------------------------------------------

function FixGroups:IsProcessing()
  return self.run.stepCount and true or false
end

function FixGroups:IsPaused()
  return self.resumeAfterCombat and true or false
end

function FixGroups:StopProcessing()
  cancelAction()
  if self.run.timeoutTimer then
    self:CancelTimer(self.run.timeoutTimer)
  end
  wipe(self.run)
  self:UpdateUI()
end

function FixGroups:StopProcessingTimedOut()
  self:Print("Stopped rearranging players because it's taking too long. Perhaps someone else is simultaneously rearranging players?")
  self:StopProcessing()
end

function FixGroups:StopProcessingNoResume()
  self.resumeAfterCombat = nil
  self:StopProcessing()
end

function FixGroups:PauseIfInCombat()
  if InCombatLockdown() then
    if self.options.resumeAfterCombat then
      self:Print("Rearranging players paused due to combat.")
      self.resumeAfterCombat = self.run.sortMode
    else
      self:Print("Rearranging players cancelled due to combat.")
      self.resumeAfterCombat = nil
    end
    self:StopProcessing()
    return true
  end
end

function FixGroups:ProcessStep()
  if not self:IsLeaderOrAssist() or not IsInRaid() then
    self:Print("You must be a raid leader or assistant to fix groups.")
    self:StopProcessing()
    return
  end
  if self:PauseIfInCombat() then
    return
  end
  if self.run.timeoutTimer then
    self:CancelTimer(self.run.timeoutTimer)
    self.run.timeoutTimer = nil
  end
  if not self:IsProcessing() then
    self.run.stepCount = 0
    self.run.startTime = time()
  end
  --debugPrintGroups()
  buildDelta()
  --debugPrintDelta()
  if isDeltaEmpty() then
    self:AnnounceComplete()
    self:StopProcessing()
    return
  elseif self.run.stepCount > MAX_STEPS then
    self:StopProcessingTimedOut()
    return
  end
  processDelta()
  --debugPrintAction()
  saveGroups()
  if action.name then
    self.run.stepCount = self.run.stepCount + 1
    self.run.timeoutTimer = self:ScheduleTimer("TimedOut", TIMEOUT_SECONDS)
    self:UpdateUI()
  else
    self:StopProcessing()
  end
end

function FixGroups:AnnounceComplete()
  local seconds = floor(time() - self.run.startTime)
  local msg
  if isSplittingRaid() then
    msg = format("Split players: %s.", getSplitGroups())
  elseif isSortingByMeter() then
    msg = "Sorted players by damage/healing done."
  else
    msg = "Rearranged players."
  end
  local msg2 = ""
  if sitting > 0 then
    msg2 = format(" Excluded %d %s sitting in groups %d-8.", sitting, sitting == 1 and "player" or "players", getMaxGroupsForInstance()+1)
  end
  msg = format("%s (%d %s, %d %s.%s)", msg, self.run.stepCount, self.run.stepCount == 1 and "step" or "steps", seconds, seconds == 1 and "second" or "seconds", msg2)
  if self.run.stepCount > 0 and (self.options.announceChatAlways or (self.options.announceChatPRN and self.lastSortMode ~= self.run.sortMode)) then
    SendChatMessage(format("[%s] %s", self.name, msg), self:GetChannel())
  else
    self:Print(msg)
  end
  self.lastSortMode = self.run.sortMode
end

function FixGroups:GetChannel()
  if IsInRaid() then
    return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
  end
  return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
end

-- Timeouts can happen for a variety of reasons.
-- Example: While the raid leader's original request to move a player is en
-- route to the server, that player leaves the group or is moved to a different
-- group by someone else.
-- Another example: Good old-fashioned lag.
function FixGroups:TimedOut()
  self.run.timeoutTimer = nil
  self.run.timeoutCount = (self.run.timeoutCount or 0) + 1
  --self:Debug(format("Timeout %d of %d.", self.run.timeoutCount, MAX_TIMEOUTS)
  if self.run.timeoutCount >= MAX_TIMEOUTS then
    self:StopProcessingTimedOut()
    return
  end
  buildGroups()
  self:ProcessStep()
end

function FixGroups:FixParty()
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
  for i = 1, min(#party, #self.options.partyMarkIcons) do
    mark = self.options.partyMarkIcons[i]
    if mark > 0 and mark <= 8 and GetRaidTargetIndex(party[i].unitID) ~= mark then
      SetRaidTarget(party[i].unitID, mark)
      allMarked = false
    end
  end
  if allMarked then
    -- Clear marks.
    for i = 1, min(#party, #self.options.partyMarkIcons) do
      SetRaidTarget(party[i].unitID, 0)
    end
  end
end

function FixGroups:FixTanksAndMasterLooter(isRequestFromAssist)
  if not self:IsLeaderOrAssist() or not IsInRaid() then
    return
  end
  local marks = wipe(tmp1)
  local unsetTanks = wipe(tmp2)
  local setNonTanks = wipe(tmp3)
  local name, rank, subgroup, rank, online, raidRole, isML, _, unitID, unitRole
  for i = 1, GetNumGroupMembers() do
    name, rank, subgroup, _, _, _, _, online, _, raidRole, isML = GetRaidRosterInfo(i)
    if self:IsLeader() and self.options.fixOfflineML and isML and not online then
      SetLootMethod("master", "player")
    end
    if subgroup >= 1 and subgroup <= getMaxGroupsForInstance() then
      name = name or "Unknown"
      unitID = "raid"..i
      unitRole = UnitGroupRolesAssigned(unitID)
      if IsInRaid() and self:IsLeader() and self.options.tankAssist and (unitRole == "TANK" or isML) and (not rank or rank < 1) then
        PromoteToAssistant(unitID)
      end
      if unitRole == "TANK" then
        tinsert(marks, {key=name, unitID=unitID})
        if raidRole ~= "MAINTANK" then
          -- Can't call protected func: SetPartyAssignment("MAINTANK", unitID)
          tinsert(unsetTanks, name)
        end
      elseif raidRole == "MAINTANK" then
        -- Can't call protected func: SetPartyAssignment(nil, unitID)
        tinsert(setNonTanks, name)
      end
    end
  end
  if isRequestFromAssist then
    return
  elseif not self:IsLeader() and (self.options.fixOfflineML or self.options.tankAssist) then
    -- There is no guarantee that the raid leader is running FixGroups as well
    -- and has the same fixOfflineML/tankAssist options set, but send the
    -- request regardless.
    SendAddonMessage("FIXGROUPS", "ftml", self:GetChannel())
  end
  if self.options.tankMark then
    sort(marks, function(a, b) return a.key < b.key end)
    local mark
    for i = 1, min(#marks, #self.options.tankMarkIcons) do
      mark = self.options.tankMarkIcons[i]
      if mark > 0 and mark <= 8 and GetRaidTargetIndex(marks[i].unitID) ~= mark then
        SetRaidTarget(marks[i].unitID, mark)
      end
    end
  end
  if self.options.tankMainTankAlways or (self.options.tankMainTankPRN and IsInInstance()) then
    local bad
    if #unsetTanks > 0 then
      bad = true
      if #unsetTanks == 1 then
        self:Print(format("|cff1784d1%s|r is not set as main tank!", tconcat2(unsetTanks)))
      else
        self:Print(format("|cff1784d1%s|r are not set as main tanks!", tconcat2(unsetTanks)))
      end
    end
    if #setNonTanks > 0 then
      bad = true
      if #setNonTanks == 1 then
        self:Print(format("|cff1784d1%s|r is incorrectly set as main tank!", tconcat2(setNonTanks)))
      else
        self:Print(format("|cff1784d1%s|r are incorrectly set as main tanks!", tconcat2(setNonTanks)))
      end
    end
    if bad then
      if self.options.openRaidTabPRN or self.options.openRaidTabAlways then
        self:Print("To fix tanks, use the raid tab. WoW addons cannot set main tanks.")
        openRaidTab()
        return
      end
      self:Print("To fix tanks, press O to open the raid tab. WoW addons cannot set main tanks.")
    end
  end
  if self.options.openRaidTabAlways then
    openRaidTab()
  end
end

function FixGroups:PrintHelp()
  self:Print(format("v%s by |cff33ff99%s|r", self.version, GetAddOnMetadata(self.name, "Author")))
  print("Arguments for the |cff1784d1/fixgroups|r command (or |cff1784d1/fg|r):")
  print("  |cff1784d1/fg help|r or |cff1784d1/fg about|r - you're reading it")
  print(format("  |cff1784d1/fg config|r or |cff1784d1/fg options|r - same as Esc>Interface>AddOns>%s", self.name))
  print("  |cff1784d1/fg cancel|r - stop rearranging players")
  print("  |cff1784d1/fg nosort|r - fix groups, no sorting")
  print("  |cff1784d1/fg meter|r or |cff1784d1/fg dps|r - fix groups, sort by overall damage/healing done")
  print("  |cff1784d1/fg split|r - split raid into two sides based on overall damage/healing done")
  print("  |cff1784d1/fg|r - fix groups")
  if self.options.showMinimapIconAlways or self.options.showMinimapIconPRN then
    print("Left click minimap icon to fix groups; right click for config.")
  end
end

function FixGroups:Command(args)
  -- Simple arguments.
  if args == "about" or args == "help" then
    self:PrintHelp()
    return
  elseif args == "config" or args == "options" then
    InterfaceOptionsFrame_OpenToCategory(self.name)
    InterfaceOptionsFrame_OpenToCategory(self.name)
    return
  elseif args == "cancel" then
    self:StopProcessingNoResume()
    return
  end

  -- Okay, we have some actual work to do then.
  self:StopProcessing()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    self:FixParty()
    if args and strmatch(args, " *") and args ~= "nosort" and args ~= "default" then
      self:Print("Groups can only be sorted while in a raid.")
    end
    return
  end
  self:FixTanksAndMasterLooter(false)

  -- Determine sort mode.
  if args == "nosort" then
    return
  elseif args == "meter" or args == "dps" then
    self.run.sortMode = "meter"
  elseif args == "split" then
    self.run.sortMode = "split"
  else
    self.run.sortMode = "default"
    if args ~= "default" and not strmatch(args, " *") then
      self:Print(format("Unknown argument \"%s\". Type |cff1784d1/fg help|r for valid arguments.", args))
    end
    if self.options.sortMode == "nosort" then
      return
    end
  end
  if self:PauseIfInCombat() then
    return
  end

  -- Sort groups.
  buildGroups()
  buildMeterSnapshot()
  --debugPrintMeterSnapshot()
  self:ProcessStep()
end

function FixGroups:OnInitialize()
  self.run = {}
  local function slashCmd(args)
    self:Command(args)
  end
  self:RegisterChatCommand("fixgroups", slashCmd)
  self:RegisterChatCommand("fixgroup", slashCmd)
  self:RegisterChatCommand("fg", slashCmd)
end

function FixGroups:OnEnable()
  self.enabled = true
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
  self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
  self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
  self:RegisterEvent("CHAT_MSG_RAID")
  self:RegisterEvent("CHAT_MSG_RAID_LEADER")
  self:RegisterEvent("CHAT_MSG_SAY")
  self:RegisterEvent("CHAT_MSG_WHISPER")
  self:RegisterEvent("CHAT_MSG_ADDON")
  RegisterAddonMessagePrefix("FIXGROUPS")
  self:SetupDB()
  self:SetupUI()
end

function FixGroups:OnDisable()
  self.enabled = false
  self:StopProcessingNoResume()
  self:CancelAllTimers()
  self:UnregisterAllEvents()
  self:UpdateUI()
end

function FixGroups:PLAYER_REGEN_ENABLED(event)
  if self:IsPaused() then
    self:Print("Resumed rearranging players.")
    local mode = self.resumeAfterCombat 
    self.resumeAfterCombat = nil
    self:Command(mode)
  end
end

function FixGroups:GROUP_ROSTER_UPDATE(event)
  if self:IsProcessing() then
    buildGroups()
    if didActionFinish() then
      self:ProcessStep()
    end
  end
  if not self.broadcastVersionTimer then
    self.broadcastVersionTimer = self:ScheduleTimer("BroadcastVersion", 15)
  end
  self:UpdateUI()
end

function FixGroups:CHAT_MSG_INSTANCE_CHAT(event, message, sender)
  self:ScanForKeywords(message, sender)
end
function FixGroups:CHAT_MSG_INSTANCE_CHAT_LEADER(event, message, sender)
  self:ScanForKeywords(message, sender)
end
function FixGroups:CHAT_MSG_RAID(event, message, sender)
  self:ScanForKeywords(message, sender)
end
function FixGroups:CHAT_MSG_RAID_LEADER(event, message, sender)
  self:ScanForKeywords(message, sender)
end
function FixGroups:CHAT_MSG_SAY(event, message, sender)
  self:ScanForKeywords(message, sender)
end
function FixGroups:CHAT_MSG_WHISPER(event, message, sender)
  self:ScanForKeywords(message, sender)
end

function FixGroups:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  --self:Debug(format("CHAT_MSG_ADDON prefix=%s message=%s channel=%s sender=%s", prefix, message, channel, sender))
  if prefix ~= "FIXGROUPS" or sender == UnitName("player") then
    return
  end
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" and not self.newVersion then
    if message and (message > self.version) then
      self:Print(format("A newer version of %s (%s) is available.", self.name, message))
      self.newVersion = message
    end
  elseif cmd == "ftml" and self:IsLeader() and IsInRaid() and not self:IsProcessing() and sender and UnitIsRaidOfficer(sender) then
    self:FixTanksAndMasterLooter(true)
  end
end

function FixGroups:ScanForKeywords(message, sender)
  if self.options.watchChat and not self:IsProcessing() and not self:IsPaused() and not InCombatLockdown() and IsInRaid() and self:IsLeaderOrAssist() and sender ~= UnitName("player") and message and (strfind(message, "fix group") or strfind(message, "mark tank")) then
    openRaidTab()
    self:FlashRaidTabButton()
  end
end

function FixGroups:BroadcastVersion(event)
  if self.broadcastVersionTimer then
    self:CancelTimer(broadcastVersionTimer)
  end
  self.broadcastVersionTimer = nil
  SendAddonMessage("FIXGROUPS", "v:"..self.version, self:GetChannel())
end

function FixGroups:Print(...)
  print("|cff33ff99"..self.name.."|r:", ...)
end

function FixGroups:Debug(...)
  print("|cff33ff99"..self.name.."|r DEBUG ["..date("%H:%M:%S").."] ", ...)
end
