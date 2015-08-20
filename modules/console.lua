local A, L = unpack(select(2, ...))
local M = A:NewModule("console", "AceConsole-3.0")
A.console = M

local date, format, print, select, strfind, strlen, strlower, strmatch, strsub, strtrim, tconcat, tinsert, tostring = date, format, print, select, string.find, string.len, string.lower, string.match, string.sub, string.trim, table.concat, table.insert, tostring
local IsInGroup, IsInRaid = IsInGroup, IsInRaid

function M:OnEnable()
  local function slashCmd(args)
    M:Command(args)
  end
  M:RegisterChatCommand("fixgroups", slashCmd)
  M:RegisterChatCommand("fixgroup", slashCmd)
  M:RegisterChatCommand("fg", slashCmd)
end

function M:Print(...)
  print("|cff33ff99"..A.name.."|r:", ...)
end

function M:Printf(...)
  print("|cff33ff99"..A.name.."|r:", format(...))
end

function M:PrintHelp()
  M:Printf(L["versionAuthor"], A.version, "|cff33ff99"..A.author.."|r")
  print(format(L["console.help.header"], "|cff1784d1/fixgroups|r", "|cff1784d1/fg|r"))
  print(format("  |cff1784d1/fg help|r %s |cff1784d1/fg about|r - %s", L["word.or"], L["console.help.help"]))
  print(format("  |cff1784d1/fg config|r %s |cff1784d1/fg options|r - %s", L["word.or"], format(L["console.help.config"], A.name)))
  print(format("  |cff1784d1/fg choose|r - %s", format(L["console.help.seeChoose"], "|cff1784d1/choose help|r")))
  print(format("  |cff1784d1/fg cancel|r - %s", L["console.help.cancel"]))
  print(format("  |cff1784d1/fg nosort|r - %s", L["console.help.nosort"]))
  print(format("  |cff1784d1/fg meter|r %s |cff1784d1/fg dps|r - %s", L["word.or"], L["console.help.meter"]))
  print(format("  |cff1784d1/fg split|r - %s", L["console.help.split"]))
  print(format("  |cff1784d1/fg|r - %s", L["console.help.blank"]))
end

function M:Command(args)
  local argsLower = strlower(strtrim(args))

  -- Simple arguments.
  if argsLower == "about" or argsLower == "help" then
    M:PrintHelp()
    return
  elseif argsLower == "config" or argsLower == "options" then
    A.gui:OpenConfig()
    return
  elseif argsLower == "cancel" then
    A.sorter:Stop()
    return
  elseif argsLower == "choose" or strmatch(argsLower, "^choose ") then
    A.choose:Command(strsub(args, strlen("choose") + 1))
    return
  end

  -- Okay, we have some actual work to do then.
  A.sorter:Stop()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if argsLower ~= "" and argsLower ~= "nosort" and argsLower ~= "default" then
      M:Print(L["console.print.notInRaid"])
    end
    return
  end
  A.marker:FixRaid(false)

  -- Start sort.
  if argsLower == "nosort" then
    return
  elseif argsLower == "meter" or argsLower == "dps" then
    A.sorter:StartMeter()
  elseif argsLower == "split" then
    A.sorter:StartSplit()
  elseif argsLower == "" or argsLower == "default" then
    A.sorter:StartDefault()
  else
    M:Printf(L["console.print.badArgument"], "|cff1784d1"..args.."|r", "|cff1784d1/fg help|r")
    return
  end
end

function M:Errorf(module, ...)
  print("|cff33ff99"..A.name.."|r internal error in "..module:GetName().." module:", format(...))
end

local function isDebuggingModule(module)
  return not module or A.debugModules == "*" or strfind(A.debugModules, module:GetName())
end

function M:Debug(module, ...)
  if isDebuggingModule(module) then
    print("|cffffcc99["..date("%H:%M:%S").."] "..(module and module:GetName() or "")..":", ..., "|r")
  end
end

function M:Debugf(module, ...)
  if isDebuggingModule(module) then
    print("|cffffcc99["..date("%H:%M:%S").."] "..(module and module:GetName() or "")..":", format(...), "|r")
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
    tinsert(t, tostring(select(i, ...) or "<nil>"))
  end
  M:Debug(module, tconcat(t, ", "))
end
