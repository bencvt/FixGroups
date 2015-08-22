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

local floor, format, tostring, time = math.floor, string.format, tostring, time
local InCombatLockdown, IsInRaid, SendChatMessage = InCombatLockdown, IsInRaid, SendChatMessage

function M:OnEnable()
  M:RegisterEvent("PLAYER_ENTERING_WORLD")
  M:RegisterEvent("PLAYER_REGEN_ENABLED")
  M:RegisterMessage("FIXGROUPS_RAID_GROUP_CHANGED")
end

function M:PLAYER_ENTERING_WORLD(event)
  R.lastSortMode = false
end

function M:PLAYER_REGEN_ENABLED(event)
  M:ResumeIfPaused()
end

function M:FIXGROUPS_RAID_GROUP_CHANGED(event, name, prevGroup, group)
  if M:IsProcessing() and A.coreSort:DidActionFinish() then
    M:ProcessStep()
  else
    if A.debug >= 2 then A.console:Debugf(M, "someone else moved %s %d->%d", name, prevGroup, group) end
  end
end

function M:IsSortingHealersBeforeDamagers()
  return A.options.sortMode == "THMUR" and R.sortMode ~= "TMURH"
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
  A.coreSort:CancelAction()
  M:ClearTimeout(true)
  R.stepCount = false
  R.startTime = false
  R.sortMode = false
  R.resumeAfterCombat = false
  A.gui:Refresh()
end

function M:StopTimedOut()
  A.console:Print(L["sorter.print.timedOut"])
  if A.debug >= 1 then A.console:Debugf(M, "steps=%d seconds=%.1f timeouts=%d", R.stepCount, (time() - R.startTime), R.timeoutCount) end
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
  local mode = A.options.sortMode
  if mode == "TMURH" or mode == "THMUR" or mode == "meter" then
    start(mode)
  else
    M:Stop()
    if mode ~= "nosort" then
      A.console:Errorf(M, "invalid sort mode %s!", tostring(mode or "<nil>"))
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
  A.coreSort:BuildDelta()
  if A.coreSort:IsDeltaEmpty() then
    M:AnnounceComplete()
    M:Stop()
    return
  elseif R.stepCount > MAX_STEPS then
    M:StopTimedOut()
    return
  end
  A.coreSort:ProcessDelta()
  if A.debug >= 2 then A.coreSort:DebugPrintAction() end
  if A.coreSort:IsActionScheduled() then
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
      msg = format(L["sorter.print.split"], A.coreSort:GetSplitGroups())
    else
      msg = L["sorter.print."..R.sortMode]
    end
    local sitting = A.raid:NumSitting()
    if sitting == 1 then
      msg = msg.." "..format(L["sorter.print.excludedSitting.singular"], A.util:GetMaxGroupsForInstance()+1)
    elseif sitting > 1 then
      msg = msg.." "..format(L["sorter.print.excludedSitting.plural"], sitting, A.util:GetMaxGroupsForInstance()+1)
    end
    if A.options.announceChatAlways or (A.options.announceChatPRN and R.lastSortMode ~= R.sortMode) then
      SendChatMessage(format("[%s] %s", A.name, msg), A.util:GetGroupChannel())
    else
      A.console:Print(msg)
    end
    if A.debug >= 1 then A.console:Debugf(M, "steps=%d seconds=%.1f timeouts=%d", R.stepCount, (time() - R.startTime), R.timeoutCount) end
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
    if A.debug >= 1 then A.console:Debugf(M, "timeout %d of %d", R.timeoutCount, MAX_TIMEOUTS) end
    if R.timeoutCount >= MAX_TIMEOUTS then
      M:StopTimedOut()
      return
    end
    A.raid:ForceBuildRoster()
    M:ProcessStep()
  end, DELAY_TIMEOUT)
end
