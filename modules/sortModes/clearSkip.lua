--- Tanks > Healers > Melee > Ranged.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("clearSkip", "AceEvent-3.0")
P.clearSkip = M

local format = format

local function getDescFunc(key)
  return function(t)
    t:AddLine(L["gui.fixGroups.help."..key], 1,1,0, true)
    t:AddLine(" ")
    t:AddLine(L["gui.fixGroups.help.sort"], 1,1,0, true)
    t:AddLine(" ")
    t:AddLine(format(L["gui.fixGroups.help.note.defaultMode"], A.util:Highlight(A.sortModes:GetDefault().name)), 1,1,1, true)
    t:AddLine(" ")
    t:AddLine(L["gui.fixGroups.help.note.clearSkip"], 1,1,1, true)
  end
end

function M:OnEnable()
  A.sortModes:Register({
    key = "clear1",
    aliases = {"c1"},
    order = 2001,
    name = L["sorter.mode.clear1"],
    desc = getDescFunc("clear1"),
    groupOffset = 1,
  })
  A.sortModes:Register({
    key = "clear2",
    aliases = {"c2"},
    order = 2002,
    name = L["sorter.mode.clear2"],
    desc = getDescFunc("clear2"),
    groupOffset = 2,
  })
  A.sortModes:Register({
    key = "skip1",
    aliases = {"s1"},
    order = 2101,
    name = L["sorter.mode.skip1"],
    desc = getDescFunc("skip1"),
    groupOffset = 1,
    skipFirstGroups = 1,
  })
  A.sortModes:Register({
    key = "skip2",
    aliases = {"s2"},
    order = 2102,
    name = L["sorter.mode.skip2"],
    desc = getDescFunc("skip2"),
    groupOffset = 2,
    skipFirstGroups = 2,
  })
end
