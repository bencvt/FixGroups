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
    desc = function(t)
      t:AddLine(format("%s:|n%s.", L["tooltip.right.fixGroups"], L["sorter.mode.alpha"]), 1,1,0, true)
      t:AddLine(" ")
      t:AddLine(L["sorter.print.notUseful"], 1,1,1, true)
    end,
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
    desc = function(t)
      t:AddLine(format("%s:|n%s.", L["tooltip.right.fixGroups"], L["sorter.mode.ralpha"]), 1,1,0, true)
      t:AddLine(" ")
      t:AddLine(L["sorter.print.notUseful"], 1,1,1, true)
    end,
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return players[a].name > players[b].name
      end)
    end,
  })
end
