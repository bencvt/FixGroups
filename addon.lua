local addonName, addonTable = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName)
A.NAME = addonName
A.VERSION = GetAddOnMetadata(A.NAME, "Version")
A.AUTHOR = GetAddOnMetadata(A.NAME, "Author")
A.DEBUG = 0 -- 0=off 1=on 2=verbose
A.DEBUG_MODULES = "*"  -- use comma-separated module names to filter
local L = LibStub("AceLocale-3.0"):GetLocale(A.NAME)
addonTable[1] = A
addonTable[2] = L
_G[addonName] = addonTable
