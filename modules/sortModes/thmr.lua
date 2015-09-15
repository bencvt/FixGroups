--- Tanks > Healers > Melee > Ranged.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("thmr", "AceEvent-3.0")
P.thmr = M

-- Indexes correspond to A.group.ROLE constants (THMRU).
local ROLE_KEY = {1, 4, 2, 3, 3}

local format, sort = format, sort

local function getCompareFunc(players)
  local ra, rb
  return function(a, b)
    ra, rb = ROLE_KEY[players[a].role or 5] or 3, ROLE_KEY[players[b].role or 5] or 3
    if ra == rb then
      return a < b
    end
    return ra < rb
  end
end

function M:OnEnable()
  A.sortModes:Register({
    key = "thmr",
    order = 3010,
    name = L["sorter.mode.thmr"],
    desc = format("%s:|n%s.", L["options.widget.sortMode.text"], L["sorter.mode.thmr"]),
    getCompareFunc = getCompareFunc,
    onSort = function(keys, players)
      sort(keys, getCompareFunc(players))
    end,
  })
end
