--- Tanks > Melee > Ranged > Healers.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("tmrh", "AceEvent-3.0")
P.tmrh = M

-- Indexes correspond to A.group.ROLE constants (THMRU).
local ROLE_KEY = {1, 4, 2, 3, 3}
local PADDING_PLAYER = {name="_unknown", role=5, isDummy=true}

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
    name = L["sorter.mode.tmrh"],
    desc = format("%s:|n%s.", L["options.widget.sortMode.text"], L["sorter.mode.tmrh"]),
    getCompareFunc = getCompareFunc,
    onBeforeSort = function(keys, players)
      -- Insert dummy players for padding to keep the healers in the last group.
      local fixedSize = A.util:GetFixedInstanceSize()
      if fixedSize then
        while #keys < fixedSize do
          k = format("_pad%02d", #keys)
          tinsert(keys, k)
          players[k] = PADDING_PLAYER
        end
      end
    end,
    onSort = function(keys, players)
      sort(keys, getCompareFunc(players))
    end,
  })
end