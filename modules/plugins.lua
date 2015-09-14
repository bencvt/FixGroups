--- Plugin registry.
local A, L = unpack(select(2, ...))
local M = A:NewModule("plugins")
A.plugins = M
M.private = {
  sortModes = {},
  sortModeList = {},
}
local R = M.private

local ipairs, sort, tinsert, tostring = ipairs, sort, tinsert, tostring

--- @param sortMode expected to be a table with the following keys:
-- key = "example",               -- required, string
-- aliases = {"whatever"},        -- optional, array of strings
-- name = "by whatever",          -- required, string
-- desc = {"Do an example sort."} -- optional, array of strings
-- onSort = someFunc,             -- required, function(keys, players)
-- onBeforeStart = someFunc,      -- optional, function()
function M:RegisterSortMode(sortMode)
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
  R.sortModes[key] = sortMode
  tinsert(R.sortModeList, key)
  sort(R.sortModeList)
  if sortMode.aliases then
    for _, alias in ipairs(sortMode.aliases) do
      if not alias or R.sortModes[alias] then
        A.console:Errorf("invalid or duplicate alias %s for sortMode %s", tostring(alias), key)
      else
        R.sortModes[alias] = sortMode
      end
    end
  end
end

function M:GetSortMode(alias)
  return R.sortModes[alias]
end

function M:GetSortModeList()
  return R.sortModeList
end

function M:GetSortModeName(key)
  if R.sortModes[key] then
    return R.sortModes[key].name
  end
  -- Must be a built-in sort mode.
  return L["sorter.mode."..key]
end
