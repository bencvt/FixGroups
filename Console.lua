local A, L = unpack(select(2, ...))
local M = A:NewModule("Console")
A.console = M

function M:OnEnable()
  local function slashCmd(args)
    M:Command(args)
  end
  A:RegisterChatCommand("fixgroups", slashCmd)
  A:RegisterChatCommand("fixgroup", slashCmd)
  A:RegisterChatCommand("fg", slashCmd)
end

function M:OnDisable()
  A:UnregisterChatCommand("fixgroups")
  A:UnregisterChatCommand("fixgroup")
  A:UnregisterChatCommand("fg")
end

function M:Print(...)
  print("|cff33ff99"..A.name.."|r:", ...)
end

function M:PrintHelp()
  M:Print(format("v%s by |cff33ff99%s|r", A.version, A.author))
  print("Arguments for the |cff1784d1/fixgroups|r command (or |cff1784d1/fg|r):")
  print("  |cff1784d1/fg help|r or |cff1784d1/fg about|r - you're reading it")
  print(format("  |cff1784d1/fg config|r or |cff1784d1/fg options|r - same as Esc>Interface>AddOns>%s", A.name))
  print("  |cff1784d1/fg cancel|r - stop rearranging players")
  print("  |cff1784d1/fg nosort|r - fix groups, no sorting")
  print("  |cff1784d1/fg meter|r or |cff1784d1/fg dps|r - fix groups, sort by overall damage/healing done")
  print("  |cff1784d1/fg split|r - split raid into two sides based on overall damage/healing done")
  print("  |cff1784d1/fg|r - fix groups")
  if A.options.showMinimapIconAlways or A.options.showMinimapIconPRN then
    print("Left click minimap icon to fix groups; right click for config.")
  end
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
  A.sorter:StopProcessing()

  -- Set tank marks and such.
  if IsInGroup() and not IsInRaid() then
    A.marker:FixParty()
    if args and strmatch(args, " *") and args ~= "nosort" and args ~= "default" then
      M:Print("Groups can only be sorted while in a raid.")
    end
    return
  end
  A.marker:FixRaid(false)

  -- Determine sort mode.
  if args == "nosort" then
    return
  elseif args == "meter" or args == "dps" then
    A.sorter.sortMode = "meter"
  elseif args == "split" then
    A.sorter.sortMode = "split"
  else
    A.sorter.sortMode = "default"
    if args ~= "default" and not strmatch(args, " *") then
      M:Print(format("Unknown argument \"%s\". Type |cff1784d1/fg help|r for valid arguments.", args))
    end
    if A.options.sortMode == "nosort" then
      return
    end
  end
  if A.sorter:PauseIfInCombat() then
    return
  end

  -- Sort groups.
  -- TODO: move to sorter module
  A.sorter.core:BuildGroups()
  if A.sorter:IsSortingByMeter() or A.sorter:IsSplittingRaid() then
    A.sorter.meter:BuildSnapshot()
  end
  A.sorter:ProcessStep()
end

function M:Debug(...)
  print("|cff33ff99"..A.name.."|r DEBUG ["..date("%H:%M:%S").."] ", ...)
end

-- TODO fix refs

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
