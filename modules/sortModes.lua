--- Sort mode registry.
local A, L = unpack(select(2, ...))
local M = A:NewModule("sortModes")
A.sortModes = M
M.private = {
  objs = {},
  orderedList = {},
}
local R = M.private

local ipairs, sort, tinsert, tostring = ipairs, sort, tinsert, tostring

--- @param sortMode expected to be a table with the following keys:
-- key = "example",               -- (required) string
-- name = "by whatever",          -- (required) string
-- aliases = {"whatever"},        -- array of strings
-- isSplit = false,               -- boolean
-- order = 100,                   -- number
-- isExtra = true,                -- boolean
-- desc = "Do an example sort.",  -- string or function(t)
-- getCompareFunc = someFunc,     -- function(players)
-- onBeforeStart = someFunc,      -- function()
-- onStart = someFunc,            -- function()
-- onBeforeSort = someFunc,       -- function(keys, players)
-- onSort = someFunc,             -- function(keys, players)
-- groupOffset = 0,               -- number
-- skipFirstGroups = 0,           -- number
function M:Register(sortMode)
  if not sortMode then
    A.console:Errorf("attempting to register a nil sortMode")
    return
  end
  local key = sortMode.key
  if not key then
    A.console:Errorf("missing key for sortMode")
    return
  end
  if not sortMode.name then
    A.console:Errorf("missing name for sortMode %s", key)
    return
  end
  R.objs[key] = sortMode
  tinsert(R.orderedList, key)
  sort(R.orderedList, function(a, b)
    local oa, ob = R.objs[a].order or 0, R.objs[b].order or 0
    return (oa == ob) and (a < b) or (oa < ob)
  end)
  if sortMode.aliases then
    for _, alias in ipairs(sortMode.aliases) do
      if not alias or R.objs[alias] then
        A.console:Errorf("invalid or duplicate alias %s for sortMode %s", tostring(alias), key)
      else
        R.objs[alias] = sortMode
      end
    end
  end
end

function M:GetObj(alias)
  return R.objs[alias]
end

function M:GetList()
  return R.orderedList
end

function M:GetName(key)
  if R.objs[key] then
    return R.objs[key].name
  end
  -- Must be a built-in sort mode.
  return L["sorter.mode."..key]
end

function M:GetDefault()
  return A.options.sortMode and R.objs[A.options.sortMode] or R.objs.tmrh
end

function M:BaseGetCompareFunc(players)
  local base = M:GetDefault()
  if not base.getCompareFunc then
    base = R.objs.tmrh
  end
  return base.getCompareFunc(players)
end

function M:BaseOnBeforeSort(sortMode, keys, players)
  local base = M:GetDefault()
  if not base.getCompareFunc then
    R.objs.tmrh.onBeforeSort()
  end
  if sortMode ~= base and base.onBeforeSort then
    base.onBeforeSort()
  end
end
