--- Alphabetic sort.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("alpha", "AceEvent-3.0")
P.alpha = M

local sort = sort

function M:OnEnable()
  A.sortModes:Register({
    key = "alpha",
    name = L["sorter.mode.alpha"],
    aliases = {"az"},
    isExtra = true,
    desc = L["sorter.print.notUseful"],
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name < players[b].name
      end)
    end,
  })
  A.sortModes:Register({
    key = "ralpha",
    name = L["sorter.mode.ralpha"],
    aliases = {"za"},
    isExtra = true,
    desc = L["sorter.print.notUseful"],
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name > players[b].name
      end)
    end,
  })
end
