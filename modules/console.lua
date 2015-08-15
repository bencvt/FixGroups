local A, L = unpack(select(2, ...))
local M = A:NewModule("console", "AceConsole-3.0")
A.console = M

local date, format, print, select, tconcat, tinsert, tostring = date, format, print, select, table.concat, table.insert, tostring
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

function M:PrintHelp()
  M:Print(format(L["console.help.versionAuthor"], A.version, "|cff33ff99"..A.author.."|r"))
  print(format(L["console.help.header"], "|cff1784d1/fixgroups|r", "|cff1784d1/fg|r"))
  print("  |cff1784d1/fg help|r "..L["word.or"].." |cff1784d1/fg about|r - "..L["console.help.help"])
  print("  |cff1784d1/fg config|r "..L["word.or"].." |cff1784d1/fg options|r - "..format(L["console.help.config"], A.name))
  print("  |cff1784d1/fg cancel|r - "..L["console.help.cancel"])
  print("  |cff1784d1/fg nosort|r - "..L["console.help.nosort"])
  print("  |cff1784d1/fg meter|r "..L["word.or"].." |cff1784d1/fg dps|r - "..L["console.help.meter"])
  print("  |cff1784d1/fg split|r - "..L["console.help.split"])
  print("  |cff1784d1/fg|r - "..L["console.help.blank"])
end

function M:Command(args)
  -- Simple arguments.
  if args == "about" or args == "help" then
    M:PrintHelp()
    return
  elseif args == "config" or args == "options" then
    A.gui:OpenConfig()
    return
  elseif args == "cancel" then
    A.sorter:Stop()
    return
  end

  -- Okay, we have some actual work to do then.
  A.sorter:Stop()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if args ~= "" and args ~= "nosort" and args ~= "default" then
      M:Print(L["console.print.notInRaid"])
    end
    return
  end
  A.marker:FixRaid(false)

  -- Start sort.
  if args == "nosort" then
    return
  elseif args == "meter" or args == "dps" then
    A.sorter:StartMeter()
  elseif args == "split" then
    A.sorter:StartSplit()
  elseif args == "" or args == "default" then
    A.sorter:StartDefault()
  else
    M:Print(format(L["console.print.badArgument"], "|cff1784d1"..args.."|r", "|cff1784d1/fg help|r"))
    return
  end
end

function M:Debug(...)
  print("|cff33ff99"..A.name.."|r DEBUG ["..date("%H:%M:%S").."] ", ...)
end

function M:DebugDump(...)
  local t = {}
  for i = 1, select("#", ...) do
    tinsert(t, tostring(select(i, ...) or "<nil>"))
  end
  M:Debug(tconcat(t, ", "))
end
