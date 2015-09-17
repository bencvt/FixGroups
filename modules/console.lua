--- Utility functions to output text to the console (i.e., default chat frame).
local A, L = unpack(select(2, ...))
local M = A:NewModule("console")
A.console = M

local PREFIX = A.util:HighlightAddon(A.NAME)..":"

local date, format, print, select, strfind, tinsert, tostring = date, format, print, select, strfind, tinsert, tostring
local tconcat = table.concat

function M:Print(...)
  print(PREFIX, ...)
end

function M:Printf(...)
  print(PREFIX, format(...))
end

function M:Errorf(module, ...)
  print(format("%s: internal error in %s module:", A.util:HighlightAddon(A.NAME.." v"..A.VERSION_PACKAGED)), format(...))
end

local function isDebuggingModule(module)
  return not module or A.DEBUG_MODULES == "*" or strfind(A.DEBUG_MODULES, module:GetName())
end

function M:Debug(module, ...)
  if isDebuggingModule(module) then
    print("|cff999999["..date("%H:%M:%S").." "..tostring(module or A.NAME).."]|r|cffffcc99", ..., "|r")
  end
end

function M:Debugf(module, ...)
  if isDebuggingModule(module) then
    print("|cff999999["..date("%H:%M:%S").." "..tostring(module or A.NAME).."]|r|cffffcc99", format(...), "|r")
  end
end

function M:DebugMore(module, ...)
  if isDebuggingModule(module) then
    print("|cffffcc99", ..., "|r")
  end
end

function M:DebugDump(module, ...)
  local t = {}
  for i = 1, select("#", ...) do
    tinsert(t, tostring(select(i, ...)))
  end
  M:Debug(module, tconcat(t, ", "))
end
