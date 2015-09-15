--- Implement the /fg (/fixgroups) console command.
local A, L = unpack(select(2, ...))
local M = A:NewModule("fgCommand", "AceConsole-3.0")
A.fgCommand = M
local H, HA = A.util.Highlight, A.util.HighlightAddon

local format, gsub, print, strlen, strlower, strmatch, strsub, strtrim = format, gsub, print, strlen, strlower, strmatch, strsub, strtrim
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
  local cmd = strlower(strtrim(args))

  -- Simple arguments.
  if cmd == "" or cmd == "gui" or cmd == "ui" or cmd == "window" or cmd == "about" or cmd == "help" then
    A.fgGui:Open()
    return
  elseif cmd == "config" or cmd == "options" then
    A.utilGui:OpenConfig()
    return
  elseif cmd == "cancel" then
    A.sorter:StopManual()
    return
  elseif cmd == "reannounce" or cmd == "reann" then
    A.sorter:ResetAnnounced()
    return
  elseif cmd == "choose" or strmatch(cmd, "^choose ") then
    A.chooseCommand:Command("choose", strsub(args, strlen("choose") + 1))
    return
  elseif cmd == "list" or strmatch(cmd, "^list ") then
    A.chooseCommand:Command("list", strsub(args, strlen("list") + 1))
    return
  elseif cmd == "listself" or strmatch(cmd, "^listself ") then
    A.chooseCommand:Command("listself", strsub(args, strlen("listself") + 1))
    return
  end

  -- Stop the current sort, if any.
  A.sorter:Stop()

  -- Determine sort mode.
  cmd = gsub(cmd, "%s+", "")
  local sortMode = A.sortModes:GetMode(cmd)
  if sortMode then
    if sortMode.key == "sort" then
      sortMode = A.sortModes:GetDefault()
    end
  else
    A.console:Printf(L["phrase.print.badArgument"], H(args), H("/fg help"))
    return
  end

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if sortMode.key ~= "nosort" and sortMode.key ~= "sort" then
      A.console:Print(L["phrase.print.notInRaid"])
    end
    return
  end
  A.marker:FixRaid(false)

  -- Start sort.
  A.sorter:Start(sortMode)

  -- Notify other people running this addon that we've started a new sort.
  A.addonChannel:Broadcast("f:"..A.sorter:GetKey())
end
