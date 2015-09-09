local A, L = unpack(select(2, ...))
local M = A:NewModule("sorter", "AceEvent-3.0", "AceTimer-3.0")
A.sorter = M
M.private = {
  active = {sortMode=false, clearGroups=false, skipGroups=false, key=false},
  resumeAfterCombat = {},
  resumeSave = {},
  lastComplete = {},
  announced = false,
  startTime = false,
  stepCount = false,
  timeoutTimer = false,
  timeoutCount = false,
}
local R = M.private

local MAX_STEPS = 30
local MAX_TIMEOUTS = 20
local DELAY_TIMEOUT = 1.0

local floor, format, max, tostring, time, wipe = floor, format, max, tostring, time, wipe
local InCombatLockdown, IsInRaid, SendChatMessage = InCombatLockdown, IsInRaid, SendChatMessage

local function swap(t, k1, k2)
  local tmp = t[k1]
  t[k1] = t[k2]
  t[k2] = tmp
end

function M:OnEnable()
  M:RegisterEvent("PLAYER_ENTERING_WORLD")
  M:RegisterEvent("PLAYER_REGEN_ENABLED")
  M:RegisterMessage("FIXGROUPS_PLAYER_CHANGED_GROUP")
end

function M:PLAYER_ENTERING_WORLD(event)
  wipe(R.lastComplete)
end

function M:PLAYER_REGEN_ENABLED(event)
  M:ResumeIfPaused()
end

function M:FIXGROUPS_PLAYER_CHANGED_GROUP(event, name, prevGroup, group)
  if M:IsProcessing() and A.coreSort:DidActionFinish() then
    M:ProcessStep()
  else
    if A.DEBUG >= 2 then A.console:Debugf(M, "someone else moved %s %d->%d", name, prevGroup, group) end
  end
end

function M:IsSortingHealersBeforeDamagers()
  return A.options.sortMode == "thmr" and R.active.sortMode ~= "tmrh"
end

function M:IsGroupIncluded(group)
  return group > R.active.skipGroups
end

function M:GetGroupOffset()
  return max(R.active.clearGroups, R.active.skipGroups)
end

function M:IsSortingByMeter()
  return R.active.sortMode == "meter"
end

function M:IsSplittingRaid()
  return R.active.sortMode == "split"
end

function M:IsProcessing()
  return R.stepCount and true or false
end

function M:IsPaused()
  return R.resumeAfterCombat.key and true or false
end

function M:GetPausedSortMode()
  return format(L["sorter.print.combatPaused"], L["sorter.mode."..R.resumeAfterCombat.sortMode])
end

function M:CanBegin()
  return not M:IsProcessing() and not M:IsPaused() and not InCombatLockdown() and IsInRaid() and A.util:IsLeaderOrAssist()
end

function M:Stop()
  A.coreSort:CancelAction()
  wipe(R.active)
  wipe(R.resumeAfterCombat)
  M:ClearTimeout(true)
  R.stepCount = false
  R.startTime = false
  A.buttonGui:Refresh()
end

function M:StopTimedOut()
  A.console:Printf(L["sorter.print.timedOut"], L["sorter.mode."..R.active.sortMode])
  if A.DEBUG >= 1 then A.console:Debugf(M, "steps=%d seconds=%.1f timeouts=%d", R.stepCount, (time() - R.startTime), R.timeoutCount) end
  M:Stop()
end

function M:StopIfNeeded()
  if not A.util:IsLeaderOrAssist() or not IsInRaid() then
    A.console:Print(L["sorter.print.needRank"])
    M:Stop()
    return true
  end
  if InCombatLockdown() then
    swap(R, "resumeSave", "active")
    M:Stop()
    if A.options.resumeAfterCombat then
      swap(R, "resumeAfterCombat", "resumeSave")
      A.console:Print(M:GetPausedSortMode())
      A.buttonGui:Refresh()
    else
      A.console:Printf(L["sorter.print.combatCancelled"], L["sorter.mode."..R.resumeSave.sortMode])
    end
    return true
  end
end

local function start(sortMode, clearGroups, skipGroups)
  M:Stop()
  R.active.sortMode = sortMode
  R.active.clearGroups = clearGroups
  R.active.skipGroups = skipGroups
  R.active.key = format("%s:%d:%d", sortMode, clearGroups, skipGroups)
  if M:StopIfNeeded() then
    return
  end
  A.group:PrintIfThereAreUnknowns()
  if M:IsSortingByMeter() or M:IsSplittingRaid() then
    -- Damage/healing meter snapshot is built once at the start,
    -- not once every step.
    A.meter:BuildSnapshot(M:IsSortingByMeter())
  end
  M:ProcessStep()
end

function M:StartMeter()
  start("meter", 0, 0)
end

function M:StartSplit()
  start("split", 0, 0)
end

function M:StartDefault(clearGroups, skipGroups)
  local mode = A.options.sortMode
  if mode == "tmrh" or mode == "thmr" or mode == "meter" or (mode == "nosort" and clearGroups > 0) then
    start(mode, clearGroups, skipGroups)
  else
    M:Stop()
    if mode ~= "nosort" then
      A.console:Errorf(M, "invalid sort mode %s!", tostring(mode))
    end
  end
end

function M:ResumeIfPaused()
  if M:IsPaused() and not InCombatLockdown() then
    swap(R, "resumeSave", "resumeAfterCombat")
    wipe(R.resumeAfterCombat)
    A.console:Printf(L["sorter.print.combatResumed"], L["sorter.mode."..R.resumeSave.sortMode])
    start(R.resumeSave.sortMode, R.resumeSave.clearGroups, R.resumeSave.skipGroups)
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
  if A.DEBUG >= 2 then A.coreSort:DebugPrintAction() end
  if A.coreSort:IsActionScheduled() then
    R.stepCount = R.stepCount + 1
    M:ScheduleTimeout()
    A.buttonGui:Refresh()
  else
    M:Stop()
  end
end

function M:AnnounceComplete()
  if R.lastComplete.key ~= R.active.key then
    R.announced = false
  end
  if R.stepCount == 0 then
    if M:IsSplittingRaid() then
      A.console:Print(L["sorter.print.alreadySplit"])
    else
      A.console:Printf(L["sorter.print.alreadySorted"], L["sorter.mode."..R.active.sortMode])
    end
  else
    -- Announce sort mode.
    local msg
    if M:IsSplittingRaid() then
      msg = format(L["sorter.print.split"], A.coreSort:GetSplitGroups())
    else
      msg = format(L["sorter.print.sorted"], L["sorter.mode."..R.active.sortMode])
    end
    -- Announce group comp.
    msg = format("%s %s: %s.", msg, L["phrase.groupComp"], A.group:GetComp(A.util.GROUP_COMP_STYLE.TEXT_FULL))
    -- Announce who we excluded, if any.
    local sitting = A.group:NumSitting()
    if sitting == 1 then
      msg = msg.." "..format(L["sorter.print.excludedSitting.singular"], A.util:GetMaxGroupsForInstance()+1)
    elseif sitting > 1 then
      msg = msg.." "..format(L["sorter.print.excludedSitting.plural"], sitting, A.util:GetMaxGroupsForInstance()+1)
    end
    -- Announce to group or to self.
    if A.options.announceChatAlways or (A.options.announceChatPRN and not R.announced) then
      SendChatMessage(format("[%s] %s", A.NAME, msg), A.util:GetGroupChannel())
      R.announced = true
    else
      A.console:Print(msg)
    end
    if A.DEBUG >= 1 then A.console:Debugf(M, "steps=%d seconds=%.1f timeouts=%d", R.stepCount, (time() - R.startTime), R.timeoutCount) end
  end
  swap(R, "lastComplete", "active")
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
    if A.DEBUG >= 1 then A.console:Debugf(M, "timeout %d of %d", R.timeoutCount, MAX_TIMEOUTS) end
    if R.timeoutCount >= MAX_TIMEOUTS then
      M:StopTimedOut()
      return
    end
    A.group:ForceBuildRoster(M, "Timeout")
    M:ProcessStep()
  end, DELAY_TIMEOUT)
end
