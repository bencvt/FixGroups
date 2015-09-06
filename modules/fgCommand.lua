local A, L = unpack(select(2, ...))
local M = A:NewModule("fgCommand", "AceConsole-3.0")
A.fgCommand = M
local H, HA = A.util.Highlight, A.util.HighlightAddon

local format, print, strlen, strlower, strmatch, strsub, strtrim = format, print, strlen, strlower, strmatch, strsub, strtrim
local IsInGroup, IsInRaid = IsInGroup, IsInRaid

function M:OnEnable()
  local function slashCmd(args)
    M:Command(args)
  end
  M:RegisterChatCommand("fixgroups", slashCmd)
  M:RegisterChatCommand("fixgroup", slashCmd)
  M:RegisterChatCommand("fg", slashCmd)
end

function M:PrintHelp()
  M:Printf(L["phrase.versionAuthor"], A.VERSION, HA(A.AUTHOR))
  print(format(L["console.help.header"], H("/fixgroups"), H("/fg")))
  print(format("  %s %s %s - %s", H("/fg help"),    L["word.or"], H("/fg about"),   L["console.help.help"]))
  print(format("  %s %s %s - %s", H("/fg config"),  L["word.or"], H("/fg options"), format(L["console.help.config"], A.NAME)))
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
    A.util:OpenConfig()
    return
  elseif argsLower == "cancel" then
    A.sorter:Stop()
    return
  elseif argsLower == "choose" or strmatch(argsLower, "^choose ") then
    A.chooseCommand:Command(strsub(args, strlen("choose") + 1))
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
