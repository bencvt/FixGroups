local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true)

-- Basic words
L["versionAuthor"] = "v%s by %s"
L["word.and"] = "and"
L["word.or"] = "or"

-- Button labels
L["button.fixGroups.text"] = "Fix Groups"
L["button.fixGroups.desc"] = "The button on the raid tab and the minimap icon also work to fix groups."
L["button.fixGroups.working.text"] = "Rearranging..."
L["button.fixGroups.paused.text"] = "In Combat..."
L["button.splitGroups.text"] = "Split Groups"
L["button.splitGroups.desc"] = "Split raid into two sides based on overall damage/healing done."
L["button.commandInfo.text"] = "/fg argument list"
L["button.commandInfo.desc"] = "Print the various arguments for the %s console/macro command."
L["button.resetAllOptions.text"] = "Reset all options to default"
L["button.resetAllOptions.print"] = "All options reset to default."

-- Minimap icon and raid tab button tooltip
L["tooltip.header.raidComp"] = "raid: %s"
L["tooltip.left.clickLeft"] = "Left Click"
L["tooltip.left.clickRight"] = "Right Click"
L["tooltip.left.shiftClickLeft"] = "Hold Shift + Left Click"
L["tooltip.left.shiftClickRight"] = "Hold Shift + Right Click"
L["tooltip.left.ctrlClickLeft"] = "Hold Ctrl + Left Click"
L["tooltip.left.ctrlClickRight"] = "Hold Ctrl + Right Click"
L["tooltip.left.drag"] = "Hold Left Click + Drag"
L["tooltip.right.fixGroups"] = "Fix groups"
L["tooltip.right.split.1"] = "Split raid into two sides based on"
L["tooltip.right.split.2"] = "overall damage/healing done"
L["tooltip.right.config"] = "Open config"
L["tooltip.right.meter.1"] = "Fix groups, sorting by"
L["tooltip.right.meter.2"] = "overall damage/healing done"
L["tooltip.right.nosort"] = "Fix tanks and ML only, no sorting"
L["tooltip.right.moveMinimapIcon"] = "Move minimap icon"

-- Options module: dropdown values
L["options.value.noMark"] = "none"
L["options.value.always"] = "Always"
L["options.value.never"] = "Never"
L["options.value.onlyWhenLeadOrAssist"] = "Only when lead or assist"
L["options.value.onlyInRaidInstances"] = "Only in raid instances"
L["options.value.announceChatLimited"] = "Only after changing group sorting method"
L["options.value.sortMode.TMURH"] = "Tanks > Melee > Ranged > Healers"
L["options.value.sortMode.THMUR"] = "Tanks > Healers > Melee > Ranged"
L["options.value.sortMode.meter"] = "Overall damage/healing done"
L["options.value.sortMode.nosort"] = "Do not rearrange players"

-- Options module: headers and widgets
L["options.widget.top.desc"] = "Organizing groups is an important, if sometimes tedious, part of running a raid. This addon helps automate the process."

L["options.header.raidLead"] = "When raid leader"
L["options.widget.tankAssist.text"] = "Give tanks assist"
L["options.widget.fixOfflineML.text"] = "Fix offline master looter"
L["options.widget.fixOfflineML.desc"] = "If the master looter is offline, make yourself the master looter instead."

L["options.header.raidAssist"] = "When raid leader or assist"
L["options.widget.sortMode.text"] = "Rearrange players"
L["options.widget.sortMode.desc"] = "The overall damage/healing done sort method will only work if Recount, Skada, or Details! is running.|n|nThis sort method can be useful for making quick decisions on who's worth an emergency heal or brez in PUGs.|n|nYou can also type %s or shift right click the minimap icon (or %s button) to do a one-off sort without changing the setting."
L["options.widget.resumeAfterCombat.text"] = "Resume rearranging players when interrupted by combat"
L["options.widget.tankMainTank.text"] = "Check whether main tanks are set"
L["options.widget.tankMainTank.desc"] = "Unfortunately WoW does not allow addons to automatically set main tanks, but we can check for it at least."
L["options.widget.openRaidTab.text"] = "Open raid tab when main tank needs to be set"
L["options.widget.tankMark.text"] = "Put target markers on tanks"
L["options.widget.raidTank1.text"] = "Tank 1"
L["options.widget.raidTank2.text"] = "Tank 2"
L["options.widget.raidTank3.text"] = "Tank 3"
L["options.widget.raidTank4.text"] = "Tank 4"
L["options.widget.raidTank5.text"] = "Tank 5"
L["options.widget.raidTank6.text"] = "Tank 6"
L["options.widget.raidTank7.text"] = "Tank 7"
L["options.widget.raidTank8.text"] = "Tank 8"
L["options.widget.raidTank.desc"] = "Tanks are sorted alphabetically."
L["options.widget.splitOddEven.text"] = "When splitting groups, use odd/even groups"
L["options.widget.splitOddEven.desc"] = "If this option is not checked then groups will be adjacent instead (i.e., 1-2 and 3-4, 1-3 and 4-6, or 1-4 and 5-8.)|n|nTo split groups, type %s, click the %s button, or right click the minimap icon."

L["options.header.party"] = "When in party (5 man content)"
L["options.widget.partyMark.text"] = "Put target markers on party members"
L["options.widget.partyMark.desc"] = "Click the minimap icon or %s button icon a second time to clear the marks."
L["options.widget.partyMarkIcon1.text"] = "Tank"
L["options.widget.partyMarkIcon1.desc"] = "Or the 1st party member, if there is no tank (e.g., arenas)."
L["options.widget.partyMarkIcon2.text"] = "Healer"
L["options.widget.partyMarkIcon2.desc"] = "Or the 2nd party member, if there is no healer."
L["options.widget.partyMarkIcon3.text"] = "DPS 1"
L["options.widget.partyMarkIcon4.text"] = "DPS 2"
L["options.widget.partyMarkIcon5.text"] = "DPS 3"
L["options.widget.partyMarkIcon.desc"] = "Party members are sorted alphabetically."

L["options.header.uiAndChat"] = "User interface and chat"
L["options.widget.showMinimapIcon.text"] = "Show minimap icon"
L["options.widget.addButtonToRaidTab.text"] = "Add button to raid tab"
L["options.widget.addButtonToRaidTab.desc"] = "Add a %s button to the default Blizzard UI on the raid tab, functioning the same as the minimap icon. The default keybind to open the raid tab is O."
L["options.widget.watchChat.text"] = "Watch chat for requests to fix groups"
L["options.widget.watchChat.desc"] = "When the keywords %s or %s are seen in chat while not in combat, automatically open the raid tab."
L["options.widget.announceChat.text"] = "Announce when players have been rearranged to instance chat"

-- Chat keywords
L["chatKeyword.fixGroups"] = "fix groups"
L["chatKeyword.markTanks"] = "mark tanks"

-- Console module
L["console.help.header"] = "Arguments for the %s command (or %s):"
L["console.help.help"] = "you're reading it"
L["console.help.config"] = "same as Esc>Interface>AddOns>%s"
L["console.help.seeChoose"] = "choose a random player or option, see %s"
L["console.help.cancel"] = "stop rearranging players"
L["console.help.nosort"] = "fix groups, no sorting"
L["console.help.meter"] = "fix groups, sort by overall damage/healing done"
L["console.help.split"] = "split raid into two sides based on overall damage/healing done"
L["console.help.blank"] = "fix groups"
L["console.print.notInRaid"] = "Groups can only be sorted while in a raid."
L["console.print.badArgument"] = "Unknown argument %s. Type %s for valid arguments."

-- Choose module
L["choose.help.header"] = "Arguments for the %s command (or %s):"
L["choose.help.option.arg"] = "<option1>, <option2>[, <option3> etc.]"
L["choose.help.option"] = "choose a random option"
L["choose.help.role.arg"] = "<role>"
L["choose.help.role"] = "choose a random player, role can be %s"
L["choose.help.class.arg"] = "<class>"
L["choose.help.class"] = "choose a random player of a particular class"
L["choose.help.class.arg"] = "<class>"
L["choose.help.token.arg"] = "<token>"
L["choose.help.token"] = "choose a random player on a particular tier token: %s"
L["choose.help.blank"] = "choose any random player"
L["choose.help.examples"] = "Type %s for examples."
L["choose.examples.header"] = "Here are some ways to use the %s command:"
L["choose.print.choosing.option"] = "Choosing a random option."
L["choose.print.choosing.player"] = "Choosing a random player."
L["choose.print.choosing.class"] = "Choosing a random %s."
L["choose.print.choosing.token"] = "Choosing a random %s."
L["choose.print.choosing.tank"] = "Choosing a random tank."
L["choose.print.choosing.healer"] = "Choosing a random healer."
L["choose.print.choosing.dps"] = "Choosing a random DPS."
L["choose.print.choosing.ranged"] = "Choosing a random ranged."
L["choose.print.choosing.melee"] = "Choosing a random melee."
L["choose.print.busy"] = "You already have a roll in progress. Please wait a couple seconds."
L["choose.print.noPlayers"] = "There aren't any such players in your group."
L["choose.print.chose.option"] = "Chose option #%d: %s."
L["choose.print.chose.player"] = "Chose option #%d: %s in group %d."
L["choose.print.badArgument"] = "Unknown argument %s. Type %s for valid arguments."

L["choose.role.any"] = "any"
L["choose.role.tank"] = "tank"
L["choose.role.healer"] = "healer"
L["choose.role.damager"] = "dps"
L["choose.role.melee"] = "melee"
L["choose.role.ranged"] = "ranged"
L["choose.tierToken.conqueror"] = "Conqueror"
L["choose.tierToken.conqueror.short"] = "conq"
L["choose.tierToken.protector"] = "Protector"
L["choose.tierToken.protector.short"] = "prot"
L["choose.tierToken.vanquisher"] = "Vanquisher"
L["choose.tierToken.vanquisher.short"] = "vanq"

-- AddonChannel module
L["addonChannel.print.newerVersion"] = "%s version %s is available. You're currently running version %s."

-- Marker module
L["marker.print.needSetMainTank"] = "%s is not set as main tank!"
L["marker.print.needSetMainTanks"] = "%s are not set as main tanks!"
L["marker.print.needClearMainTank"] = "%s is incorrectly set as main tank!"
L["marker.print.needClearMainTanks"] = "%s are incorrectly set as main tanks!"
L["marker.print.useRaidTab"] = "To fix tanks, use the raid tab. WoW addons cannot set main tanks."
L["marker.print.openRaidTab"] = "To fix tanks, press O to open the raid tab. WoW addons cannot set main tanks."

-- Sorter module
L["sorter.print.combatPaused"] = "Rearranging players paused due to combat."
L["sorter.print.combatCancelled"] = "Rearranging players cancelled due to combat."
L["sorter.print.combatResumed"] = "Resumed rearranging players."
L["sorter.print.timedOut"] = "Stopped rearranging players because it's taking too long. Perhaps someone else is simultaneously rearranging players?"
L["sorter.print.needRank"] = "You must be a raid leader or assistant to fix groups."
L["sorter.print.alreadySplit"] = "No change - the raid is already split."
L["sorter.print.alreadySorted"] = "No change - the raid is already sorted."
L["sorter.print.split"] = "Split players: groups %s."
L["sorter.print.meter"] = "Rearranged players by damage/healing done."
L["sorter.print.TMURH"] = "Rearranged tanks>melee>ranged>healers."
L["sorter.print.THMUR"] = "Rearranged tanks>healers>melee>ranged."
L["sorter.print.excludedSitting.singular"] = "Excluded 1 player sitting in groups %d-8."
L["sorter.print.excludedSitting.plural"] = "Excluded %d players sitting in groups %d-8."

-- Meter module
L["meter.print.noAddon"] = "No supported damage/healing meter addon found."
L["meter.print.usingDataFrom"] = "Using damage/healing data from %s."
L["meter.print.noDataFrom"] = "There is currently no data available from %s."
