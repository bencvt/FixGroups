--- Tanks > Melee > Ranged > Healers.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("tmrh", "AceEvent-3.0")
P.tmrh = M

-- Indexes correspond to A.group.ROLE constants (THMRU).
local ROLE_KEY = {1, 2, 3, 4, 4}

local format, sort = format, sort

local function getCompareFunc(players)
  local ra, rb
  return function(a, b)
    ra, rb = ROLE_KEY[players[a].role or 5] or 4, ROLE_KEY[players[b].role or 5] or 4
    if ra == rb then
      return a < b
    end
    return ra < rb
  end
end

function M:OnEnable()
  A.sortModes:Register({
    key = "tmrh",
    order = 3000,
    name = L["sorter.mode.tmrh"],
    desc = format("%s:|n%s.", L["options.widget.sortMode.text"], L["sorter.mode.tmrh"]),
    getCompareFunc = getCompareFunc,
    onSort = function(keys, players)
      sort(keys, getCompareFunc(players))
    end,
  })
end
