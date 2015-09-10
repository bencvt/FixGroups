--- Implement the /fg (/fixgroups) console command.
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

function M:Command(args)
  local argsLower = strlower(strtrim(args))

  -- Simple arguments.
  if argsLower == "" or argsLower == "gui" or argsLower == "ui" or argsLower == "window" or argsLower == "about" or argsLower == "help" then
    A.fgGui:Open()
    return
  elseif argsLower == "config" or argsLower == "options" then
    A.utilGui:OpenConfig()
    return
  elseif argsLower == "cancel" then
    A.sorter:Stop()
    return
  elseif argsLower == "choose" or strmatch(argsLower, "^choose ") then
    A.chooseCommand:Command("choose", strsub(args, strlen("choose") + 1))
    return
  elseif argsLower == "list" or strmatch(argsLower, "^list ") then
    A.chooseCommand:Command("list", strsub(args, strlen("list") + 1))
    return
  elseif argsLower == "listself" or strmatch(argsLower, "^listself ") then
    A.chooseCommand:Command("listself", strsub(args, strlen("listself") + 1))
    return
  end

  -- Okay, we have some actual work to do then.
  A.sorter:Stop()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if argsLower ~= "nosort" and argsLower ~= "default" and argsLower ~= "sort" then
      A.console:Print(L["phrase.print.notInRaid"])
    end
    return
  end
  A.marker:FixRaid(false)

  -- Start sort.
  if argsLower == "nosort" then
    return
  elseif argsLower == "meter" or argsLower == "dps" then
    A.sorter:StartMeter()
  elseif argsLower == "clear1" or argsLower == "clear 1" or argsLower == "c1" or argsLower == "c 1" then
    A.sorter:StartDefault(1, 0)
  elseif argsLower == "clear2" or argsLower == "clear 2" or argsLower == "c2" or argsLower == "c 2" then
    A.sorter:StartDefault(2, 0)
  elseif argsLower == "skip1" or argsLower == "skip 1" or argsLower == "s1" or argsLower == "s 1" then
    A.sorter:StartDefault(0, 1)
  elseif argsLower == "skip2" or argsLower == "skip 2" or argsLower == "s2" or argsLower == "s 2" then
    A.sorter:StartDefault(0, 2)
  elseif argsLower == "meter" or argsLower == "dps" then
    A.sorter:StartMeter()
  elseif argsLower == "split" then
    A.sorter:StartSplit()
  elseif argsLower == "default" or argsLower == "sort" then
    A.sorter:StartDefault(0, 0)
  else
    A.console:Printf(L["phrase.print.badArgument"], H(args), H("/fg help"))
    return
  end
end
