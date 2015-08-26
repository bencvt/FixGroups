local A, L = unpack(select(2, ...))
local M = A:NewModule("addonChannel", "AceEvent-3.0", "AceTimer-3.0")
A.addonChannel = M
M.private = {
  broadcastVersionTimer = false,
  newerVersion = false,
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

local strsplit = strsplit
local IsInGroup, IsInRaid, RegisterAddonMessagePrefix, SendAddonMessage, UnitExists, UnitIsRaidOfficer, UnitName = IsInGroup, IsInRaid, RegisterAddonMessagePrefix, SendAddonMessage, UnitExists, UnitIsRaidOfficer, UnitName

local PREFIX = "FIXGROUPS"
local DELAY_BROADCAST_VERSION = 15.5

function M:OnEnable()
  M:RegisterEvent("CHAT_MSG_ADDON")
  M:RegisterMessage("FIXGROUPS_PLAYER_JOINED")
  RegisterAddonMessagePrefix(PREFIX)
end

function M:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  if prefix ~= PREFIX or not sender then
    return
  end
  if not UnitExists(sender) then
    sender = A.util:StripRealm(sender)
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "%sCHAT_MSG_ADDON prefix=%s message=%s channel=%s sender=%s", ((sender ~= UnitName("player")) and "|r" or ""), prefix, message, channel, sender) end
  if sender == UnitName("player") then
    return
  end
  local cmd
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" and not R.newerVersion then
    if message and (message > A.VERSION) then
      A.console:Printf(L["addonChannel.print.newerVersion"], A.NAME, H(A.util:Escape(message)), A.VERSION)
      R.newerVersion = message
    end
  elseif cmd == "f" and A.util:IsLeader() and IsInRaid() and not A.sorter:IsProcessing() and UnitIsRaidOfficer(sender) then
    A.marker:FixRaid(true)
  end
end

function M:FIXGROUPS_PLAYER_JOINED(event, player)
  if not R.broadcastVersionTimer then
    R.broadcastVersionTimer = M:ScheduleTimer(function ()
      if R.broadcastVersionTimer then
        M:CancelTimer(R.broadcastVersionTimer)
      end
      R.broadcastVersionTimer = false
      M:Broadcast("v:"..A.VERSION)
    end, DELAY_BROADCAST_VERSION)
  end
end

function M:Broadcast(message)
  if IsInGroup() then
    SendAddonMessage(PREFIX, message, A.util:GetGroupChannel())
  end
end
