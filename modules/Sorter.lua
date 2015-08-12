local A, L = unpack(select(2, ...))
local M = A:NewModule("Sorter", "AceEvent-3.0", "AceTimer-3.0")
A.sorter = M

local MAX_STEPS = 30
local MAX_TIMEOUTS = 20
local TIMEOUT_SECONDS = 1.0

local floor, format, time = math.floor, string.format, time

function M:OnEnable()
  M:RegisterEvent("PLAYER_ENTERING_WORLD")
  M:RegisterEvent("PLAYER_REGEN_ENABLED")
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function M:PLAYER_ENTERING_WORLD(event)
  M.lastSortMode = nil
end

function M:PLAYER_REGEN_ENABLED(event)
  M:ResumeIfPaused()
end

function M:GROUP_ROSTER_UPDATE(event)
  if M:IsProcessing() then
    M.core:BuildGroups()
    if M.core:DidActionFinish() then
      M:ProcessStep()
    end
  end
end

function M:IsProcessing()
  return M.stepCount and true or false
end

function M:IsPaused()
  return M.resumeAfterCombat and true or false
end

function M:StopProcessing()
  M.core:CancelAction()
  M:ClearTimeout(true)
  M.stepCount = nil
  M.startTime = nil
  M.sortMode = nil
  A.gui:Refresh()
end

function M:StopProcessingTimedOut()
  A.console:Print(L["Stopped rearranging players because it's taking too long. Perhaps someone else is simultaneously rearranging players?"])
  M:StopProcessing()
end

function M:StopProcessingNoResume()
  M.resumeAfterCombat = nil
  M:StopProcessing()
end

function M:StopProcessingIfNeeded()
  if not A.util:IsLeaderOrAssist() or not IsInRaid() then
    A.console:Print(L["You must be a raid leader or assistant to fix groups."])
    M:StopProcessingNoResume()
    return true
  end
  if InCombatLockdown() then
    if A.options.resumeAfterCombat then
      A.console:Print(L["Rearranging players paused due to combat."])
      M.resumeAfterCombat = M.sortMode
    else
      A.console:Print(L["Rearranging players cancelled due to combat."])
      M.resumeAfterCombat = nil
    end
    M:StopProcessing()
    return true
  end
end

function M:IsSortingByMeter()
  return M.sortMode == "meter"
end

function M:IsSplittingRaid()
  return M.sortMode == "split"
end

local function beginSort(mode)
  M:StopProcessingNoResume()
  M.sortMode = mode
  if M:StopProcessingIfNeeded() then
    return
  end
  -- Groups are built every step.
  M.core:BuildGroups()
  if M:IsSortingByMeter() or M:IsSplittingRaid() then
    -- Damage/healing meter snapshot is built once at the beginning,
    -- not once every step.
    M.meter:BuildSnapshot()
  end
  M:ProcessStep()
end

function M:BeginMeter()
  beginSort("meter")
end

function M:BeginSplit()
  beginSort("split")
end

function M:BeginDefault()
  local m = A.options.sortMode
  if m == "TMURH" or m == "THMUR" or m == "meter" then
    beginSort(m)
  else
    M:StopProcessingNoResume()
    if m ~= "nosort" then
      A.console:Print(format("Internal error: invalid sort mode %s.", tostring(m or "<nil>")))
    end
  end
end

function M:ResumeIfPaused()
  if M:IsPaused() and not InCombatLockdown() then
    A.console:Print(L["Resumed rearranging players."])
    local mode = M.resumeAfterCombat 
    M.resumeAfterCombat = nil
    beginSort(mode)
  end
end

function M:ProcessStep()
  if M:StopProcessingIfNeeded() then
    return
  end
  M:ClearTimeout(false)
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
    msg = format(L["sortMode.split"], M.core:GetSplitGroups())
  else
    msg = L["sortMode."..M.sortMode]
  end
  local msg2 = ""
  if M.core.sitting > 0 then
    msg2 = " "..format(L["Excluded %d %s sitting in groups %d-8."], M.core.sitting, M.core.sitting == 1 and L["player"] or L["players"], A.util:GetMaxGroupsForInstance()+1)
  end
  msg = format("%s (%d %s, %d %s.%s)", msg, M.stepCount, M.stepCount == 1 and L["step"] or L["steps"], seconds, seconds == 1 and L["second"] or L["seconds"], msg2)
  if M.stepCount > 0 and (A.options.announceChatAlways or (A.options.announceChatPRN and M.lastSortMode ~= M.sortMode)) then
    SendChatMessage(format("[%s] %s", A.name, msg), A.util:GetGroupChannel())
  else
    A.console:Print(msg)
  end
  M.lastSortMode = M.sortMode
end

function M:ClearTimeout(resetCount)
  if M.timeoutTimer then
    M:CancelTimer(M.timeoutTimer)
  end
  M.timeoutTimer = nil
  if resetCount then
    M.timeoutCount = nil
  end
end

-- Timeouts can happen for a variety of reasons.
-- Example: While the raid leader's original request to move a player is en
-- route to the server, that player leaves the group or is moved to a different
-- group by someone else.
-- Another example: Good old-fashioned lag.
function M:ScheduleTimeout()
  M:ClearTimeout(false)
  M.timeoutTimer = M:ScheduleTimer(function ()
    M:ClearTimeout(false)
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
