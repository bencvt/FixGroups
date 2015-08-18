local addonName, addonTable = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName)
A.name = addonName
A.version = GetAddOnMetadata(addonName, "Version")
A.author = GetAddOnMetadata(addonName, "Author")
A.debug = 0 -- 0=off 1=on 2=verbose
A.debugModules = "*"  -- use comma-separated module names to filter
local L = LibStub("AceLocale-3.0"):GetLocale(A.name)
addonTable[1] = A
addonTable[2] = L
_G[addonName] = addonTable
