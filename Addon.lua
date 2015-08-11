local addonName, addonTable = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
A.name = addonName
A.version = GetAddOnMetadata(addonName, "Version")
A.author = GetAddOnMetadata(addonName, "Author")
A.addonChannelPrefix = "FIXGROUPS"
local L = LibStub("AceLocale-3.0"):GetLocale(A.name)
addonTable[1] = A
addonTable[2] = L
_G[addonName] = addonTable

local strfind, strsplit = string.find, strsplit
local InCombatLockdown, IsInRaid, UnitName = InCombatLockdown, IsInRaid, UnitName

function A:OnEnable()
	A:RegisterEvent("PLAYER_ENTERING_WORLD")
	A:RegisterEvent("PLAYER_REGEN_ENABLED")
	A:RegisterEvent("GROUP_ROSTER_UPDATE")
  A:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
  A:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
  A:RegisterEvent("CHAT_MSG_RAID")
  A:RegisterEvent("CHAT_MSG_RAID_LEADER")
  A:RegisterEvent("CHAT_MSG_SAY")
  A:RegisterEvent("CHAT_MSG_WHISPER")
  A:RegisterEvent("CHAT_MSG_ADDON")
  RegisterAddonMessagePrefix("FIXGROUPS")
end

function A:OnDisable()
  A:CancelAllTimers()
  A:UnregisterAllEvents()
end

function A:PLAYER_ENTERING_WORLD(event)
  A.sorter.lastSortMode = nil
  A.gui:Refresh()
end

function A:PLAYER_REGEN_ENABLED(event)
  A.sorter:ResumeIfPaused()
end

function A:GROUP_ROSTER_UPDATE(event)
  if not A.broadcastVersionTimer then
    A.broadcastVersionTimer = A:ScheduleTimer("BroadcastVersion", 15)
  end
  A.sorter:GROUP_ROSTER_UPDATE(event)
  A.gui:Refresh()
end

function A:CHAT_MSG_INSTANCE_CHAT(event, message, sender)
  A:ScanForKeywords(message, sender)
end
function A:CHAT_MSG_INSTANCE_CHAT_LEADER(event, message, sender)
  A:ScanForKeywords(message, sender)
end
function A:CHAT_MSG_RAID(event, message, sender)
  A:ScanForKeywords(message, sender)
end
function A:CHAT_MSG_RAID_LEADER(event, message, sender)
  A:ScanForKeywords(message, sender)
end
function A:CHAT_MSG_SAY(event, message, sender)
  A:ScanForKeywords(message, sender)
end
function A:CHAT_MSG_WHISPER(event, message, sender)
  A:ScanForKeywords(message, sender)
end

function A:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  --A.console:Debug(format("CHAT_MSG_ADDON prefix=%s message=%s channel=%s sender=%s", prefix, message, channel, sender))
  if prefix ~= A.addonChannelPrefix or sender == UnitName("player") then
    return
  end
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" and not A.newVersion then
    if message and (message > A.version) then
      A.console:Print(format(L["A newer version of %s (%s) is available."], A.name, message))
      A.newVersion = message
    end
  elseif cmd == "f" and A.util:IsLeader() and IsInRaid() and not A.sorter:IsProcessing() and sender and UnitIsRaidOfficer(sender) then
    A.marker:FixRaid(true)
  end
end

function A:BroadcastAddonMessage(message)
  SendAddonMessage(A.addonChannelPrefix, message, A.util:GetChannel())
end

function A:BroadcastVersion(event)
  if A.broadcastVersionTimer then
    A:CancelTimer(broadcastVersionTimer)
  end
  A.broadcastVersionTimer = nil
  A:BroadcastAddonMessage("v:"..A.version)
end

function A:ScanForKeywords(message, sender)
  if A.options.watchChat and not A.sorter:IsProcessing() and not A.sorter:IsPaused() and not InCombatLockdown() then
    if IsInRaid() and A.util:IsLeaderOrAssist() and sender ~= UnitName("player") and message then
      -- Search for both the default and the localized keywords.
      if strfind(message, "fix group") or strfind(message, "mark tank") or strfind(message, L["fix group"]) or strfind(message, L["mark tank"]) then
        A.gui:OpenRaidTab()
        A.gui:FlashRaidTabButton()
      end
    end
  end
end
