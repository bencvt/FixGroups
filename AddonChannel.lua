local A, L = unpack(select(2, ...))
local M = A:NewModule("AddonChannel", "AceEvent-3.0")
A.addonChannel = M

M.addonChannelPrefix = "FIXGROUPS"

function M:OnEnable()
  M:RegisterEvent("CHAT_MSG_ADDON")
  M:RegisterEvent("GROUP_ROSTER_UPDATE")
  RegisterAddonMessagePrefix(M.addonChannelPrefix)
end

function M:OnDisable()
  M:UnregisterAllEvents()
end

function M:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  --A.console:Debug(format("CHAT_MSG_ADDON prefix=%s message=%s channel=%s sender=%s", prefix, message, channel, sender))
  if prefix ~= M.addonChannelPrefix or sender == UnitName("player") then
    return
  end
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" and not M.newerVersion then
    if message and (message > A.version) then
      A.console:Print(format(L["A newer version of %s (%s) is available."], A.name, message))
      M.newerVersion = message
    end
  elseif cmd == "f" and A.util:IsLeader() and IsInRaid() and not A.sorter:IsProcessing() and sender and UnitIsRaidOfficer(sender) then
    A.marker:FixRaid(true)
  end
end

function M:GROUP_ROSTER_UPDATE(event)
  if not M.broadcastVersionTimer then
    M.broadcastVersionTimer = M:ScheduleTimer(function ()
      if M.broadcastVersionTimer then
        A:CancelTimer(M.broadcastVersionTimer)
      end
      M.broadcastVersionTimer = nil
      M:Broadcast("v:"..A.version)
    end, 15)
  end
end

function M:Broadcast(message)
  SendAddonMessage(M.addonChannelPrefix, message, A.util:GetGroupChannel())
end
