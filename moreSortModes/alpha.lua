--- Alphabetic sort.
local A, P, L = unpack(select(2, ...))
local M = P:NewModule("alpha", "AceEvent-3.0")

local sort = sort

function M:OnEnable()
  A.plugins:RegisterSortMode({
    key = "alpha",
    aliases = {"az"},
    name = L["plugin.moreSortModes.alpha"],
    desc = {L["plugin.moreSortModes.note.notUseful"]},
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name < players[b].name
      end)
    end,
  })
  A.plugins:RegisterSortMode({
    key = "ralpha",
    aliases = {"za"},
    name = L["plugin.moreSortModes.ralpha"],
    desc = {L["plugin.moreSortModes.note.notUseful"]},
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name > players[b].name
      end)
    end,
  })
end
