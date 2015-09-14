--- Plugin registry.
local A, L = unpack(select(2, ...))
local M = A:NewModule("plugins")
A.plugins = M
M.private = {
  sortModes = {},
}
local R = M.private

function M:RegisterSortMode(aliases, name, desc, sortFunc)
  local s = {
    key = aliases[1],
    aliases = aliases,
    name = name,
    desc = desc,
    sortFunc = sortFunc,
  }
  for _, alias in ipairs(aliases) do
    R.sortModes[alias] = s
  end
end

function M:GetSortMode(alias)
  return R.sortModes[alias]
end
