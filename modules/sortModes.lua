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
-- key = "example",               -- required, string
-- aliases = {"whatever"},        -- optional, array of strings
-- isSplit = false,               -- optional, boolean
-- order = 100,                   -- optional, number
-- isExtra = true,                -- optional, boolean
-- name = "by whatever",          -- required, string
-- desc = "Do an example sort.",  -- optional, string or function(t)
-- getCompareFunc = someFunc,     -- optional, function(players)
-- onBeforeStart = someFunc,      -- optional, function()
-- onStart = someFunc,            -- optional, function()
-- onBeforeSort = someFunc,       -- optional, function(keys, players)
-- onSort = someFunc,             -- required, function(keys, players)
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
  if not sortMode.onSort then
    A.console:Errorf("missing onSort for sortMode %s", key)
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

function M:InitBaseSort(isOnBeforeSort, keys, players)
  local mode = M:GetDefault()
  if not mode.getCompareFunc then
    mode = R.objs.tmrh
  end
  if isOnBeforeSort then
    if mode.onBeforeSort then
      mode.onBeforeSort()
    end
  else
    return mode.getCompareFunc(players)
  end
end
