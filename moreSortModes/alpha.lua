--- Alphabetic sort.
local A, P, L = unpack(select(2, ...))
local M = P:NewModule("alpha", "AceEvent-3.0")

function M:OnEnable()
  --TODO localize
  A.plugins:RegisterSortMode({"alpha", "az"}, "by player name A-Z", nil, function(keys, players)
    sort(keys, function(a, b)
      return players[a].name < players[b].name
    end)
  end)
  A.plugins:RegisterSortMode({"ralpha", "za"}, "by player name Z-A", nil, function(keys, players)
    sort(keys, function(a, b)
      return players[a].name > players[b].name
    end)
  end)
end
