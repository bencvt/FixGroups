local A, L = unpack(select(2, ...))
local M = A.sorter:NewModule("SorterCore")
A.sorter.core = M

local ACTION_DELAY_SECONDS = 0.1
local SR_TANK, SR_MELEE, SR_UNKNOWN, SR_RANGED, SR_HEALER = 1, 2, 3, 4, 5
local SORT_ROLES_TMURH = {"a", "b", "c", "d", "e"}
local SORT_ROLES_THMUR = {"a", "c", "d", "e", "b"}

M.sortRoles = SORT_ROLES_TMURH
M.prevGroups = {{}, {}, {}, {}, {}, {}, {}, {}}
M.groups = {{}, {}, {}, {}, {}, {}, {}, {}}
M.groupSizes = {0, 0, 0, 0, 0, 0, 0, 0}
M.groupSizeTotal = 0
M.sitting = 0
M.delta = {}
M.action = {}

local tmp1, tmp2, tmp3 = {}, {}, {}
local floor, format, ipairs, pairs, sort, strsub, tconcat, tinsert, wipe = math.floor, string.format, ipairs, pairs, sort, string.sub, table.concat, table.insert, wipe

function M:SaveGroups()
  local tmp = M.prevGroups
  M.prevGroups = M.groups
  M.groups = tmp -- will get wiped on next use
end

function M:AreGroupsDifferent()
  for g = 1, 8 do
    -- For each group, only compare keys (i.e., role+class+name).
    -- Changes in the unitID (raid1, raid2, etc.) are irrelevant.
    for key, _ in pairs(M.prevGroups[g]) do
      if not M.groups[g][key] then
        return true
      end
    end
    for key, _ in pairs(M.groups[g]) do
      if not M.prevGroups[g][key] then
        return true
      end
    end
  end
  return false
end

function M:KeyGetName(key)
  return strsub(key, 3)
end

function M:KeyIsTank(key)
  return strsub(key, 1, 1) == M.sortRoles[SR_TANK]
end

function M:KeyIsHealer(key)
  return strsub(key, 1, 1) == M.sortRoles[SR_HEALER]
end

function M:KeyIsDps(key)
  local role = strsub(key, 1, 1)
  return role == M.sortRoles[SR_MELEE] or role == M.sortRoles[SR_UNKNOWN] or role == M.sortRoles[SR_RANGED]
end

function M:BuildGroups()
  M.sortRoles = (A.sorter.sortMode == "THMUR") and SORT_ROLES_THMUR or SORT_ROLES_TMURH
  for g = 1, 8 do
    wipe(M.groups[g])
    M.groupSizes[g] = 0
  end
  M.groupSizeTotal = 0
  M.sitting = 0

  local name, subgroup, class, unitRole, _
  for i = 1, GetNumGroupMembers() do
    name, _, subgroup, _, _, class = GetRaidRosterInfo(i)
    if subgroup > A.util:GetMaxGroupsForInstance() then
      M.sitting = M.sitting + 1
    elseif subgroup >= 1 then
      unitRole = UnitGroupRolesAssigned("raid"..i)
      if unitRole == "TANK" then
        -- We don't care what class the tanks are.
        class = M.sortRoles[SR_TANK].."1"
      elseif unitRole == "HEALER" then
        if     class == "PALADIN"      then class = M.sortRoles[SR_HEALER].."1"
        elseif class == "MONK"         then class = M.sortRoles[SR_HEALER].."2"
        elseif class == "DRUID"        then class = M.sortRoles[SR_HEALER].."3"
        elseif class == "SHAMAN"       then class = M.sortRoles[SR_HEALER].."4"
        elseif class == "PRIEST"       then class = M.sortRoles[SR_HEALER].."5"
        else                                class = M.sortRoles[SR_HEALER].."9"
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
        if     class == "ROGUE"        then class = M.sortRoles[SR_MELEE].."1"
        elseif class == "PALADIN"      then class = M.sortRoles[SR_MELEE].."2"
        elseif class == "MONK"         then class = M.sortRoles[SR_MELEE].."3"
        elseif class == "WARRIOR"      then class = M.sortRoles[SR_MELEE].."4"
        elseif class == "DEATHKNIGHT"  then class = M.sortRoles[SR_MELEE].."5"
        elseif class == "DEMONHUNTER"  then class = M.sortRoles[SR_MELEE].."6"
        elseif class == "DRUID"        then class = M.sortRoles[SR_UNKNOWN].."1"
        elseif class == "SHAMAN"       then class = M.sortRoles[SR_UNKNOWN].."2"
        elseif class == "PRIEST"       then class = M.sortRoles[SR_RANGED].."1"
        elseif class == "HUNTER"       then class = M.sortRoles[SR_RANGED].."2"
        elseif class == "MAGE"         then class = M.sortRoles[SR_RANGED].."3"
        elseif class == "WARLOCK"      then class = M.sortRoles[SR_RANGED].."4"
        else                                class = M.sortRoles[SR_UNKNOWN].."9"
        end
      end
      M.groups[subgroup][class..(name or "Unknown")] = i
      M.groupSizes[subgroup] = M.groupSizes[subgroup] + 1
      M.groupSizeTotal = M.groupSizeTotal + 1
    end
  end
end

-- The delta table is an array of players who are in the wrong group.
function M:BuildDelta()
  -- Populate and sort a temporary array of players.
  local players = wipe(tmp1)
  for g = 1, 8 do
    for key, i in pairs(M.groups[g]) do
      tinsert(players, {key=key, index=i, oldGroup=g})
    end
  end
  if A.sorter:IsSortingByMeter() or A.sorter:IsSplittingRaid() then
    for _, p in ipairs(players) do
      if M:KeyIsTank(p.key) then
        p.isTank = true
      elseif M:KeyIsHealer(p.key) then
        p.isHealer = true
      end
      p.meter = A.sorter.meter.snapshot[p.key] or A.sorter.meter.snapshot[p.isHealer and "_averageHealing" or "_averageDamage"] or 0
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
  wipe(M.delta)
  local numGroups = floor((M.groupSizeTotal - 1) / 5) + 1
  if A.sorter:IsSplittingRaid() and numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  for i, p in ipairs(players) do
    if A.sorter:IsSplittingRaid() then
      if A.options.splitOddEven then
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
      tinsert(M.delta, p)
    end
  end  
end

function M:GetSplitGroups()
  local numGroups = floor((M.groupSizeTotal - 1) / 5) + 1
  if numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  if numGroups < 2 then
    return "1 "..L["and"].." 2"
  end
  if A.options.splitOddEven then
    local split = wipe(tmp1)
    split[1] = wipe(tmp2)
    split[2] = wipe(tmp3)
    for i = 1, numGroups do
      tinsert(split[(i % 2) + 1], tostring(i))
    end
    return tconcat(split[2], "/").." "..L["and"].." "..tconcat(split[1], "/")
  else
    numGroups = floor(numGroups / 2)
    return "1-"..numGroups.." "..L["and"].." "..(numGroups + 1).."-"..(numGroups * 2)
  end
end

function M:IsDeltaEmpty()
  return #M.delta == 0
end

function M:CancelAction(reason)
  if M.action.timer then
    A:CancelTimer(M.action.timer)
  end
  wipe(M.action)
  M.action.debug = reason or "cancelled"
end

function M:StartAction(key, group, func, desc)
  M:CancelAction()
  M.action.name = M:KeyGetName(key)
  M.action.group = group
  M.action.timer = A:ScheduleTimer(func, ACTION_DELAY_SECONDS)
  M.action.debug = desc or "<nil>"
end

-- Move the first player in the delta table to their new group.
-- Populate action, which we'll be checking for in a future GROUP_ROSTER_UPDATE.
-- The action table contains the expected results of the WoW API call,
-- either SetRaidSubgroup or SwapRaidSubgroup.
-- We add in a slight delay to the API call to avoid confusing other addons
-- that rely on the GROUP_ROSTER_UPDATE event.
function M:ProcessDelta()
  if M:IsDeltaEmpty() then
    M:CancelAction("done")
    return
  end
  local index = M.delta[1].index
  local ng = M.delta[1].newGroup
  M.action.name = M:KeyGetName(M.delta[1].key)
  M.action.group = ng
  -- Simplest case: the new group has room.
  if M.groupSizes[ng] < 5 then
    M:StartAction(M.delta[1].key, ng, function () SetRaidSubgroup(index, ng) end, "set "..index.." "..ng)
    return
  end
  -- Else find a partner to swap groups with.
  -- Best case: there is a one-to-one swap possible.
  for d = 2, #M.delta do
    if M.delta[d].oldGroup == ng and M.delta[d].newGroup == M.delta[1].oldGroup then
      local index2 = M.delta[d].index
      M:StartAction(M.delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapO "..index.." "..index2)
      return
    end
  end
  -- Else there is no one-to-one swap possible for this step.
  -- Just put the partner in the wrong group for now.
  -- They'll get sorted correctly on another iteration.
  for d = 2, #M.delta do
    if M.delta[d].oldGroup == ng then
      local index2 = M.delta[d].index
      M:StartAction(M.delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapX "..index.." "..index2)
      return
    end
  end
  -- Should never get here.
  A.console:Print(format("Internal error - unable to find slot for %s!", M.action.name))
  M:CancelAction("error")
end

function M:IsActionScheduled()
  return M.action.name and true or false
end

function M:DidActionFinish()
  if not M.action.name or not M.action.group then
    return false
  end
  for key, _ in pairs(M.groups[M.action.group]) do
    if M:KeyGetName(key) == M.action.name then
      return true
    end
  end
  return false
end
