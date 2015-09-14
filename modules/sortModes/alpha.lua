--- Alphabetic sort.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("alpha", "AceEvent-3.0")
P.alpha = M

local sort = sort

function M:OnEnable()
  A.sortModes:Register({
    key = "alpha",
    aliases = {"az"},
    order = 5910,
    name = L["plugin.moreSortModes.alpha"],
    desc = {L["plugin.moreSortModes.note.notUseful"]},
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name < players[b].name
      end)
    end,
  })
  A.sortModes:Register({
    key = "ralpha",
    aliases = {"za"},
    order = 5910,
    name = L["plugin.moreSortModes.ralpha"],
    desc = {L["plugin.moreSortModes.note.notUseful"]},
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name > players[b].name
      end)
    end,
  })
end