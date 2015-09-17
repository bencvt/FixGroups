--- Sort mode registry.
local A, L = unpack(select(2, ...))
local M = A:NewModule("sortModes")
A.sortModes = M
M.private = {
  modes = {},
}
local R = M.private

local format, ipairs, sort, tinsert, tostring = format, ipairs, sort, tinsert, tostring

--- @param sortMode expected to be a table with the following keys:
-- key = "example",               -- (required) string
-- name = "by whatever",          -- (required) string
-- aliases = {"whatever"},        -- array of strings
-- isSplit = false,               -- boolean
-- isIncludingSitting = false,    -- boolean
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
    A.console:Errorf(M, "attempting to register a nil sortMode")
    return
  end
  local key = sortMode.key
  if not key then
    A.console:Errorf(M, "missing key for sortMode")
    return
  end
  if not sortMode.name then
    A.console:Errorf(M, "missing name for sortMode %s", key)
    return
  end
  R.modes[key] = sortMode
  if sortMode.aliases then
    for _, alias in ipairs(sortMode.aliases) do
      if not alias or R.modes[alias] then
        A.console:Errorf(M, "invalid or duplicate alias %s for sortMode %s", tostring(alias), key)
      else
        R.modes[alias] = sortMode
      end
    end
  end
  if sortMode.onSort then
    sortMode.getFullKey = function() return sortMode.key end
    sortMode.getFullName = function() return sortMode.name end
  else
    sortMode.getFullKey = function() return format("%s:%s", M:GetDefault().key, sortMode.key) end
    sortMode.getFullName = function() return format("%s, %s", M:GetDefault().name, sortMode.name) end
  end
end

function M:GetMode(alias)
  return R.modes[alias]
end

function M:GetDefault()
  return A.options.sortMode and R.modes[A.options.sortMode] or R.modes.tmrh
end

function M:BaseGetCompareFunc(players)
  local base = M:GetDefault()
  if not base.getCompareFunc then
    base = R.modes.tmrh
  end
  return base.getCompareFunc(players)
end

function M:BaseOnBeforeSort(sortMode, keys, players)
  local base = M:GetDefault()
  if not base.getCompareFunc then
    R.modes.tmrh.onBeforeSort(keys, players)
  end
  if sortMode ~= base and base.onBeforeSort then
    base.onBeforeSort(keys, players)
  end
end
