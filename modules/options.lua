local A, L = unpack(select(2, ...))
local M = A:NewModule("options", "AceTimer-3.0")
A.options = M
M.private = {
  optionsGUI = false,
  optionsTable = false,
  defaults = {
    profile = {
      options = {
        tankAssist = true,
        fixOfflineML = true,
        sortMode = "TMURH", -- other valid values: "THMUR", "meter", "nosort"
        splitOddEven = true,
        resumeAfterCombat = true,
        tankMainTankAlways = false,
        tankMainTankPRN = true, -- ignored (implied false) if tankMainTankAlways == true
        openRaidTabPRN = true, -- ignored (implied false) if tankMainTankAlways == true and tankMainTankPRN = false
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
  },
}
local R = M.private

-- In parentheses is how many times DBM uses that mark for all Draenor content.
--
-- Skull, cross, and moon are used the least frequently. However those marks
-- usually mean "kill first", "kill second", and "keep cc'd", respectively.
--
-- Of the remaining marks, triangle and square are next. That's why they're the
-- default tank marks.
local MARKS = {
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14:0:0|t", -- 1=star (16)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14:0:0|t", -- 2=circle (16)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14:0:0|t", -- 3=diamond (14)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14:0:0|t", -- 4=triangle (11)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14:0:0|t", -- 5=moon (9)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14:0:0|t", -- 6=square (10)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14:0:0|t", -- 7=cross (7)
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t", -- 8=skull (9)
  L["options.value.noMark"],
}
local DELAY_FIX_BUTTONS = 0.1

local ipairs = ipairs

local function getOptionMark(arr, index)
  if arr[index] and arr[index] <= 8 then
    return arr[index]
  end
  return 9
end

local function setOptionMark(arr, index, value)
  if arr ~= A.options.partyMarkIcons then
    A.sorter:Stop()
  end
  if value <= 0 or value > 8 then
    value = 9
  end
  arr[index] = value
  -- Assume the user knows what they're doing.
  -- Don't bother fixing duplicates.
end

-- The utils module is not available when we're define R.optionsTable,
-- so just duplicate Highlight and HighlightAddon.
local function H(text)
  return "|cff1784d1"..text.."|r"
end
local function HA(text)
  return "|cff33ff99"..text.."|r"
end

local BUTTONS, RAIDLEAD, RAIDASSIST, PARTY, UI, CHAT, RESET = 100, 200, 300, 400, 500, 600, 700, 900

R.optionsTable = {
  type = "group",
  name = HA(A.name).." "..format(L["versionAuthor"], A.version, HA(A.author)),
  args = {
    desc = {
      order = 0,
      type = "description",
      name = L["options.widget.top.desc"].."|n",
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
          if not R.optionsGUI.obj.children[1] then
            -- The GUI tree does not exist any more.
            -- The player must have closed the options window immediately.
            return
          end
          for _, g in ipairs(R.optionsGUI.obj.children[1].frame.obj.children) do
            if g.type == "Button" then
              -- Enable right-click on all buttons in the options pane.
              g.frame:RegisterForClicks("AnyUp")
            end
          end
        end, DELAY_FIX_BUTTONS)
      end,
    },
    buttonCommandDefault = {
      order = BUTTONS+10,
      type = "execute",
      name = L["button.fixGroups.text"],
      desc = L["button.fixGroups.desc"],
      func = function(_, button) A.gui:ButtonPress(button) end,
      --disabled = function(i) return not IsInGroup() end,
    },
    buttonCommandSplit = {
      order = BUTTONS+20,
      type = "execute",
      name = L["button.splitGroups.text"],
      desc = L["button.splitGroups.desc"],
      func = function() A.console:Command("split") end,
      --disabled = function(i) return not IsInRaid() end,
    },
    buttonCommandHelp = {
      order = BUTTONS+30,
      type = "execute",
      name = L["button.commandInfo.text"],
      desc = format(L["button.commandInfo.desc"], H("/fg")),
      func = function() A.console:Command("help") end,
    },
    -- -------------------------------------------------------------------------
    headerUI = {
      order = UI,
      type = "header",
      name = L["options.header.uiAndChat"],
    },
    showMinimapIcon = {
      order = UI+10,
      name = L["options.widget.showMinimapIcon.text"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["options.value.always"],
        [2] = L["options.value.onlyWhenLeadOrAssist"],
        [3] = L["options.value.never"],
      },
      get = function(i) if A.options.showMinimapIconAlways then return 1 elseif A.options.showMinimapIconPRN then return 2 end return 3 end,
      set = function(i,v) A.options.showMinimapIconAlways, A.options.showMinimapIconPRN = (v==1), (v==2) A.gui:Refresh() end,
    },
    addButtonToRaidTab = {
      order = UI+20,
      name = L["options.widget.addButtonToRaidTab.text"],
      desc = format(L["options.widget.addButtonToRaidTab.desc"], H(L["button.fixGroups.text"])),
      type = "toggle",
      width = "full",
      get = function(i) return A.options.addButtonToRaidTab end,
      set = function(i,v) A.options.addButtonToRaidTab = v A.gui:Refresh() end,
    },
    -- -------------------------------------------------------------------------
    --headerCHAT = {
    --  order = CHAT,
    --  type = "header",
    --  name = ...,
    --},
    watchChat = {
      order = CHAT+10,
      name = L["options.widget.watchChat.text"],
      desc = format(L["options.widget.watchChat.desc"], H(L["chatKeyword.fixGroups"]), H(L["chatKeyword.markTanks"])),
      type = "toggle",
      width = "full",
      get = function(i) return A.options.watchChat end,
      set = function(i,v) A.options.watchChat = v end,
    },
    announceChat = {
      order = CHAT+20,
      name = L["options.widget.announceChat.text"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["options.value.always"],
        [2] = L["options.value.announceChatLimited"],
        [3] = L["options.value.never"],
      },
      get = function(i) if A.options.announceChatAlways then return 1 elseif A.options.announceChatPRN then return 2 end return 3 end,
      set = function(i,v) A.options.announceChatAlways, A.options.announceChatPRN = (v==1), (v==2) end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDLEAD = {
      order = RAIDLEAD,
      type = "header",
      name = L["options.header.raidLead"],
    },
    tankAssist = {
      order = RAIDLEAD+10,
      name = L["options.widget.tankAssist.text"],
      type = "toggle",
      width = "full",
      get = function(i) return A.options.tankAssist end,
      set = function(i,v) A.options.tankAssist = v end,
    },
    fixOfflineML = {
      order = RAIDLEAD+20,
      name = L["options.widget.fixOfflineML.text"],
      desc = L["options.widget.fixOfflineML.desc"],
      type = "toggle",
      width = "full",
      get = function(i) return A.options.fixOfflineML end,
      set = function(i,v) A.options.fixOfflineML = v end,
    },
    -- -------------------------------------------------------------------------
    headerRAIDASSIST = {
      order = RAIDASSIST,
      type = "header",
      name = L["options.header.raidAssist"],
    },
    sortMode = {
      order = RAIDASSIST+10,
      name = L["options.widget.sortMode.text"],
      desc = format(L["options.widget.sortMode.desc"], H("/fg meter"), H(L["button.fixGroups.text"])),
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["options.value.sortMode.TMURH"],
        [2] = L["options.value.sortMode.THMUR"],
        [3] = L["options.value.sortMode.meter"],
        [4] = L["options.value.sortMode.nosort"],
      },
      get = function(i)
        if A.options.sortMode == "nosort" then return 4
        elseif A.options.sortMode == "meter" then return 3
        elseif A.options.sortMode == "THMUR" then return 2
        else return 1
        end
      end,
      set = function(i,v)
        A.sorter:Stop()
        if v == 4 then A.options.sortMode = "nosort"
        elseif v == 3 then A.options.sortMode = "meter"
        elseif v == 2 then A.options.sortMode = "THMUR"
        else A.options.sortMode = "TMURH"
        end
      end,
    },
    resumeAfterCombat = {
      order = RAIDASSIST+20,
      name = L["options.widget.resumeAfterCombat.text"],
      type = "toggle",
      width = "full",
      get = function(i) return A.options.resumeAfterCombat end,
      set = function(i,v) A.sorter:Stop() A.options.resumeAfterCombat = v end,
    },
    tankMainTank = {
      order = RAIDASSIST+40,
      name = L["options.widget.tankMainTank.text"],
      desc = L["options.widget.tankMainTank.desc"],
      type = "select",
      width = "double",
      style = "dropdown",
      values = {
        [1] = L["options.value.always"],
        [2] = L["options.value.onlyInRaidInstances"],
        [3] = L["options.value.never"],
      },
      get = function(i) if A.options.tankMainTankAlways then return 1 elseif A.options.tankMainTankPRN then return 2 end return 3 end,
      set = function(i,v) A.options.tankMainTankAlways, A.options.tankMainTankPRN = (v==1), (v==2) end,
    },
    openRaidTab = {
      order = RAIDASSIST+50,
      name = L["options.widget.openRaidTab.text"],
      type = "toggle",
      width = "full",
      get = function(i) return A.options.openRaidTabPRN end,
      set = function(i,v) A.options.openRaidTabPRN = v end,
      disabled = function(i) return not A.options.tankMainTankAlways and not A.options.tankMainTankPRN end,
    },
    tankMark = {
      order = RAIDASSIST+60,
      name = L["options.widget.tankMark.text"],
      type = "toggle",
      width = "full",
      get = function(i) return A.options.tankMark end,
      set = function(i,v) A.options.tankMark = v end,
    },
    tankMarkIcon1 = {
      order = RAIDASSIST+60+1,
      name = L["options.widget.raidTank1.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 1) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 1, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon2 = {
      order = RAIDASSIST+60+2,
      name = L["options.widget.raidTank2.text"],
      desc = L["options.widget.raidTank.desc"],
       type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 2) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 2, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon3 = {
      order = RAIDASSIST+60+3,
      name = L["options.widget.raidTank3.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 3) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 3, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon4 = {
      order = RAIDASSIST+60+4,
      name = L["options.widget.raidTank4.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 4) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 4, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon5 = {
      order = RAIDASSIST+60+5,
      name = L["options.widget.raidTank5.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 5) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 5, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon6 = {
      order = RAIDASSIST+60+6,
      name = L["options.widget.raidTank6.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 6) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 6, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon7 = {
      order = RAIDASSIST+60+7,
      name = L["options.widget.raidTank7.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 7) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 7, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    tankMarkIcon8 = {
      order = RAIDASSIST+60+8,
      name = L["options.widget.raidTank8.text"],
      desc = L["options.widget.raidTank.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.tankMarkIcons, 8) end,
      set = function(i,v) setOptionMark(A.options.tankMarkIcons, 8, v) end,
      disabled = function(i) return not A.options.tankMark end,
    },
    splitOddEven = {
      order = RAIDASSIST+70,
      name = L["options.widget.splitOddEven.text"],
      desc = format(L["options.widget.splitOddEven.desc"], H("/fg split"), H(L["button.splitGroups.text"])),
      type = "toggle",
      width = "full",
      get = function(i) return A.options.splitOddEven end,
      set = function(i,v) A.sorter:Stop() A.options.splitOddEven = v end,
    },
    -- -------------------------------------------------------------------------
    headerPARTY = {
      order = PARTY,
      type = "header",
      name = L["options.header.party"],
    },
    partyMark = {
      order = PARTY+10,
      name = L["options.widget.partyMark.text"],
      desc = format(L["options.widget.partyMark.desc"], H(L["button.fixGroups.text"])),
      type = "toggle",
      width = "full",
      get = function(i) return A.options.partyMark end,
      set = function(i,v) A.options.partyMark = v end,
    },
    partyMarkIcon1 = {
      order = PARTY+10+1,
      name = L["options.widget.partyMarkIcon1.text"],
      desc = L["options.widget.partyMarkIcon1.desc"].."|n|n"..L["options.widget.partyMarkIcon.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.partyMarkIcons, 1) end,
      set = function(i,v) setOptionMark(A.options.partyMarkIcons, 1, v) end,
      disabled = function(i) return not A.options.partyMark end,
    },
    partyMarkIcon2 = {
      order = PARTY+10+2,
      name = L["options.widget.partyMarkIcon2.text"],
      desc = L["options.widget.partyMarkIcon2.desc"].."|n|n"..L["options.widget.partyMarkIcon.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.partyMarkIcons, 2) end,
      set = function(i,v) setOptionMark(A.options.partyMarkIcons, 2, v) end,
      disabled = function(i) return not A.options.partyMark end,
    },
    partyMarkIcon3 = {
      order = PARTY+10+3,
      name = L["options.widget.partyMarkIcon3.text"],
      desc = L["options.widget.partyMarkIcon.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.partyMarkIcons, 3) end,
      set = function(i,v) setOptionMark(A.options.partyMarkIcons, 3, v) end,
      disabled = function(i) return not A.options.partyMark end,
    },
    partyMarkIcon4 = {
      order = PARTY+10+4,
      name = L["options.widget.partyMarkIcon4.text"],
      desc = L["options.widget.partyMarkIcon.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.partyMarkIcons, 4) end,
      set = function(i,v) setOptionMark(A.options.partyMarkIcons, 4, v) end,
      disabled = function(i) return not A.options.partyMark end,
    },
    partyMarkIcon5 = {
      order = PARTY+10+5,
      name = L["options.widget.partyMarkIcon5.text"],
      desc = L["options.widget.partyMarkIcon.desc"],
      type = "select",
      width = "half",
      style = "dropdown",
      values = MARKS,
      get = function(i) return getOptionMark(A.options.partyMarkIcons, 5) end,
      set = function(i,v) setOptionMark(A.options.partyMarkIcons, 5, v) end,
      disabled = function(i) return not A.options.partyMark end,
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
      name = L["button.resetAllOptions.text"],
      func = function()
        -- Preserve the minimapIcon table. It's owned by LibDBIcon.
        local minimapIcon = A.options.minimapIcon
        A.db:ResetProfile()
        -- Update table reference.
        A.options = A.db.profile.options
        A.options.minimapIcon = minimapIcon
        A.console:Print(L["button.resetAllOptions.print"])
        A.gui:Refresh()
      end,
    },
  },
}

function M:OnInitialize()
  A.db = LibStub("AceDB-3.0"):New("FixGroupsDB", R.defaults, true)
  -- Intentionally overwriting the module reference.
  -- Can always do A:GetModule("options") if needed.
  A.options = A.db.profile.options

  LibStub("AceConfig-3.0"):RegisterOptionsTable(A.name, R.optionsTable)
  R.optionsGUI = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(A.name, A.name)
end
