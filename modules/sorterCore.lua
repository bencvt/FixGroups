local A, L = unpack(select(2, ...))
local M = A:NewModule("sorterCore", "AceTimer-3.0")
A.sorterCore = M
M.private = {
  sortRoles = false,
  groups = {{}, {}, {}, {}, {}, {}, {}, {}},
  groupSizes = {0, 0, 0, 0, 0, 0, 0, 0},
  groupSizeTotal = 0,
  sitting = 0,
  delta = {},
  action = {},
  tmp1 = {},
  tmp2 = {},
  tmp3 = {},
}
local R = M.private

local DELAY_ACTION = 0.1
local SR_TANK, SR_MELEE, SR_UNKNOWN, SR_RANGED, SR_HEALER = 1, 2, 3, 4, 5
local SORT_ROLES_TMURH = {"a", "b", "c", "d", "e"}
local SORT_ROLES_THMUR = {"a", "c", "d", "e", "b"}

local floor, format, ipairs, pairs, sort, strsub, tconcat, tinsert, wipe = math.floor, string.format, ipairs, pairs, sort, string.sub, table.concat, table.insert, wipe

function M:GetGroup(g)
  return R.groups[g]
end

function M:KeyGetName(key)
  return strsub(key, 3)
end

function M:KeyIsTank(key)
  return strsub(key, 1, 1) == R.sortRoles[SR_TANK]
end

function M:KeyIsHealer(key)
  return strsub(key, 1, 1) == R.sortRoles[SR_HEALER]
end

function M:KeyIsDps(key)
  local role = strsub(key, 1, 1)
  return role == R.sortRoles[SR_MELEE] or role == R.sortRoles[SR_UNKNOWN] or role == R.sortRoles[SR_RANGED]
end

function M:BuildGroups()
  R.sortRoles = A.sorter:IsSortingTHMUR() and SORT_ROLES_THMUR or SORT_ROLES_TMURH
  for g = 1, 8 do
    wipe(R.groups[g])
    R.groupSizes[g] = 0
  end
  R.groupSizeTotal = 0
  R.sitting = 0

  local name, subgroup, class, unitRole, _
  for i = 1, GetNumGroupMembers() do
    name, _, subgroup, _, _, class = GetRaidRosterInfo(i)
    if subgroup > A.util:GetMaxGroupsForInstance() then
      R.sitting = R.sitting + 1
    elseif subgroup >= 1 then
      unitRole = UnitGroupRolesAssigned("raid"..i)
      if unitRole == "TANK" then
        -- We don't care what class the tanks are.
        class = R.sortRoles[SR_TANK].."1"
      elseif unitRole == "HEALER" then
        if     class == "PALADIN"      then class = R.sortRoles[SR_HEALER].."1"
        elseif class == "MONK"         then class = R.sortRoles[SR_HEALER].."2"
        elseif class == "DRUID"        then class = R.sortRoles[SR_HEALER].."3"
        elseif class == "SHAMAN"       then class = R.sortRoles[SR_HEALER].."4"
        elseif class == "PRIEST"       then class = R.sortRoles[SR_HEALER].."5"
        else                                class = R.sortRoles[SR_HEALER].."9"
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
        if     class == "ROGUE"        then class = R.sortRoles[SR_MELEE].."1"
        elseif class == "PALADIN"      then class = R.sortRoles[SR_MELEE].."2"
        elseif class == "MONK"         then class = R.sortRoles[SR_MELEE].."3"
        elseif class == "WARRIOR"      then class = R.sortRoles[SR_MELEE].."4"
        elseif class == "DEATHKNIGHT"  then class = R.sortRoles[SR_MELEE].."5"
        elseif class == "DEMONHUNTER"  then class = R.sortRoles[SR_MELEE].."6"
        elseif class == "DRUID"        then class = R.sortRoles[SR_UNKNOWN].."1"
        elseif class == "SHAMAN"       then class = R.sortRoles[SR_UNKNOWN].."2"
        elseif class == "PRIEST"       then class = R.sortRoles[SR_RANGED].."1"
        elseif class == "HUNTER"       then class = R.sortRoles[SR_RANGED].."2"
        elseif class == "MAGE"         then class = R.sortRoles[SR_RANGED].."3"
        elseif class == "WARLOCK"      then class = R.sortRoles[SR_RANGED].."4"
        else                                class = R.sortRoles[SR_UNKNOWN].."9"
        end
      end
      R.groups[subgroup][class..(name or "Unknown")] = i
      R.groupSizes[subgroup] = R.groupSizes[subgroup] + 1
      R.groupSizeTotal = R.groupSizeTotal + 1
    end
  end
end

-- The delta table is an array of players who are in the wrong group.
function M:BuildDelta()
  -- Populate and sort a temporary array of players.
  local players = wipe(R.tmp1)
  for g = 1, 8 do
    for key, i in pairs(R.groups[g]) do
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
      p.meter = A.meter:GetPlayerMeter(p.key)
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
  wipe(R.delta)
  local numGroups = floor((R.groupSizeTotal - 1) / 5) + 1
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
      tinsert(R.delta, p)
    end
  end  
end

function M:GetSplitGroups()
  local numGroups = floor((R.groupSizeTotal - 1) / 5) + 1
  if numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  if numGroups < 2 then
    return "1 "..L["word.and"].." 2"
  end
  if A.options.splitOddEven then
    local split = wipe(R.tmp1)
    split[1] = wipe(R.tmp2)
    split[2] = wipe(R.tmp3)
    for i = 1, numGroups do
      tinsert(split[(i % 2) + 1], tostring(i))
    end
    return tconcat(split[2], "/").." "..L["word.and"].." "..tconcat(split[1], "/")
  else
    numGroups = floor(numGroups / 2)
    return "1-"..numGroups.." "..L["word.and"].." "..(numGroups + 1).."-"..(numGroups * 2)
  end
end

function M:IsDeltaEmpty()
  return #R.delta == 0
end

function M:NumSitting()
  return R.sitting
end

function M:CancelAction(reason)
  if R.action.timer then
    M:CancelTimer(R.action.timer)
  end
  wipe(R.action)
  R.action.debug = reason or "cancelled"
end

function M:StartAction(key, group, func, desc)
  M:CancelAction()
  R.action.name = M:KeyGetName(key)
  R.action.group = group
  R.action.timer = M:ScheduleTimer(func, DELAY_ACTION)
  R.action.debug = desc or "<nil>"
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
  local index = R.delta[1].index
  local ng = R.delta[1].newGroup
  R.action.name = M:KeyGetName(R.delta[1].key)
  R.action.group = ng
  -- Simplest case: the new group has room.
  if R.groupSizes[ng] < 5 then
    M:StartAction(R.delta[1].key, ng, function () SetRaidSubgroup(index, ng) end, "set "..index.." "..ng)
    return
  end
  -- Else find a partner to swap groups with.
  -- Best case: there is a one-to-one swap possible.
  for d = 2, #R.delta do
    if R.delta[d].oldGroup == ng and R.delta[d].newGroup == R.delta[1].oldGroup then
      local index2 = R.delta[d].index
      M:StartAction(R.delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapO "..index.." "..index2)
      return
    end
  end
  -- Else there is no one-to-one swap possible for this step.
  -- Just put the partner in the wrong group for now.
  -- They'll get sorted correctly on another iteration.
  for d = 2, #R.delta do
    if R.delta[d].oldGroup == ng then
      local index2 = R.delta[d].index
      M:StartAction(R.delta[1].key, ng, function () SwapRaidSubgroup(index, index2) end, "swapX "..index.." "..index2)
      return
    end
  end
  -- Should never get here.
  A.console:Print(format("Internal error - unable to find slot for %s!", R.action.name))
  M:CancelAction("error")
end

function M:IsActionScheduled()
  return R.action.name and true or false
end

function M:DidActionFinish()
  if not R.action.name or not R.action.group then
    return false
  end
  for key, _ in pairs(R.groups[R.action.group]) do
    if M:KeyGetName(key) == R.action.name then
      return true
    end
  end
  return false
end

function M:DebugPrintGroups()
  for g = 1, 8 do
    local line = g.."("..R.groupSizes[g].."):"
    for key, i in pairs(R.groups[g]) do
      line = line.." "..i.."="..key
    end
    A.console:Debug(line)
  end
end

function M:DebugPrintDelta()
  A.console:Debug(format("delta=%d players in incorrect groups:", #R.delta))
  for _, p in ipairs(R.delta) do
    A.console:Debug(p.oldGroup.."/"..p.newGroup.." raid"..p.index.." "..p.key)
  end
end

function M:DebugPrintAction()
  A.console:Debug(format("action: name=%s group=%s debug=%s", (R.action.name or "<nil>"), (R.action.group or "<nil>"), (R.action.debug or "<nil>")))
end
