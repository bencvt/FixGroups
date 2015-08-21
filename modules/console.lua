local A, L = unpack(select(2, ...))
local M = A:NewModule("console", "AceConsole-3.0")
A.console = M

local date, format, print, select, strfind, strlen, strlower, strmatch, strsub, strtrim, tconcat, tinsert, tostring = date, format, print, select, string.find, string.len, string.lower, string.match, string.sub, string.trim, table.concat, table.insert, tostring
local IsInGroup, IsInRaid = IsInGroup, IsInRaid

local H, HA

function M:OnEnable()
  H, HA = A.util.Highlight, A.util.HighlightAddon
  local function slashCmd(args)
    M:Command(args)
  end
  M:RegisterChatCommand("fixgroups", slashCmd)
  M:RegisterChatCommand("fixgroup", slashCmd)
  M:RegisterChatCommand("fg", slashCmd)
end

function M:Print(...)
  print(HA(A.name)..":", ...)
end

function M:Printf(...)
  print(HA(A.name)..":", format(...))
end

function M:PrintHelp()
  M:Printf(L["versionAuthor"], A.version, HA(A.author))
  print(format(L["console.help.header"], H("/fixgroups"), H("/fg")))
  print(format("  %s %s %s - %s", H("/fg help"),    L["word.or"], H("/fg about"),   L["console.help.help"]))
  print(format("  %s %s %s - %s", H("/fg config"),  L["word.or"], H("/fg options"), format(L["console.help.config"], A.name)))
  print(format("  %s - %s",       H("/fg choose"),                                  format(L["console.help.seeChoose"], H("/choose help"))))
  print(format("  %s - %s",       H("/fg cancel"),                                  L["console.help.cancel"]))
  print(format("  %s - %s",       H("/fg nosort"),                                  L["console.help.nosort"]))
  print(format("  %s %s %s - %s", H("/fg meter"),   L["word.or"], H("/fg dps"),     L["console.help.meter"]))
  print(format("  %s - %s",       H("/fg split"),                                   L["console.help.split"]))
  print(format("  %s - %s",       H("/fg"),                                         L["console.help.blank"]))
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
    M:Printf(L["console.print.badArgument"], H(args), H("/fg help"))
    return
  end
end

function M:Errorf(module, ...)
  print(HA(A.name).." internal error in "..module:GetName().." module:", format(...))
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
