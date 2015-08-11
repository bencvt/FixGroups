local addonName, addonTable = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0")
A.name = addonName
A.version = GetAddOnMetadata(addonName, "Version")
A.author = GetAddOnMetadata(addonName, "Author")
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
end

function A:OnDisable()
  A:CancelAllTimers()
  A:UnregisterAllEvents()
end

function A:PLAYER_ENTERING_WORLD(event)
  A.sorter:PLAYER_ENTERING_WORLD(event)
  A.gui:Refresh()
end

function A:PLAYER_REGEN_ENABLED(event)
  A.sorter:ResumeIfPaused()
end

function A:GROUP_ROSTER_UPDATE(event)
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
