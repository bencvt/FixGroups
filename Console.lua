local A, L = unpack(select(2, ...))
local M = A:NewModule("Console", "AceConsole-3.0")
A.console = M

local format, print = format, print

function M:OnEnable()
  local function slashCmd(args)
    M:Command(args)
  end
  M:RegisterChatCommand("fixgroups", slashCmd)
  M:RegisterChatCommand("fixgroup", slashCmd)
  M:RegisterChatCommand("fg", slashCmd)
end

function M:OnDisable()
  M:UnregisterChatCommand("fixgroups")
  M:UnregisterChatCommand("fixgroup")
  M:UnregisterChatCommand("fg")
end

function M:Print(...)
  print("|cff33ff99"..A.name.."|r:", ...)
end

function M:PrintHelp()
  M:Print(format(L["v%s by %s"], A.version, "|cff33ff99"..A.author.."|r"))
  print(format(L["Arguments for the %s command (or %s):"], "|cff1784d1/fixgroups|r", "|cff1784d1/fg|r"))
  print("  |cff1784d1/fg help|r "..L["or"].." |cff1784d1/fg about|r - "..L["you're reading it"])
  print("  |cff1784d1/fg config|r "..L["or"].." |cff1784d1/fg options|r - "..format(L["same as Esc>Interface>AddOns>%s"], A.name))
  print("  |cff1784d1/fg cancel|r - "..L["stop rearranging players"])
  print("  |cff1784d1/fg nosort|r - "..L["fix groups, no sorting"])
  print("  |cff1784d1/fg meter|r "..L["or"].." |cff1784d1/fg dps|r - "..L["fix groups, sort by overall damage/healing done"])
  print("  |cff1784d1/fg split|r - "..L["split raid into two sides based on overall damage/healing done"])
  print("  |cff1784d1/fg|r - "..L["fix groups"])
end

function M:Command(args)
  -- Simple arguments.
  if args == "about" or args == "help" then
    M:PrintHelp()
    return
  elseif args == "config" or args == "options" then
    A.gui.OpenConfig()
    return
  elseif args == "cancel" then
    A.sorter:StopProcessingNoResume()
    return
  end

  -- Okay, we have some actual work to do then.
  A.sorter:StopProcessingNoResume()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if args ~= "" and args ~= "nosort" and args ~= "default" then
      M:Print(L["Groups can only be sorted while in a raid."])
    end
    return
  end
  A.marker:FixRaid(false)

  -- Determine sort mode.
  local sortMode
  if args == "nosort" then
    return
  elseif args == "meter" or args == "dps" then
    sortMode = "meter"
  elseif args == "split" then
    sortMode = "split"
  elseif args == "" or args == "default" then
    if A.options.sortMode == "nosort" then
      return
    end
    sortMode = "default"
  else
    M:Print(format(L["Unknown argument %s. Type %s for valid arguments."], "|cff1784d1"..args.."|r", "|cff1784d1/fg help|r"))
    return
  end

  -- Sort groups.
  A.sorter:Begin(sortMode)
end

function M:Debug(...)
  print("|cff33ff99"..A.name.."|r DEBUG ["..date("%H:%M:%S").."] ", ...)
end

function M:DebugPrintGroups()
  for g = 1, 8 do
    local line = g.."("..A.sorter.core.groupSizes[g].."):"
    for key, i in pairs(A.sorter.core.groups[g]) do
      line = line.." "..i..key
    end
    M:Debug(line)
  end
end

function M:DebugPrintMeterSnapshot()
  M:Debug("sorter.meter.snapshot:")
  for k, v in pairs(A.sorter.meter.snapshot) do
    M:Debug("  "..k..": "..v)
  end
end

function M:DebugPrintDelta()
  M:Debug(format("delta=%d players in incorrect groups:", #A.sorter.core.delta))
  for _, p in ipairs(A.sorter.core.delta) do
    M:Debug(p.oldGroup.."/"..p.newGroup.." raid"..p.index.." "..p.key)
  end
end

function M:DebugPrintAction()
  M:Debug(format("action: name=%s group=%s debug=%s", (A.sorter.core.action.name or "<nil>"), (A.sorter.core.action.group or "<nil>"), (A.sorter.core.action.debug or "<nil>")))
end
