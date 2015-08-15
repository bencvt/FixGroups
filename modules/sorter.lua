local A, L = unpack(select(2, ...))
local M = A:NewModule("sorter", "AceEvent-3.0", "AceTimer-3.0")
A.sorter = M
M.private = {
  sortMode = false,
  lastSortMode = false,
  resumeAfterCombat = false,
  startTime = false,
  stepCount = false,
  timeoutTimer = false,
  timeoutCount = false,
}
local R = M.private

local MAX_STEPS = 30
local MAX_TIMEOUTS = 20
local DELAY_TIMEOUT = 1.0

local floor, format, time = math.floor, string.format, time
local InCombatLockdown, IsInRaid, SendChatMessage = InCombatLockdown, IsInRaid, SendChatMessage

function M:OnEnable()
  M:RegisterEvent("PLAYER_ENTERING_WORLD")
  M:RegisterEvent("PLAYER_REGEN_ENABLED")
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function M:PLAYER_ENTERING_WORLD(event)
  R.lastSortMode = false
end

function M:PLAYER_REGEN_ENABLED(event)
  M:ResumeIfPaused()
end

function M:GROUP_ROSTER_UPDATE(event)
  if M:IsProcessing() then
    A.sorterCore:BuildGroups()
    if A.sorterCore:DidActionFinish() then
      M:ProcessStep()
    end
  end
end

function M:IsSortingTHMUR()
  return R.sortMode == "THMUR"
end

function M:IsSortingByMeter()
  return R.sortMode == "meter"
end

function M:IsSplittingRaid()
  return R.sortMode == "split"
end

function M:IsProcessing()
  return R.stepCount and true or false
end

function M:IsPaused()
  return R.resumeAfterCombat and true or false
end

function M:CanBegin()
  return not M:IsProcessing() and not M:IsPaused() and not InCombatLockdown() and IsInRaid() and A.util:IsLeaderOrAssist()
end

function M:Stop()
  A.sorterCore:CancelAction()
  M:ClearTimeout(true)
  R.stepCount = false
  R.startTime = false
  R.sortMode = false
  R.resumeAfterCombat = false
  A.gui:Refresh()
end

function M:StopTimedOut()
  A.console:Print(L["sorter.print.timedOut"])
  M:Stop()
end

function M:StopIfNeeded()
  if not A.util:IsLeaderOrAssist() or not IsInRaid() then
    A.console:Print(L["sorter.print.needRank"])
    M:Stop()
    return true
  end
  if InCombatLockdown() then
    local resumeSortMode = R.sortMode
    M:Stop()
    if A.options.resumeAfterCombat then
      A.console:Print(L["sorter.print.combatPaused"])
      R.resumeAfterCombat = resumeSortMode
      A.gui:Refresh()
    else
      A.console:Print(L["sorter.print.combatCancelled"])
    end
    return true
  end
end

local function start(mode)
  M:Stop()
  R.sortMode = mode
  if M:StopIfNeeded() then
    return
  end
  -- Groups are built prior to every step.
  A.sorterCore:BuildGroups()
  if M:IsSortingByMeter() or M:IsSplittingRaid() then
    -- Damage/healing meter snapshot is built once at the start,
    -- not once every step.
    A.meter:BuildSnapshot()
  end
  M:ProcessStep()
end

function M:StartMeter()
  start("meter")
end

function M:StartSplit()
  start("split")
end

function M:StartDefault()
  local m = A.options.sortMode
  if m == "TMURH" or m == "THMUR" or m == "meter" then
    start(m)
  else
    M:Stop()
    if m ~= "nosort" then
      A.console:Print(format("Internal error: invalid sort mode %s.", tostring(m or "<nil>")))
    end
  end
end

function M:ResumeIfPaused()
  if M:IsPaused() and not InCombatLockdown() then
    A.console:Print(L["sorter.print.combatResumed"])
    local mode = R.resumeAfterCombat 
    R.resumeAfterCombat = false
    start(mode)
  end
end

function M:ProcessStep()
  if M:StopIfNeeded() then
    return
  end
  M:ClearTimeout(false)
  if not M:IsProcessing() then
    R.stepCount = 0
    R.startTime = time()
  end
  --A.sorterCore:DebugPrintGroups()
  A.sorterCore:BuildDelta()
  --A.sorterCore:DebugPrintDelta()
  if A.sorterCore:IsDeltaEmpty() then
    M:AnnounceComplete()
    M:Stop()
    return
  elseif R.stepCount > MAX_STEPS then
    M:StopTimedOut()
    return
  end
  A.sorterCore:ProcessDelta()
  --A.sorterCore:DebugPrintAction()
  if A.sorterCore:IsActionScheduled() then
    R.stepCount = R.stepCount + 1
    M:ScheduleTimeout()
    A.gui:Refresh()
  else
    M:Stop()
  end
end

function M:AnnounceComplete()
  if R.stepCount == 0 then
    if M:IsSplittingRaid() then
      A.console:Print(L["sorter.print.alreadySplit"])
    else
      A.console:Print(L["sorter.print.alreadySorted"])
    end
  else
    local msg
    if M:IsSplittingRaid() then
      msg = format(L["sorter.print.split"], A.sorterCore:GetSplitGroups())
    else
      msg = L["sorter.print."..R.sortMode]
    end
    local sitting = A.sorterCore:NumSitting()
    if sitting > 0 then
      msg = msg.." "..format(L["sorter.print.excludedSitting"], sitting, sitting == 1 and L["word.player"] or L["word.players"], A.util:GetMaxGroupsForInstance()+1)
    end
    if A.options.announceChatAlways or (A.options.announceChatPRN and R.lastSortMode ~= R.sortMode) then
      SendChatMessage(format("[%s] %s", A.name, msg), A.util:GetGroupChannel())
    else
      A.console:Print(msg)
    end
    --A.console:Debug(format("steps=%d seconds=%.1f timeouts=%d", R.stepCount, (time() - R.startTime), R.timeoutCount))
  end
  R.lastSortMode = R.sortMode
end

function M:ClearTimeout(resetCount)
  if R.timeoutTimer then
    M:CancelTimer(R.timeoutTimer)
  end
  R.timeoutTimer = false
  if resetCount then
    R.timeoutCount = false
  end
end

-- Timeouts can happen for a variety of reasons.
-- Example: While the raid leader's original request to move a player is en
-- route to the server, that player leaves the group or is moved to a different
-- group by someone else.
-- Another example: Good old-fashioned lag.
function M:ScheduleTimeout()
  M:ClearTimeout(false)
  R.timeoutTimer = M:ScheduleTimer(function ()
    M:ClearTimeout(false)
    R.timeoutCount = (R.timeoutCount or 0) + 1
    --A.console:Debug(format("Timeout %d of %d.", R.timeoutCount, MAX_TIMEOUTS))
    if R.timeoutCount >= MAX_TIMEOUTS then
      M:StopTimedOut()
      return
    end
    A.sorterCore:BuildGroups()
    M:ProcessStep()
  end, DELAY_TIMEOUT)
end
