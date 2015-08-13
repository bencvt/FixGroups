local A, L = unpack(select(2, ...))
local M = A:NewModule("Options", "AceTimer-3.0")
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
      openRaidTabPRN = true,
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
  L["none"],
}

local O
local optionsGUI

local function getOptionMark(arr, index)
  if arr[index] and arr[index] <= 8 then
    return arr[index]
  end
  return 9
end

local function setOptionMark(arr, index, value)
  if arr ~= O.partyMarkIcons then
    A.sorter:Stop()
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
      name = L["options.desc"].."|n",
      fontSize = "medium",
      hidden = function(i)
        -- For consistency's sake, we want the Fix Groups button in the options
        -- pane to be right-click-able, just like its twin on the raid tab.
        --
        -- Getting a reference to the button frame is a little kludgey.
        -- It's auto-created by Ace libraries, which doesn't give us an easy
        -- reference to the frame. So we walk the AceGUI tree each time the
        -- options pane is displayed.
        --
        -- We use a short timer to delay the tree walk: at the time the hidden
        -- function is called, the tree hasn't been built yet.
        M:ScheduleTimer(function()
          for _, g in ipairs(optionsGUI.obj.children[1].frame.obj.children) do
            if g.type == "Button" then
              -- Enable right-click on all buttons in the options pane.
              g.frame:RegisterForClicks("AnyUp")
            end
          end
        end, 0.1)
      end,
    },
    buttonCommandDefault = {
      order = BUTTONS+10,
      type = "execute",
      name = L["Fix Groups"],
      func = function(_, button) A.gui:ButtonPress(button) end,
      --disabled = function(i) return not IsInGroup() end,
    },
    buttonCommandSplit = {
      order = BUTTONS+20,
      type = "execute",
      name = L["Split Groups"],
      desc = L["options.buttonCommandSplit.desc"],
      func = function() A.console:Command("split") end,
      --disabled = function(i) return not IsInRaid() end,
    },
    buttonCommandHelp = {
      order = BUTTONS+30,
      type = "execute",
      name = L["/fg command info"],
      desc = format(L["options.buttonCommandHelp.desc"], "|cff1784d1/fg|r"),
      func = function() A.console:Command("help") end,
    },
    -- -------------------------------------------------------------------------
    headerUI = {
      order = UI,
      type = "header",
      name = L["User interface and chat"],
    },
    showMinimapIcon = {
      order = UI+10,
      name = L["Show minimap icon"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["Always"],
        [2] = L["Only when lead or assist"],
        [3] = L["Never"],
      },
      get = function(i) if O.showMinimapIconAlways then return 1 elseif O.showMinimapIconPRN then return 2 end return 3 end,
      set = function(i,v) O.showMinimapIconAlways, O.showMinimapIconPRN = (v==1), (v==2) A.gui:Refresh() end,
    },
    addButtonToRaidTab = {
      order = UI+20,
      name = L["Add button to raid tab"],
      desc = format(L["options.addButtonToRaidTab.desc"], "|cff1784d1"..L["Fix Groups"].."|r"),
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
      name = L["Watch chat for requests to fix groups"],
      desc = L["options.watchChat.desc"],
      type = "toggle",
      width = "full",
      get = function(i) return O.watchChat end,
      set = function(i,v) O.watchChat = v end,
    },
    announceChat = {
      order = CHAT+20,
      name = L["Announce when players have been rearranged to instance chat"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["Always"],
        [2] = L["Only after changing group sorting method"],
        [3] = L["Never"],
      },
      get = function(i) if O.announceChatAlways then return 1 elseif O.announceChatPRN then return 2 end return 3 end,
      set = function(i,v) O.announceChatAlways, O.announceChatPRN = (v==1), (v==2) end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDLEAD = {
      order = RAIDLEAD,
      type = "header",
      name = L["When raid leader"],
    },
    tankAssist = {
      order = RAIDLEAD+10,
      name = L["Give tanks assist"],
      type = "toggle",
      width = "full",
      get = function(i) return O.tankAssist end,
      set = function(i,v) O.tankAssist = v end,
    },
    fixOfflineML = {
      order = RAIDLEAD+20,
      name = L["Fix offline master looter"],
      desc = L["options.fixOfflineML.desc"],
      type = "toggle",
      width = "full",
      get = function(i) return O.fixOfflineML end,
      set = function(i,v) O.fixOfflineML = v end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDASSIST = {
      order = RAIDASSIST,
      type = "header",
      name = L["When raid leader or assist"],
    },
    sortMode = {
      order = RAIDASSIST+10,
      name = L["Rearrange players"],
      desc = format(L["options.sortMode.desc"], "|cff1784d1/fg meter|r"),
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["Tanks > Melee > Ranged > Healers"],
        [2] = L["Tanks > Healers > Melee > Ranged"],
        [3] = L["Overall damage/healing done"],
        [4] = L["Do not rearrange players"],
      },
      get = function(i)
        if O.sortMode == "nosort" then return 4
        elseif O.sortMode == "meter" then return 3
        elseif O.sortMode == "THMUR" then return 2
        else return 1
        end
      end,
      set = function(i,v)
        A.sorter:Stop()
        if v == 4 then O.sortMode = "nosort"
        elseif v == 3 then O.sortMode = "meter"
        elseif v == 2 then O.sortMode = "THMUR"
        else O.sortMode = "TMURH"
        end
      end,
    },
    resumeAfterCombat = {
      order = RAIDASSIST+20,
      name = L["Resume rearranging players when interrupted by combat"],
      type = "toggle",
      width = "full",
      get = function(i) return O.resumeAfterCombat end,
      set = function(i,v) A.sorter:Stop() O.resumeAfterCombat = v end,
    },
    tankMainTank = {
      order = RAIDASSIST+40,
      name = L["Check whether main tanks are set"],
      desc = L["options.tankMainTank.desc"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["Always"],
        [2] = L["Only in instances"],
        [3] = L["Never"],
      },
      get = function(i) if O.tankMainTankAlways then return 1 elseif O.tankMainTankPRN then return 2 end return 3 end,
      set = function(i,v) O.tankMainTankAlways, O.tankMainTankPRN = (v==1), (v==2) end,
    },
    openRaidTab = {
      order = RAIDASSIST+50,
      name = L["Open raid tab when main tank needs to be set"],
      type = "toggle",
      width = "full",
      get = function(i) return O.openRaidTabPRN end,
      set = function(i,v) O.openRaidTabPRN = v end,
    },
    tankMark = {
      order = RAIDASSIST+60,
      name = L["Put target markers on tanks"],
      type = "toggle",
      width = "full",
      get = function(i) return O.tankMark end,
      set = function(i,v) O.tankMark = v end,
    },
    tankMarkIcon1 = {
      order = RAIDASSIST+60+1,
      name = L["Tank 1"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 2"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 3"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 4"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 5"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 6"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 7"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["Tank 8"],
      desc = L["Tanks are sorted alphabetically."],
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
      name = L["When splitting groups, use odd/even groups"],
      desc = format(L["options.splitOddEven.desc"], "|cff1784d1/fg split|r", "|cff1784d1"..L["Split Groups"].."|r"),
      type = "toggle",
      width = "full",
      get = function(i) return O.splitOddEven end,
      set = function(i,v) A.sorter:Stop() O.splitOddEven = v end,
    },
    -- -------------------------------------------------------------------------
    headerPARTY = {
      order = PARTY,
      type = "header",
      name = L["When in party (5 man content)"],
    },
    partyMark = {
      order = PARTY+10,
      name = L["Put target markers on party members"],
      type = "toggle",
      width = "full",
      get = function(i) return O.partyMark end,
      set = function(i,v) O.partyMark = v end,
    },
    partyMarkIcon1 = {
      order = PARTY+10+1,
      name = L["Tank"],
      desc = L["options.partyMarkIcon1.desc"].."|n|n"..L["Party members are sorted alphabetically."],
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
      name = L["Healer"],
      desc = L["options.partyMarkIcon2.desc"].."|n|n"..L["Party members are sorted alphabetically."],
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
      name = L["DPS 1"],
      desc = L["Party members are sorted alphabetically."],
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
      name = L["DPS 2"],
      desc = L["Party members are sorted alphabetically."],
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
      name = L["DPS 3"],
      desc = L["Party members are sorted alphabetically."],
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
      name = L["Reset all options to default"],
      func = function()
        local minimapIcon = O.minimapIcon
        M.db:ResetProfile()
        A.options = M.db.profile.options
        O = A.options
        O.minimapIcon = minimapIcon
        A.console:Print(L["All options reset to default."])
        A.gui:Refresh()
      end,
    },
  },
}

function M:OnInitialize()
  M.db = LibStub("AceDB-3.0"):New("FixGroupsDB", defaults, true)
  -- Intentionally overwriting the module reference
  A.options = M.db.profile.options
  O = A.options

  LibStub("AceConfig-3.0"):RegisterOptionsTable(A.name, optionsTable)
  optionsGUI = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(A.name, A.name)
end
