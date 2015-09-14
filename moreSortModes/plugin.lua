local pluginName, pluginTable = ...
local A = FixGroups
A[pluginName] = LibStub("AceAddon-3.0"):NewAddon(pluginName)
pluginTable[1] = A
pluginTable[2] = A[pluginName]
pluginTable[3] = A.L
