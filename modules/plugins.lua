--- Plugin registry.
local A, L = unpack(select(2, ...))
local M = A:NewModule("plugins")
A.plugins = M
M.private = {
  sortModes = {},
}
local R = M.private

--- @param sortMode expected to be a table with the following keys:
-- name = "example",              -- string
-- aliases = {"example", "ex"},   -- array of strings
-- desc = "Do an example sort."   -- string
-- onSort = someFunc,             -- function(keys, players)
-- onBeforeStart = someFunc,      -- function()
function M:RegisterSortMode(sortMode)
  if not sortMode then
    A.console:Errorf("attempting to register a nil sortMode")
    return
  end
  if not sortMode.name then
    A.console:Errorf("missing name for sortMode")
    return
  end
  if not sortMode.aliases or #sortMode.aliases < 1 then
    A.console:Errorf("missing aliases for sortMode %s", sortMode.name)
    return
  end
  if not sortMode.onSort then
    A.console:Errorf("missing onSort for sortMode %s", sortMode.name)
  end
  sortMode.key = sortMode.aliases[1]
  for _, alias in ipairs(sortMode.aliases) do
    if not alias or R.sortModes[alias] then
      A.console:Errorf("invalid or duplicate alias %s for sortMode %s", tostring(alias), sortMode.name)
    else
      R.sortModes[alias] = sortMode
    end
  end
end

function M:GetSortMode(alias)
  return R.sortModes[alias]
end
