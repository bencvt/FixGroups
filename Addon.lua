local addonName, addonTable = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceTimer-3.0")
A.name = addonName
A.version = GetAddOnMetadata(addonName, "Version")
A.author = GetAddOnMetadata(addonName, "Author")
local L = LibStub("AceLocale-3.0"):GetLocale(A.name)
addonTable[1] = A
addonTable[2] = L
_G[addonName] = addonTable

function A:OnDisable()
  A:CancelAllTimers()
end
