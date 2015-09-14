--- Alphabetic sort. Not a very useful way to organize a raid. Included for
-- the sake of completeness.
local A, P, L = unpack(select(2, ...))
local M = P:NewModule("alpha", "AceEvent-3.0")

local sort = sort

function M:OnEnable()
  A.plugins:RegisterSortMode({
    aliases = {"alpha", "az"},
    name = "by player name A-Z", --TODO localize
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name < players[b].name
      end)
    end,
  })
  A.plugins:RegisterSortMode({
    aliases = {"ralpha", "za"},
    name = "by player name Z-A", --TODO localize
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name > players[b].name
      end)
    end,
  })
end
