local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true)

-- Basic letters, words, phrases, and character names
L["letter.1"] = "A"
L["letter.2"] = "B"
L["letter.3"] = "C"

L["word.and"] = "and"
L["word.or"] = "or"
L["word.raid"] = "raid"
L["word.party"] = "party"
L["word.none"] = "none"
L["word.alias.singular"] = "Alias"
L["word.alias.plural"] = "Aliases"
L["word.tank.singular"] = "Tank"
L["word.tank.plural"] = "Tanks"
L["word.healer.singular"] = "Healer"
L["word.healer.plural"] = "Healers"
L["word.damager.singular"] = "DPS"
L["word.damager.plural"] = "DPS"
L["word.melee.singular"] = "Melee"
L["word.melee.plural"] = "Melee"
L["word.ranged.singular"] = "Ranged"
L["word.ranged.plural"] = "Ranged"
L["word.unknown.singular"] = "Unknown"
L["word.unknown.plural"] = "Unknown"

L["phrase.versionAuthor"] = "v%s by %s"
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

L["character.thrall"] = "Thrall"

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
L["button.fixGroupsHelp.desc.1"] = "The %s (or %s) command allows you to control the addon without using the GUI. You can use this in a macro, or just type it in chat."
L["button.fixGroupsHelp.desc.2"] = "Click this button to run %s, which will show you the various arguments."
L["button.resetAllOptions.text"] = "Reset all options to default"
L["button.resetAllOptions.print"] = "All options reset to default."

-- Chat keywords
L["chatKeyword.fixGroups"] = "fix groups"
L["chatKeyword.markTanks"] = "mark tanks"

-- Choose module
L["choose.print.choosing.option"] = "Choosing a random option..."
L["choose.print.choosing.group"] = "Choosing a random group with players in it..."
L["choose.print.choosing.sitting"] = "Choosing a random player sitting in groups %d-8..."
L["choose.print.choosing.sitting.noGroups"] = "Choosing a random sitting player..."
L["choose.print.choosing.notMe"] = "Choosing a random player other than %s..."
L["choose.print.choosing.guildmate"] = "Choosing a random <%s> member in the group..."
L["choose.print.choosing.guildmate.noGuild"] = "Choosing a random guildmate in the group, if you were in a guild..."
L["choose.print.choosing.armor"] = "Choosing a random %s wearer (%s)..."
L["choose.print.choosing.primaryStat"] = "Choosing a random %s user (%s)..."
L["choose.print.choosing.fromGroup"] = "Choosing a random player from group %d..."
L["choose.print.choosing.dead"] = "Choosing a random dead player..."
L["choose.print.choosing.alive"] = "Choosing a random living player..."
L["choose.print.choosing.any"] = "Choosing a random player..."
L["choose.print.choosing.anyIncludingSitting"] = "Choosing a random player, including sitting players..."
L["choose.print.choosing.class"] = "Choosing a random %s..."
L["choose.print.choosing.tierToken"] = "Choosing a random %s (%s)..."
L["choose.print.choosing.tank"] = "Choosing a random tank..."
L["choose.print.choosing.healer"] = "Choosing a random healer..."
L["choose.print.choosing.damager"] = "Choosing a random DPS..."
L["choose.print.choosing.ranged"] = "Choosing a random ranged..."
L["choose.print.choosing.melee"] = "Choosing a random melee..."
L["choose.print.choosing.last"] = "Repeating the last %s command..."
L["choose.print.busy"] = "You already have a roll in progress. Please wait a couple seconds."
L["choose.print.noPlayers"] = "There aren't any such players in your group."
L["choose.print.noLastCommand"] = "There is no previous %s command."
L["choose.print.chose.option"] = "Chose option #%d: %s."
L["choose.print.chose.player"] = "Chose option #%d: %s in group %d."
L["choose.print.badArgument"] = "Unknown argument %s. Type %s for valid arguments."

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
L["choose.modeAliases.damager"] = "dps,dd,damager,damage"
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

-- Choose GUI module
L["choose.gui.title"] = "%s command"
L["choose.gui.intro"] = "Need to flip a coin to make a decision? Use the %s command to randomly select an option or a player. The choice will be instant, transparent, and fair thanks to WoW's built-in /roll command."
L["choose.gui.header.buttons"] = "%s command arguments"
L["choose.gui.header.examples"] = "Examples of the %s command in action"
L["choose.gui.note.multipleClasses"] = "You also can specify multiple classes. For example: %s."
L["choose.gui.note.option.1"] = "To choose from a list of generic options rather than a player meeting certain criteria, simply list them after the %s command."
L["choose.gui.note.option.2"] = "You can use commas or spaces to separate the options."

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

-- DataBroker module
L["dataBroker.groupComp.name"] = "Group Comp"
L["dataBroker.groupComp.notInGroup"] = "not in group"
L["dataBroker.groupComp.sitting"] = "Sitting in groups %d-8"
L["dataBroker.groupComp.groupQueued"] = "Your group is queued in LFG."
L["dataBroker.groupComp.openRaidTab"] = "Open Raid Tab"

-- Marker module
L["marker.print.needSetMainTank.singular"] = "%s is not set as main tank!"
L["marker.print.needSetMainTank.plural"] = "%s are not set as main tanks!"
L["marker.print.needClearMainTank.singular"] = "%s is incorrectly set as main tank!"
L["marker.print.needClearMainTank.plural"] = "%s are incorrectly set as main tanks!"
L["marker.print.useRaidTab"] = "To fix tanks, use the raid tab. WoW addons cannot set main tanks."
L["marker.print.openRaidTab"] = "To fix tanks, press O to open the raid tab. WoW addons cannot set main tanks."

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

-- Options module: headers and widgets
L["options.widget.top.desc"] = "Organizing groups is an important, if sometimes tedious, part of running a raid. This addon helps automate the process."

L["options.header.console"] = "Console commands"

L["options.header.raidLead"] = "When raid leader"
L["options.widget.tankAssist.text"] = "Give tanks assist"
L["options.widget.fixOfflineML.text"] = "Fix offline master looter"
L["options.widget.fixOfflineML.desc"] = "If the master looter is offline, make yourself the master looter instead."

L["options.header.raidAssist"] = "When raid leader or assist"
L["options.widget.sortMode.text"] = "Rearrange players"
L["options.widget.sortMode.desc.1"] = "The overall damage/healing done sort method will only work if %s is running."
L["options.widget.sortMode.desc.2"] = "This sort method can be useful for making quick decisions on who's worth an emergency heal or brez in PUGs."
L["options.widget.sortMode.desc.3"] = "You can also type %s or shift right click the minimap icon (or %s button) to do a one-off sort without changing the setting."
L["options.widget.resumeAfterCombat.text"] = "Resume rearranging players when interrupted by combat"
L["options.widget.tankMainTank.text"] = "Check whether main tanks are set"
L["options.widget.tankMainTank.desc"] = "Unfortunately WoW does not allow addons to automatically set main tanks, but we can check for it at least."
L["options.widget.openRaidTab.text"] = "Open raid tab when main tank needs to be set"
L["options.widget.tankMark.text"] = "Put target markers on tanks"
L["options.widget.raidTank.desc"] = "Tanks are sorted alphabetically."
L["options.widget.splitOddEven.text"] = "When splitting groups, use odd/even groups"
L["options.widget.splitOddEven.desc.1"] = "If this option is not checked then groups will be adjacent instead (i.e., 1-2 and 3-4, 1-3 and 4-6, or 1-4 and 5-8.)"
L["options.widget.splitOddEven.desc.2"] = "To split groups, type %s, click the %s button, or right click the minimap icon."

L["options.header.party"] = "When in party (5 man content)"
L["options.widget.partyMark.text"] = "Put target markers on party members"
L["options.widget.partyMark.desc"] = "Click the minimap icon or %s button icon a second time to clear the marks."
L["options.widget.partyMarkIcon1.desc"] = "Or the 1st party member, if there is no tank (e.g., arenas)."
L["options.widget.partyMarkIcon2.desc"] = "Or the 2nd party member, if there is no healer."
L["options.widget.partyMarkIcon.desc"] = "Party members are sorted alphabetically."

L["options.header.uiAndChat"] = "User interface and chat"
L["options.widget.showMinimapIcon.text"] = "Show minimap icon"
L["options.widget.addButtonToRaidTab.text"] = "Add button to raid tab"
L["options.widget.addButtonToRaidTab.desc"] = "Add a %s button to the default Blizzard UI on the raid tab, functioning the same as the minimap icon. The default keybind to open the raid tab is O."
L["options.widget.watchChat.text"] = "Watch chat for requests to fix groups"
L["options.widget.watchChat.desc"] = "When the keywords %s or %s are seen in chat while not in combat, automatically open the raid tab."
L["options.widget.announceChat.text"] = "Announce when players have been rearranged to instance chat"

L["options.header.sysMsg"] = "Enhance group-related system messages"
L["options.widget.sysMsgLabel.name"] = "The system message that appears whenever a player joins or leaves a group can be modified to make it more informative. Examples:"
L["options.widget.sysMsgClassColor.text"] = "Add class color"
L["options.widget.sysMsgRoleName.text"] = "Add role name"
L["options.widget.sysMsgRoleIcon.text"] = "Add role icon"
L["options.widget.sysMsgGroupComp.text"] = "Add new group comp"
L["options.widget.sysMsgGroupCompDim.text"] = "Make new group comp dim"

L["options.header.interop"] = "Addon integration"
L["options.widget.dataBrokerGroupCompStyle.text"] = "%s display style"
L["options.widget.dataBrokerGroupCompStyle.desc.1"] = "%s is available as a Data Broker object (a.k.a. an LDB plugin). If you're running an addon that displays Data Broker objects, you can have the group comp on the screen at all times."
L["options.widget.dataBrokerGroupCompStyle.desc.2"] = "There are many Data Broker display addons out there. Some of the more popular ones are %s."

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

-- Tooltips for minimap icon and raid tab button
L["tooltip.right.fixGroups"] = "Fix groups"
L["tooltip.right.split.1"] = "Split raid into two sides based on"
L["tooltip.right.split.2"] = "overall damage/healing done"
L["tooltip.right.config"] = "Open config"
L["tooltip.right.meter.1"] = "Fix groups, sorting by"
L["tooltip.right.meter.2"] = "overall damage/healing done"
L["tooltip.right.nosort"] = "Fix tanks and ML only, no sorting"
L["tooltip.right.moveMinimapIcon"] = "Move minimap icon"
