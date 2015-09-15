--- Tanks > Healers > Melee > Ranged.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("nosort", "AceEvent-3.0")
P.nosort = M

local format, sort = format, sort

function M:OnEnable()
  A.sortModes:Register({
    key = "thmr",
    order = 3900,
    name = L["sorter.mode.nosort"],
    desc = L["gui.fixGroups.help.nosort"],
    onSort = function(keys, players)
      -- Do nothing.
    end,
  })
end
