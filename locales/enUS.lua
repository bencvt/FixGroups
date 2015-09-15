local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true)

-- Basic letters, words, phrases, and character names
L["letter.1"] = "A"
L["letter.2"] = "B"
L["letter.3"] = "C"

L["word.and"] = "and"
L["word.or"] = "or"
L["word.raid"] = "Raid"
L["word.party"] = "Party"
L["word.none"] = "none"
L["word.alias.singular"] = "Alias"
L["word.alias.plural"] = "Aliases"
L["word.tank.singular"] = "Tank"
L["word.tank.plural"] = "Tanks"
L["word.healer.singular"] = "Healer"
L["word.healer.plural"] = "Healers"
L["word.damager.singular"] = "Damage"
L["word.damager.plural"] = "Damage"
L["word.melee.singular"] = "Melee"
L["word.melee.plural"] = "Melee"
L["word.ranged.singular"] = "Ranged"
L["word.ranged.plural"] = "Ranged"
L["word.unknown.singular"] = "Unknown"
L["word.unknown.plural"] = "Unknown"

L["phrase.versionAuthor"] = "v%s by %s"
L["phrase.groupComp"] = "Group Comp"
L["phrase.waitingOnDataFromServerFor"] = "Waiting on data from the server for %s."
L["phrase.assumingRangedForNow.singular"] = "Assuming they're ranged for now."
L["phrase.assumingRangedForNow.plural"] = "Assuming they're ranged for now."
L["phrase.mouse.clickLeft"] = "Left Click"
L["phrase.mouse.clickRight"] = "Right Click"
L["phrase.mouse.shiftClickLeft"] = "Hold Shift + Left Click"
L["phrase.mouse.shiftClickRight"] = "Hold Shift + Right Click"
L["phrase.mouse.ctrlClickLeft"] = "Hold Ctrl + Left Click"
L["phrase.mouse.ctrlClickRight"] = "Hold Ctrl + Right Click"
L["phrase.mouse.drag"] = "Hold Left Click + Drag"
L["phrase.print.badArgument"] = "Unknown argument %s. Type %s for valid arguments."
L["phrase.print.notInRaid"] = "Groups can only be sorted while in a raid."

L["character.thrall"] = "Thrall"
L["character.liadrin"] = "Liadrin"
L["character.velen"] = "Velen"

-- AddonChannel module
L["addonChannel.print.newerVersion"] = "%s version %s is available. You're currently running version %s."

-- Button labels
L["button.close.text"] = "Close"
L["button.fixGroups.text"] = "Fix Groups"
L["button.fixGroups.desc"] = "The button on the raid tab and the minimap icon also work to fix groups."
L["button.fixGroups.working.text"] = "Rearranging..."
L["button.fixGroups.paused.text"] = "In Combat..."
L["button.splitGroups.text"] = "Split Groups"
L["button.splitGroups.desc"] = "Split raid into two sides based on overall damage/healing done."
L["button.resetAllOptions.text"] = "Reset all options to default"
L["button.resetAllOptions.print"] = "All options reset to default."

-- Choose module
L["choose.choosing.tooltip"] = "Choose a random %s."
L["choose.choosing.print"] = "Choosing a random %s..."
L["choose.list.tooltip"] = "List every %s."
L["choose.list.print"] = "List of every %s:"
L["choose.print.choosing.option"] = "option"
L["choose.print.choosing.group"] = "group with players in it"
L["choose.print.choosing.sitting"] = "player sitting in group %s"
L["choose.print.choosing.sitting.noGroups"] = "sitting player"
L["choose.print.choosing.notMe"] = "player other than %s"
L["choose.print.choosing.guildmate"] = "<%s> member in the group"
L["choose.print.choosing.guildmate.noGuild"] = "guildmate in the group, if you were in a guild"
L["choose.print.choosing.armor"] = "%s wearer"
L["choose.print.choosing.primaryStat"] = "%s user"
L["choose.print.choosing.fromGroup"] = "player from group %d"
L["choose.print.choosing.dead"] = "dead player"
L["choose.print.choosing.alive"] = "living player"
L["choose.print.choosing.any"] = "player"
L["choose.print.choosing.anyIncludingSitting"] = "player, including sitting players"
L["choose.print.last"] = "Repeat the last command%s."
L["choose.print.busy"] = "You already have a roll in progress. Please wait a couple seconds."
L["choose.print.noPlayers"] = "There aren't any such players in the group."
L["choose.print.noLastCommand"] = "There is no previous %s command."
L["choose.print.chose.option"] = "Chose option #%d: %s."
L["choose.print.chose.player"] = "Chose option #%d: %s in group %d."

L["choose.modeAliases.gui"] = "gui,window"
L["choose.modeAliases.group"] = "group,party"
L["choose.modeAliases.fromGroup"] = "g,group,party"
L["choose.modeAliases.guildmate"] = "guildmate,guildie,guildy,guild"
L["choose.modeAliases.any"] = "any,anyone,anybody,someone,somebody,player"
L["choose.modeAliases.sitting"] = "sitting,benched,bench,standby,inactive,idle"
L["choose.modeAliases.anyIncludingSitting"] = "any+sitting,any|sitting,any/sitting,anysitting,anyIncludingSitting"
L["choose.modeAliases.notMe"] = "notMe,somebodyElse,someoneElse"
L["choose.modeAliases.dead"] = "dead"
L["choose.modeAliases.alive"] = "alive,live,living"
L["choose.modeAliases.tank"] = "tank"
L["choose.modeAliases.healer"] = "healer,heal"
L["choose.modeAliases.damager"] = "dps,damage,damager,dd"
L["choose.modeAliases.melee"] = "melee"
L["choose.modeAliases.ranged"] = "ranged,range"
L["choose.modeAliases.conqueror"] = "Conqueror,conq"
L["choose.modeAliases.protector"] = "Protector,prot"
L["choose.modeAliases.vanquisher"] = "Vanquisher,vanq"
L["choose.modeAliases.intellect"] = "intellect,intel,int"
L["choose.modeAliases.agility"] = "agility,agi"
L["choose.modeAliases.strength"] = "strength,str"
L["choose.modeAliases.cloth"] = "cloth,clothie"
L["choose.modeAliases.leather"] = "leather"
L["choose.modeAliases.mail"] = "mail"
L["choose.modeAliases.plate"] = "plate"
L["choose.modeAliases.last"] = "last,again,previous,prev,repeat"
L["choose.classAliases.warrior"] = "warr"
L["choose.classAliases.deathknight"] = "dk"
L["choose.classAliases.paladin"] = "pal,pala,pally"
L["choose.classAliases.monk"] = ","
L["choose.classAliases.priest"] = ","
L["choose.classAliases.shaman"] = "sham,shammy"
L["choose.classAliases.druid"] = ","
L["choose.classAliases.rogue"] = ","
L["choose.classAliases.mage"] = ","
L["choose.classAliases.warlock"] = "lock"
L["choose.classAliases.hunter"] = ","
L["choose.classAliases.demonhunter"] = "dh"

-- DataBroker module
L["dataBroker.groupComp.notInGroup"] = "not in group"
L["dataBroker.groupComp.sitting"] = "Sitting in group %s"
L["dataBroker.groupComp.groupQueued"] = "Your group is queued in LFG."
L["dataBroker.groupComp.openRaidTab"] = "Open Raid Tab"

-- Generic GUI modules
L["gui.chatKeywords"] = "fix groups,mark tanks,set tanks"
L["gui.title"] = "%s command"
L["gui.header.buttons"] = "%s command arguments"
L["gui.header.examples"] = "Examples of the %s command in action"

-- Choose GUI module
L["gui.choose.intro"] = "Need to flip a coin to make a decision? Use the %s command to randomly select an option or a player. The choice will be instant, transparent, and fair thanks to WoW's built-in /roll command."
L["gui.list.intro"] = "The %s command works exactly the same as the %s command, except that it stops short of doing a /roll."
L["gui.choose.note.multipleClasses"] = "You also can specify multiple classes. For example: %s."
L["gui.choose.note.option.1"] = "To choose from a list of generic options rather than a player meeting certain criteria, simply list them after the %s command."
L["gui.choose.note.option.2"] = "You can use commas or spaces to separate the options."

-- FixGroups GUI module
L["gui.fixGroups.intro"] = "The %s (or %s) command allows you to control the addon without using the GUI. You can use this in a macro, or just type it in chat."
L["gui.fixGroups.help.sort"] = "Rearrange players using the default sort method."
L["gui.fixGroups.help.note.defaultMode"] = "The default sort method is currently %s. It can be changed in the config."
L["gui.fixGroups.help.nosort"] = "Fix tanks and ML only, no sorting."
L["gui.fixGroups.help.split"] = "Split raid into two sides based on overall damage/healing done."
L["gui.fixGroups.help.cancel"] = "Stop rearranging players."
L["gui.fixGroups.help.clear1"] = "Clear players out of group 1."
L["gui.fixGroups.help.clear2"] = "Clear players out of groups 1 and 2."
L["gui.fixGroups.help.skip1"] = "Exclude any players that you have placed in group 1."
L["gui.fixGroups.help.skip2"] = "Exclude any players that you have placed in groups 1 or 2."
L["gui.fixGroups.help.note.clearSkip"] = "This can be useful for raid encounters that require assigning a group or groups of players to handle a certain mechanic. E.g., nether banish groups on Archimonde."
L["gui.fixGroups.help.choose"] = "Choose a random player or option."
L["gui.fixGroups.help.list"] = "List players matching a certain criteria to raid chat."
L["gui.fixGroups.help.listself"] = "List players matching a certain criteria to yourself."
L["gui.fixGroups.help.note.sameAsCommand"] = "Same as the %s command."
L["gui.fixGroups.help.note.sameAsLeftClicking"] = "Same as left-clicking the minimap icon or the %s button in the raid tab."
L["gui.fixGroups.help.config"] = "Same as %s>Interface>AddOns>%s."
L["gui.fixGroups.help.note.meter.1"] = "Overall damage/healing data requires %s to be running."
L["gui.fixGroups.help.note.meter.2"] = "This sort method can be useful for making quick decisions on who's worth an emergency heal or brez in PUGs."

-- Marker module
L["marker.print.needSetMainTank.singular"] = "%s is not set as main tank!"
L["marker.print.needSetMainTank.plural"] = "%s are not set as main tanks!"
L["marker.print.needClearMainTank.singular"] = "%s is incorrectly set as main tank!"
L["marker.print.needClearMainTank.plural"] = "%s are incorrectly set as main tanks!"
L["marker.print.useRaidTab"] = "To fix tanks, use the raid tab. WoW addons cannot set main tanks."
L["marker.print.openRaidTab"] = "To fix tanks, press %s to open the raid tab. WoW addons cannot set main tanks."

-- Meter module
L["meter.print.noAddon"] = "No supported damage/healing meter addon found."
L["meter.print.usingDataFrom"] = "Using damage/healing data from %s."
L["meter.print.noDataFrom"] = "There is currently no data available from %s."

-- Options module: dropdown values
L["options.value.noMark"] = "none"
L["options.value.always"] = "Always"
L["options.value.never"] = "Never"
L["options.value.onlyWhenLeadOrAssist"] = "Only when lead or assist"
L["options.value.onlyInRaidInstances"] = "Only in raid instances"
L["options.value.announceChatLimited"] = "Only after changing group sorting method"
L["options.value.sortMode.meter"] = "Overall damage/healing done"
L["options.value.sortMode.nosort"] = "Do not rearrange players"

-- Options module: tabs
L["options.tab.main"] = "Main"
L["options.tab.sorting"] = "Sorting"
L["options.tab.marking"] = "Marking"
L["options.tab.userInterface"] = "User Interface"

-- Options module: headers and widgets
L["options.widget.top.desc"] = "Organizing groups is an important, if sometimes tedious, part of running a raid. %s helps automate the process."

L["options.header.console"] = "Console commands"

L["options.header.raidLead"] = "When raid leader"
L["options.widget.tankAssist.text"] = "Give tanks assist"
L["options.widget.fixOfflineML.text"] = "Fix offline master looter"
L["options.widget.fixOfflineML.desc"] = "If the master looter is offline, make yourself the master looter instead."

L["options.header.raidAssist"] = "When raid leader or assist"
L["options.widget.sortMode.text"] = "Default sort method"
L["options.widget.resumeAfterCombat.text"] = "Resume rearranging players when interrupted by combat"
L["options.widget.tankMainTank.text"] = "Check whether main tanks are set"
L["options.widget.tankMainTank.desc"] = "Unfortunately WoW does not allow addons to automatically set main tanks, but we can check for it at least."
L["options.widget.openRaidTab.text"] = "Open raid tab when main tank needs to be set"
L["options.widget.tankMark.text"] = "Put target markers on tanks"
L["options.widget.raidTank.desc"] = "Tanks are sorted alphabetically."
L["options.widget.clearRaidMarks.text"] = "Clear target markers from all other raid members"
L["options.widget.splitOddEven.text"] = "When splitting groups, use odd/even groups"
L["options.widget.splitOddEven.desc.1"] = "If this option is not checked then groups will be adjacent instead (i.e., 1-2 and 3-4, 1-3 and 4-6, or 1-4 and 5-8.)"
L["options.widget.splitOddEven.desc.2"] = "To split groups, type %s, click the %s button, or right click the minimap icon."
L["options.widget.showExtraSortModes.text"] = "Show extra sort methods"

L["options.header.party"] = "When in party (5 man content)"
L["options.widget.partyMark.text"] = "Put target markers on party members"
L["options.widget.partyMark.desc"] = "Click the minimap icon or %s button icon a second time to clear the marks."
L["options.widget.partyMarkIcon1.desc"] = "Or the 1st party member, if there is no tank (e.g., arenas)."
L["options.widget.partyMarkIcon2.desc"] = "Or the 2nd party member, if there is no healer."
L["options.widget.partyMarkIcon.desc"] = "Party members are sorted alphabetically."

L["options.widget.showMinimapIcon.text"] = "Show minimap icon"
L["options.widget.addButtonToRaidTab.text"] = "Add button to raid tab"
L["options.widget.addButtonToRaidTab.desc"] = "Add a %s button to the default Blizzard UI on the raid tab, functioning the same as the minimap icon. The keybind to open the raid tab is %s."
L["options.widget.watchChat.text"] = "Watch chat for requests to fix groups"
L["options.widget.watchChat.desc"] = "When the keywords %s are seen in chat while not in combat, automatically open the raid tab."
L["options.widget.announceChat.text"] = "Announce when players have been rearranged to instance chat"
L["options.widget.roleIconStyle.text"] = "Role icon style"
L["options.widget.roleIconSize.text"] = "Role icon size"

L["options.header.sysMsg"] = "Enhance Joined/Left Messages"
L["options.widget.sysMsg.desc"] = "The system message that appears whenever a player joins or leaves a group can be modified to make it more informative."
L["options.widget.sysMsgClassColor.text"] = "Add class color"
L["options.widget.sysMsgRoleName.text"] = "Add role name"
L["options.widget.sysMsgRoleIcon.text"] = "Add role icon"
L["options.widget.sysMsgGroupComp.text"] = "Add new group comp"
L["options.widget.sysMsgGroupCompHighlight.text"] = "Highlight new group comp"

L["options.header.interop"] = "Data Broker"
L["options.widget.dataBrokerGroupCompStyle.text"] = "%s display style"
L["options.widget.dataBrokerGroupCompStyle.desc.1"] = "%s is available as a Data Broker object (a.k.a. an LDB plugin). If you're running an addon that displays Data Broker objects, you can have the group comp on the screen at all times."
L["options.widget.dataBrokerGroupCompStyle.desc.2"] = "There are many Data Broker display addons out there. Some of the more popular ones are %s."

-- Sorter module
L["sorter.mode.meter"] = "by damage/healing done"
L["sorter.mode.tmrh"] = "tanks>melee>ranged>healers"
L["sorter.mode.thmr"] = "tanks>healers>melee>ranged"
L["sorter.mode.nosort"] = "no sorting"
L["sorter.mode.split"] = "raid into split halves"
L["sorter.mode.alpha"] = "by player name, A-Z"
L["sorter.mode.ralpha"] = "by player name, Z-A"
L["sorter.mode.random"] = "at random"

L["sorter.print.notUseful"] = "Some sort methods are not very useful for organizing a raid, but they're available for the sake of completeness."
L["sorter.print.notActive"] = "You are not currently rearranging the group."
L["sorter.print.groupDisbanding"] = "Rearranging cancelled because the group appears to be disbanding."
L["sorter.print.combatPaused"] = "Rearranging %s paused due to combat."
L["sorter.print.combatCancelled"] = "Rearranging %s cancelled due to combat."
L["sorter.print.combatResumed"] = "Resumed rearranging %s."
L["sorter.print.manualCancel"] = "Rearranging %s cancelled."
L["sorter.print.yieldToRaidOfficer"] = "Rearranging %s cancelled to let %s rearrange instead."
L["sorter.print.timedOut"] = "Rearranging %s cancelled because it's taking too long. Perhaps someone else is simultaneously rearranging players?"
L["sorter.print.needRank"] = "You must be a raid leader or assistant to fix groups."
L["sorter.print.alreadySplit"] = "No change - the raid is already split."
L["sorter.print.alreadySorted"] = "No change - the raid is already sorted %s."
L["sorter.print.split"] = "Split players: groups %s."
L["sorter.print.sorted"] = "Rearranged %s."
L["sorter.print.excludedSitting.singular"] = "Excluded 1 player sitting in group %s."
L["sorter.print.excludedSitting.plural"] = "Excluded %d players sitting in group %s."

-- Tooltips for minimap icon and raid tab button
L["tooltip.right.fixGroups"] = "Rearrange players"
L["tooltip.right.gui"] = "Other sort methods"
L["tooltip.right.moveMinimapIcon"] = "Move minimap icon"
L["tooltip.right.meter.1"] = "Fix groups, sorting by"
L["tooltip.right.meter.2"] = "overall damage/healing done"
L["tooltip.right.nosort"] = "Fix tanks and ML only, no sorting"
L["tooltip.right.split.1"] = "Split raid into two sides based on"
L["tooltip.right.split.2"] = "overall damage/healing done"
L["tooltip.right.config"] = "Open config"
