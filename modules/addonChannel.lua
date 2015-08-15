local A, L = unpack(select(2, ...))
local M = A:NewModule("addonChannel", "AceEvent-3.0", "AceTimer-3.0")
A.addonChannel = M
M.private = {
  broadcastVersionTimer = false,
  newerVersion = false,
}
local R = M.private

local strsplit = string.split
local IsInGroup, SendAddonMessage, UnitName = IsInGroup, SendAddonMessage, UnitName

local PREFIX = "FIXGROUPS"

function M:OnEnable()
  M:RegisterEvent("CHAT_MSG_ADDON")
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
  RegisterAddonMessagePrefix(PREFIX)
end

function M:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  if prefix ~= PREFIX then
    return
  end
  --A.console:Debug(format("CHAT_MSG_ADDON prefix=%s message=%s channel=%s sender=%s|r", prefix, message, channel, sender))
  if sender == UnitName("player") then
    return
  end
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" and not R.newerVersion then
    if message and (message > A.version) then
      A.console:Print(format(L["addonChannel.print.newerVersion"], A.name, "|cff1784d1"..message.."|r", A.version))
      R.newerVersion = message
    end
  elseif cmd == "f" and A.util:IsLeader() and IsInRaid() and not A.sorter:IsProcessing() and sender and UnitIsRaidOfficer(sender) then
    A.marker:FixRaid(true)
  end
end

function M:GROUP_ROSTER_UPDATE(event)
  if not R.broadcastVersionTimer then
    R.broadcastVersionTimer = M:ScheduleTimer(function ()
      if R.broadcastVersionTimer then
        M:CancelTimer(R.broadcastVersionTimer)
      end
      R.broadcastVersionTimer = false
      M:Broadcast("v:"..A.version)
    end, 15)
  end
end

function M:Broadcast(message)
  if IsInGroup() then
    SendAddonMessage(PREFIX, message, A.util:GetGroupChannel())
  end
end
