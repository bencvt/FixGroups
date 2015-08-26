local A, L = unpack(select(2, ...))
local M = A:NewModule("coreSort", "AceTimer-3.0")
A.coreSort = M
M.private = {
  deltaPlayers = {},
  deltaNewGroups = {},
  action = {},
  splitGroups = {{}, {}},
  tmp1 = {},
  tmp2 = {},
}
local R = M.private

local DELAY_ACTION = 0.01
-- ROLE_SORT_CHAR_x indexes correspond to A.group.ROLES constants.
local ROLE_SORT_CHAR_TMURH = {"a", "d", "b", "c", "c"}
local ROLE_SORT_CHAR_THMUR = {"a", "b", "c", "d", "d"}
local CLASS_SORT_CHAR = {}
for i, class in ipairs(CLASS_SORT_ORDER) do
  CLASS_SORT_CHAR[class] = string.char(64 + i)
end
CLASS_SORT_CHAR["_unknown"] = "Z"

local format, floor, ipairs, pairs, sort, tinsert, tostring, wipe = format, floor, ipairs, pairs, sort, tinsert, tostring, wipe
local tconcat = table.concat
local SetRaidSubgroup, SwapRaidSubgroup = SetRaidSubgroup, SwapRaidSubgroup

-- The delta table is an array of players who are in the wrong group.
function M:BuildDelta()
  -- Build temporary tables tracking players.
  local sortRoles = A.sorter:IsSortingHealersBeforeDamagers() and ROLE_SORT_CHAR_THMUR or ROLE_SORT_CHAR_TMURH
  local keys = wipe(R.tmp1)
  local playersByKey = wipe(R.tmp2)
  local k
  for name, p in pairs(A.group:GetRoster()) do
    if not p.isSitting then
      k = sortRoles[p.role]..(p.class and CLASS_SORT_CHAR[p.class] or CLASS_SORT_CHAR["_unknown"])..(p.isUnknown and ("_"..name) or name)
      tinsert(keys, k)
      playersByKey[k] = p
    end
  end

  -- Sort keys.
  -- TODO: potential hook for plugins that want to implement a custom sort mode.
  if A.sorter:IsSortingByMeter() or A.sorter:IsSplittingRaid() then
    local TANK, HEALER = A.group.ROLES.TANK, A.group.ROLES.HEALER
    local pa, pb
    sort(keys, function(a, b)
      pa, pb = playersByKey[a], playersByKey[b]
      if pa.role ~= pb.role then
        if pa.role == HEALER or pb.role == HEALER or pa.role == TANK or pb.role == TANK then
          -- Tanks and healers are in their own brackets.
          return a < b
        end
      end
      pa, pb = A.meter:GetPlayerMeter(pa.name), A.meter:GetPlayerMeter(pb.name)
      if pa == pb then
        -- Tie, or no data. Fall back to default sort.
        return a < b
      end
      return pa > pb
    end)
  else
    sort(keys)
  end

  -- Determine which group each player needs to be in.
  -- If they're in the wrong group, add them to the delta tables.
  wipe(R.deltaPlayers)
  wipe(R.deltaNewGroups)
  local numGroups = floor((A.group:GetSize() - A.group:NumSitting() - 1) / 5) + 1
  if A.sorter:IsSplittingRaid() and numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  local newGroup
  for i, k in ipairs(keys) do
    if A.sorter:IsSplittingRaid() then
      if A.options.splitOddEven then
        -- Assign everyone in the raid to odd/even groups based on their ranking
        -- in the damage/healing meters. This is quick-and-dirty but it gets the
        -- job done. A better algorithm, perhaps for a future version of this
        -- addon, could attempt to balance ranged and melee.
        newGroup = floor((i - 1) / 10) * 2 + 1
        if i % 2 == 0 then
          newGroup = newGroup + 1
        end
      else
        -- Split using adjacent groups (1-2/3-4, 1-3/4-6, or 1-4/5-8) instead
        -- of odd/even.
        newGroup = floor((i - 1) / 10) + 1
        if i % 2 == 0 then
          newGroup = newGroup + floor(numGroups / 2)
        end
      end
    else
      -- Just sorting the raid, not splitting it.
      newGroup = floor((i - 1) / 5) + 1
    end
    if newGroup ~= playersByKey[k].group then
      tinsert(R.deltaPlayers, playersByKey[k])
      tinsert(R.deltaNewGroups, newGroup)
    end
  end

  if A.DEBUG >= 2 then M:DebugPrintDelta() end
end

function M:GetSplitGroups()
  local numGroups = floor((A.group:GetSize() - A.group:NumSitting() - 1) / 5) + 1
  if numGroups % 2 == 1 then
    numGroups = numGroups + 1
  end
  if numGroups < 2 then
    return "1 "..L["word.and"].." 2"
  end
  if A.options.splitOddEven then
    wipe(R.splitGroups[1])
    wipe(R.splitGroups[2])
    for i = 1, numGroups do
      tinsert(R.splitGroups[(i % 2) + 1], tostring(i))
    end
    return tconcat(R.splitGroups[2], "/").." "..L["word.and"].." "..tconcat(R.splitGroups[1], "/")
  else
    numGroups = floor(numGroups / 2)
    return "1-"..numGroups.." "..L["word.and"].." "..(numGroups + 1).."-"..(numGroups * 2)
  end
end

function M:IsDeltaEmpty()
  return #R.deltaPlayers == 0
end

function M:CancelAction()
  if R.action.timer then
    M:CancelTimer(R.action.timer)
  end
  wipe(R.action)
end

local function startAction(name, newGroup, func, desc)
  M:CancelAction()
  R.action.name = name
  R.action.newGroup = newGroup
  R.action.timer = M:ScheduleTimer(func, DELAY_ACTION)
  R.action.desc = desc
end

-- Move the first player in the delta tables to their new group.
-- Populate action, which we'll be checking for in a future GROUP_ROSTER_UPDATE.
-- The action table contains the expected results of the WoW API call,
-- either SetRaidSubgroup or SwapRaidSubgroup.
-- We add in a slight delay to the API call to avoid confusing other addons
-- that rely on the GROUP_ROSTER_UPDATE event.
function M:ProcessDelta()
  M:CancelAction()
  if M:IsDeltaEmpty() then
    return
  end
  local rindex = R.deltaPlayers[1].rindex
  local newGroup = R.deltaNewGroups[1]
  local name = R.deltaPlayers[1].name
  -- Simplest case: the new group has room.
  if A.group:GetGroupSize(newGroup) < 5 then
    startAction(name, newGroup, function () SetRaidSubgroup(rindex, newGroup) end, "set "..rindex.." "..newGroup)
    return
  end
  -- Else find a partner to swap groups with.
  -- Best case: there is a one-to-one swap possible.
  for d = 2, #R.deltaPlayers do
    if R.deltaPlayers[d].group == newGroup and R.deltaNewGroups[d] == R.deltaPlayers[1].group then
      local rindex2 = R.deltaPlayers[d].rindex
      startAction(name, newGroup, function () SwapRaidSubgroup(rindex, rindex2) end, "swap "..rindex.." "..rindex2)
      return
    end
  end
  -- Else there is no one-to-one swap possible for this step.
  -- Just put the partner in the wrong group for now.
  -- They'll get sorted correctly on another iteration.
  for d = 2, #R.deltaPlayers do
    if R.deltaPlayers[d].group == newGroup then
      local rindex2 = R.deltaPlayers[d].rindex
      startAction(name, newGroup, function () SwapRaidSubgroup(rindex, rindex2) end, "swapX "..rindex.." "..rindex2)
      return
    end
  end
  -- Should never get here.
  A.console:Errorf(M, "unable to find slot for %s!", R.action.name)
end

function M:IsActionScheduled()
  return R.action.name and true or false
end

function M:DidActionFinish()
  if R.action.name and R.action.newGroup then
    local p = A.group:GetPlayer(R.action.name)
    return p and (p.group == R.action.newGroup)
  end
end

function M:DebugPrintDelta()
  A.console:Debugf(M, "delta=%d players in incorrect groups:", #R.deltaPlayers)
  if #R.deltaPlayers > 1 then
    local p
    for i = 1, #R.deltaPlayers do
      p = R.deltaPlayers[i]
      A.console:DebugMore(M, format("  %d: group=%d newGroup=%d rindex=%d name=%s", i, p.group, R.deltaNewGroups[i], p.rindex, p.name))
    end
  end
end

function M:DebugPrintAction()
  A.console:Debugf(M, "action: %s to %s: %s", (R.action.name or "<nil>"), (R.action.newGroup or "<nil>"), (R.action.desc or "<nil>"))
end
