local A, L = unpack(select(2, ...))
local M = A:NewModule("inspect", "AceEvent-3.0", "AceTimer-3.0")
A.inspect = M
M.private = {
  requests = {},
  timer = false,
  lastNotifyTime = 0,
}
local R = M.private

local DELAY_TIMER = 16.0
local DELAY_NOTIFY = 1.0
local DELAY_INSPECT_NEXT = 0.01

local format, ipairs, pairs, select, time = format, ipairs, pairs, select, time
local CanInspect, GetPlayerInfoByGUID, InCombatLockdown, NotifyInspect, UnitExists, UnitIsConnected = CanInspect, GetPlayerInfoByGUID, InCombatLockdown, NotifyInspect, UnitExists, UnitIsConnected

function M:OnEnable()
  M:RegisterEvent("INSPECT_READY")
  M:RegisterEvent("PLAYER_REGEN_ENABLED")
end

local function inspectTimerStop(reason)
  if R.timer then
    M:CancelTimer(R.timer)
    if A.debug >= 1 then A.console:Debugf(M, "timer stop %s", reason) end
  end
  R.timer = false
end

local function inspectTimerTick()
  if InCombatLockdown() then
    inspectTimerStop("combat")
    return
  end
  local now = time()
  local count = 0
  local notifySent
  for name, _ in pairs(R.requests) do
    if not UnitExists(name) then
      R.requests[name] = nil
      if A.debug >= 2 then A.console:Debugf(M, "queue remove non-existent %s", name) end
    else
      count = count + 1
      if not notifySent and (now > R.lastNotifyTime + DELAY_NOTIFY) and CanInspect(name) and UnitIsConnected(name) and A.raid:IsInSameZone(name) then
        notifySent = true
        R.lastNotifyTime = now
        NotifyInspect(name)
        if A.debug >= 1 then A.console:Debugf(M, "send %s", name) end
      end
    end
  end
  if count == 0 then
    inspectTimerStop("empty")
  elseif not notifySent then
    if A.debug >= 2 then A.console:Debugf(M, "waiting count=%d", count) end
  end
end

local function inspectTimerStart()
  inspectTimerStop("sanity check")
  R.timer = M:ScheduleRepeatingTimer(inspectTimerTick, DELAY_TIMER)
  if A.debug >= 1 then A.console:Debug(M, "timer start") end
  inspectTimerTick()
end

function M:INSPECT_READY(event, guid)
  local name, realm = select(6, GetPlayerInfoByGUID(guid))
  if not name then
    return
  end
  if realm then
    name = name.."-"..realm
  end
  if A.debug >= 1 and R.requests[name] then A.console:Debugf(M, "recv %s", name) end
  R.requests[name] = nil
  if not InCombatLockdown() then
    -- Use a short delay to allow other modules and addons a chance to
    -- process the INSPECT_READY event.
    M:ScheduleTimer(function () inspectTimerTick() end, DELAY_INSPECT_NEXT)
  end
end

function M:PLAYER_REGEN_ENABLED(event)
  inspectTimerStart()
end

function M:Request(name)
  if A.debug >= 1 then A.console:Debugf(M, "queue %s %s", (R.requests[name] and "update" or "add"), name) end
  R.requests[name] = true
  if not InCombatLockdown() and not R.timer then
    inspectTimerStart()
  end
end

function M:DebugPrintRequests()
  local line = ""
  local count = 0
  for _, k in ipairs(A.util:SortedKeys(R.requests)) do
    line = line.." "..k
    count = count + 1
  end
  A.console:Debugf(M, "request count=%d names:%s", count, line)
end
