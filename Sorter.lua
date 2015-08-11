local A, L = unpack(select(2, ...))
local M = A:NewModule("Sorter")
A.sorter = M

local MAX_STEPS = 30
local MAX_TIMEOUTS = 20
local TIMEOUT_SECONDS = 1.0

local floor, format, time = math.floor, string.format, time

function M:IsSortingByMeter()
  return A.options.sortMode == "meter" or M.sortMode == "meter"
end

function M:IsSplittingRaid()
  return M.sortMode == "split"
end

function M:IsProcessing()
  return M.stepCount and true or false
end

function M:IsPaused()
  return M.resumeAfterCombat and true or false
end

function M:StopProcessing()
  M.core:CancelAction()
  if M.timeoutTimer then
    A:CancelTimer(M.timeoutTimer)
    M.timeoutTimer = nil
  end
  M.stepCount = nil
  M.startTime = nil
  M.sortMode = nil
  A.gui:Refresh()
end

function M:StopProcessingTimedOut()
  A.console:Print("Stopped rearranging players because it's taking too long. Perhaps someone else is simultaneously rearranging players?")
  M:StopProcessing()
end

function M:StopProcessingNoResume()
  M.resumeAfterCombat = nil
  M:StopProcessing()
end

function M:PauseIfInCombat()
  if InCombatLockdown() then
    if A.options.resumeAfterCombat then
      A.console:Print("Rearranging players paused due to combat.")
      M.resumeAfterCombat = M.sortMode
    else
      A.console:Print("Rearranging players cancelled due to combat.")
      M.resumeAfterCombat = nil
    end
    M:StopProcessing()
    return true
  end
end

function M:ProcessStep()
  if not A.util:IsLeaderOrAssist() or not IsInRaid() then
    A.console:Print("You must be a raid leader or assistant to fix groups.")
    M:StopProcessing()
    return
  end
  if M:PauseIfInCombat() then
    return
  end
  if M.timeoutTimer then
    A:CancelTimer(M.timeoutTimer)
    M.timeoutTimer = nil
  end
  if not M:IsProcessing() then
    M.stepCount = 0
    M.startTime = time()
  end
  --A.console:DebugPrintGroups()
  M.core:BuildDelta()
  --A.console:DebugPrintDelta()
  if M.core:IsDeltaEmpty() then
    M:AnnounceComplete()
    M:StopProcessing()
    return
  elseif M.stepCount > MAX_STEPS then
    M:StopProcessingTimedOut()
    return
  end
  M.core:ProcessDelta()
  --A.console:DebugPrintAction()
  M.core:SaveGroups()
  if M.core:IsActionScheduled() then
    M.stepCount = M.stepCount + 1
    M:ScheduleTimeout()
    A.gui:Refresh()
  else
    M:StopProcessing()
  end
end

function M:AnnounceComplete()
  local seconds = floor(time() - M.startTime)
  local msg
  if M:IsSplittingRaid() then
    msg = format("Split players: groups %s.", M.core:GetSplitGroups())
  elseif M:IsSortingByMeter() then
    msg = "Sorted players by damage/healing done."
  else
    msg = "Rearranged players."
  end
  local msg2 = ""
  if M.core.sitting > 0 then
    msg2 = format(" Excluded %d %s sitting in groups %d-8.", M.core.sitting, M.core.sitting == 1 and "player" or "players", A.util:GetMaxGroupsForInstance()+1)
  end
  msg = format("%s (%d %s, %d %s.%s)", msg, M.stepCount, M.stepCount == 1 and "step" or "steps", seconds, seconds == 1 and "second" or "seconds", msg2)
  if M.stepCount > 0 and (A.options.announceChatAlways or (A.options.announceChatPRN and M.lastSortMode ~= M.sortMode)) then
    SendChatMessage(format("[%s] %s", A.name, msg), A.util:GetChannel())
  else
    A.console:Print(msg)
  end
  M.lastSortMode = M.sortMode
end

-- Timeouts can happen for a variety of reasons.
-- Example: While the raid leader's original request to move a player is en
-- route to the server, that player leaves the group or is moved to a different
-- group by someone else.
-- Another example: Good old-fashioned lag.
function M:ScheduleTimeout()
  if M.timeoutTimer then
    A:CancelTimer(M.timeoutTimer)
  end
  M.timeoutTimer = A:ScheduleTimer(function ()
    M.timeoutTimer = nil
    M.timeoutCount = (M.timeoutCount or 0) + 1
    --A.console:Debug(format("Timeout %d of %d.", M.timeoutCount, MAX_TIMEOUTS)
    if M.timeoutCount >= MAX_TIMEOUTS then
      M:StopProcessingTimedOut()
      return
    end
    M.core:BuildGroups()
    M:ProcessStep()
  end, TIMEOUT_SECONDS)
end

function M:GROUP_ROSTER_UPDATE(event)
  if M:IsProcessing() then
    M.core:BuildGroups()
    if M.core:DidActionFinish() then
      M:ProcessStep()
    end
  end
end
