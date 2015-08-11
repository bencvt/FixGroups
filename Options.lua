local A, L = unpack(select(2, ...))
local M = A:NewModule("Options")
A.options = M

local defaults = {
  profile = {
    options = {
      tankAssist = true,
      fixOfflineML = true,
      sortMode = "TMURH", -- other valid values: "THMUR", "meter", "nosort"
      splitOddEven = true,
      resumeAfterCombat = true,
      tankMainTankAlways = false,
      tankMainTankPRN = true, -- ignored (implied false) if tankMainTankAlways == true
      openRaidTabAlways = false,
      openRaidTabPRN = true, -- ignored (implied false) if openRaidTabAlways == true
      tankMark = true,
      tankMarkIcons = {4, 6, 1, 2, 3, 7, 9, 9},
      partyMark = true,
      partyMarkIcons = {4, 6, 9, 9, 9},
      minimapIcon = {}, -- handled by LibDBIcon
      showMinimapIconAlways = true,
      showMinimapIconPRN = false, -- ignored (implied false) if showMinimapIconAlways == true
      addButtonToRaidTab = true,
      watchChat = true,
      announceChatAlways = false,
      announceChatPRN = true, -- ignored (implied false) if announceChatAlways == true
    },
  },
}

local MARKS = {
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14:0:0|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t",
  "none",
}

local O

local function getOptionMark(arr, index)
  if arr[index] and arr[index] <= 8 then
    return arr[index]
  end
  return 9
end

local function setOptionMark(arr, index, value)
  if arr ~= O.partyMarkIcons then
    A.sorter:StopProcessingNoResume()
  end
  if value <= 0 or value > 8 then
    value = 9
  end
  arr[index] = value
  -- Assume the user knows what they're doing.
  -- Don't bother fixing duplicates.
end

local BUTTONS, RAIDLEAD, RAIDASSIST, PARTY, UI, CHAT, RESET = 100, 200, 300, 400, 500, 600, 700, 900

local optionsTable = {
  type = "group",
  name = format("|cff33ff99%s|r v%s by |cff33ff99%s|r", A.name, A.version, A.author),
  args = {
    desc = {
      order = 0,
      type = "description",
      name = "Organizing groups is an important, if sometimes tedious, part of running a raid. This addon helps automate the process.|n",
      fontSize = "medium",
    },
    buttonCommandDefault = {
      order = BUTTONS+10,
      type = "execute",
      name = "Fix groups",
      func = function() A.console:Command("default") end,
      --disabled = function(i) return not IsInGroup() end,
    },
    buttonCommandSplit = {
      order = BUTTONS+20,
      type = "execute",
      name = "Split groups",
      desc = "Split raid into two sides based on overall damage/healing done.",
      func = function() A.console:Command("split") end,
      --disabled = function(i) return not IsInRaid() end,
    },
    buttonCommandHelp = {
      order = BUTTONS+30,
      type = "execute",
      name = "/fg command info",
      desc = "Print the various options for the |cff1784d1/fg|r console/macro command.",
      func = function() A.console:Command("help") end,
    },
    -- -------------------------------------------------------------------------
    headerUI = {
      order = UI,
      type = "header",
      name = "User interface and chat",
    },
    showMinimapIcon = {
      order = UI+10,
      name = "Show minimap icon",
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = "Always",
        [2] = "Only when lead or assist",
        [3] = "Never",
      },
      get = function(i) if O.showMinimapIconAlways then return 1 elseif O.showMinimapIconPRN then return 2 end return 3 end,
      set = function(i,v) O.showMinimapIconAlways, O.showMinimapIconPRN = (v==1), (v==2) A.gui:Refresh() end,
    },
    addButtonToRaidTab = {
      order = UI+20,
      name = "Add button to raid tab",
      desc = "This adds a \"Fix Group\" button to the default Blizzard UI on the raid tab. The default keybind to open the raid tab is O.",
      type = "toggle",
      width = "full",
      get = function(i) return O.addButtonToRaidTab end,
      set = function(i,v) O.addButtonToRaidTab = v A.gui:Refresh() end,
    },
    -- -------------------------------------------------------------------------
    --headerCHAT = {
    --  order = CHAT,
    --  type = "header",
    --  name = "Chat",
    --},
    watchChat = {
      order = CHAT+10,
      name = "Watch chat for requests to fix groups",
      desc = "When the keywords \"fix groups\" or \"mark tanks\" are seen in chat while not in combat, automatically open the raid tab.",
      type = "toggle",
      width = "full",
      get = function(i) return O.watchChat end,
      set = function(i,v) O.watchChat = v end,
    },
    announceChat = {
      order = CHAT+20,
      name = "Announce when players have been rearranged to instance chat",
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = "Always",
        [2] = "Only after changing group sorting method",
        [3] = "Never",
      },
      get = function(i) if O.announceChatAlways then return 1 elseif O.announceChatPRN then return 2 end return 3 end,
      set = function(i,v) O.announceChatAlways, O.announceChatPRN = (v==1), (v==2) end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDLEAD = {
      order = RAIDLEAD,
      type = "header",
      name = "When raid leader",
    },
    tankAssist = {
      order = RAIDLEAD+10,
      name = "Give tanks assist",
      type = "toggle",
      width = "full",
      get = function(i) return O.tankAssist end,
      set = function(i,v) O.tankAssist = v end,
    },
    fixOfflineML = {
      order = RAIDLEAD+20,
      name = "Fix offline master looter",
      desc = "If the master looter is offline, pass it to the raid leader (i.e., you).",
      type = "toggle",
      width = "full",
      get = function(i) return O.fixOfflineML end,
      set = function(i,v) O.fixOfflineML = v end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDASSIST = {
      order = RAIDASSIST,
      type = "header",
      name = "When raid leader or assist",
    },
    sortMode = {
      order = RAIDASSIST+10,
      name = "Rearrange players",
      desc = "The overall damage/healing done sort method will only work if Recount, Skada, or Details is running.|n|nThis sort method can be useful for making quick decisions on who's worth an emergency heal or brez in PUGs.|n|nYou can also type |cff1784d1/fg meter|r or to do a one-off sort without changing the setting.",
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = "Tanks > Melee > Ranged > Healers",
        [2] = "Tanks > Healers > Melee > Ranged",
        [3] = "Overall damage/healing done",
        [4] = "Do not rearrange players",
      },
      get = function(i)
        if O.sortMode == "nosort" then return 4
        elseif O.sortMode == "meter" then return 3
        elseif O.sortMode == "THMUR" then return 2
        else return 1
        end
      end,
      set = function(i,v)
        A.sorter:StopProcessingNoResume()
        if v == 4 then O.sortMode = "nosort"
        elseif v == 3 then O.sortMode = "meter"
        elseif v == 2 then O.sortMode = "THMUR"
        else O.sortMode = "TMURH"
        end
      end,
    },
    resumeAfterCombat = {
      order = RAIDASSIST+20,
      name = "Resume rearranging players when interrupted by combat",
      type = "toggle",
      width = "full",
      get = function(i) return O.resumeAfterCombat end,
      set = function(i,v) A.sorter:StopProcessingNoResume() O.resumeAfterCombat = v end,
    },
    tankMainTank = {
      order = RAIDASSIST+40,
      name = "Check whether main tanks are set",
      desc = "Unfortunately WoW does not allow addons to automatically set main tanks, but we can check for it at least.",
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = "Always",
        [2] = "Only in instances",
        [3] = "Never",
      },
      get = function(i) if O.tankMainTankAlways then return 1 elseif O.tankMainTankPRN then return 2 end return 3 end,
      set = function(i,v) O.tankMainTankAlways, O.tankMainTankPRN = (v==1), (v==2) end,
    },
    openRaidTab = {
      order = RAIDASSIST+50,
      name = "Open raid tab",
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = "Always",
        [2] = "Only when main tank needs to be set",
        [3] = "Never",
      },
      get = function(i) if O.openRaidTabAlways then return 1 elseif O.openRaidTabPRN then return 2 end return 3 end,
      set = function(i,v) O.openRaidTabAlways, O.openRaidTabPRN = (v==1), (v==2) end,
    },
    tankMark = {
      order = RAIDASSIST+60,
      name = "Put target markers on tanks",
      type = "toggle",
      width = "full",
      get = function(i) return O.tankMark end,
      set = function(i,v) O.tankMark = v end,
    },
    tankMarkIcon1 = {
      order = RAIDASSIST+60+1,
      name = "Tank 1",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 1) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 1, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon2 = {
      order = RAIDASSIST+60+2,
      name = "Tank 2",
      desc = "Tanks are sorted alphabetically.",
       type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 2) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 2, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon3 = {
      order = RAIDASSIST+60+3,
      name = "Tank 3",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 3) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 3, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon4 = {
      order = RAIDASSIST+60+4,
      name = "Tank 4",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 4) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 4, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon5 = {
      order = RAIDASSIST+60+5,
      name = "Tank 5",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 5) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 5, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon6 = {
      order = RAIDASSIST+60+6,
      name = "Tank 6",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 6) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 6, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon7 = {
      order = RAIDASSIST+60+7,
      name = "Tank 7",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 7) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 7, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    tankMarkIcon8 = {
      order = RAIDASSIST+60+8,
      name = "Tank 8",
      desc = "Tanks are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.tankMarkIcons, 8) end,
      set = function(i,v) setOptionMark(O.tankMarkIcons, 8, v) end,
      disabled = function(i) return not O.tankMark end,
    },
    splitOddEven = {
      order = RAIDASSIST+70,
      name = "When splitting groups, use odd/even groups",
      desc = "If this option is not checked then groups will be adjacent (i.e., 1-2 and 3-4, 1-3 and 4-6, or 1-4 and 5-8.)|n|nTo split groups, hold shift and left click the minimap icon, type |cff1784d1/fg split|r, or click the |cff1784d1Split groups|r button.",
      type = "toggle",
      width = "full",
      get = function(i) return O.splitOddEven end,
      set = function(i,v) A.sorter:StopProcessingNoResume() O.splitOddEven = v end,
    },
    -- -------------------------------------------------------------------------
    headerPARTY = {
      order = PARTY,
      type = "header",
      name = "When in party (5 man content)",
    },
    partyMark = {
      order = PARTY+10,
      name = "Put target markers on party members",
      type = "toggle",
      width = "full",
      get = function(i) return O.partyMark end,
      set = function(i,v) O.partyMark = v end,
    },
    partyMarkIcon1 = {
      order = PARTY+10+1,
      name = "Tank",
      desc = "Or the 1st party member, if there is no tank (e.g., arenas).|n|nParty members are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.partyMarkIcons, 1) end,
      set = function(i,v) setOptionMark(O.partyMarkIcons, 1, v) end,
      disabled = function(i) return not O.partyMark end,
    },
    partyMarkIcon2 = {
      order = PARTY+10+2,
      name = "Healer",
      desc = "Or the 2nd party member, if there is no healer.|n|nParty members are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.partyMarkIcons, 2) end,
      set = function(i,v) setOptionMark(O.partyMarkIcons, 2, v) end,
      disabled = function(i) return not O.partyMark end,
    },
    partyMarkIcon3 = {
      order = PARTY+10+3,
      name = "DPS 1",
      desc = "Party members are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.partyMarkIcons, 3) end,
      set = function(i,v) setOptionMark(O.partyMarkIcons, 3, v) end,
      disabled = function(i) return not O.partyMark end,
    },
    partyMarkIcon4 = {
      order = PARTY+10+4,
      name = "DPS 2",
      desc = "Party members are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.partyMarkIcons, 4) end,
      set = function(i,v) setOptionMark(O.partyMarkIcons, 4, v) end,
      disabled = function(i) return not O.partyMark end,
    },
    partyMarkIcon5 = {
      order = PARTY+10+5,
      name = "DPS 3",
      desc = "Party members are sorted alphabetically.",
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(O.partyMarkIcons, 5) end,
      set = function(i,v) setOptionMark(O.partyMarkIcons, 5, v) end,
      disabled = function(i) return not O.partyMark end,
    },
    -- -------------------------------------------------------------------------
    headerRESET = {
      order = RESET,
      type = "header",
      name = "",
    },
    buttonReset = {
      order = RESET+10,
      type = "execute",
      width = "full",
      name = "Reset all options to default",
      func = function()
        local pos = O.minimapIcon.minimapPos
        M.db:ResetProfile()
        A.options = M.db.profile.options
        O = A.options
        O.minimapIcon.minimapPos = pos
        A.console:Print("All options reset to default.")
      end,
    },
  },
}

function M:OnEnable()
  if M.db then
    return
  end
  M.db = LibStub("AceDB-3.0"):New("FixGroupsDB", defaults, true)
  -- Intentionally overwriting the module reference
  A.options = M.db.profile.options
  O = A.options

  LibStub("AceConfig-3.0"):RegisterOptionsTable(A.name, optionsTable)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(A.name, A.name)
end
