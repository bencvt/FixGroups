local L = LibStub("AceLocale-3.0")
L = L:NewLocale(..., "esES") or L:NewLocale(..., "esMX")
if not L then return end

L["and"] = true
L["or"] = true
L["none"] = true

L["console.newerVersion"] = "A newer version of %s (%s) is available. You're currently running %s."

-- button labels
L["Fix Groups"] = true
L["Split Groups"] = true
L["/fg command info"] = true
L["Rearranging..."] = true
L["In Combat..."] = true
L["Reset all options to default"] = true

-- Options dropdown values
L["Always"] = true
L["Never"] = true
L["Only when lead or assist"] = true
L["Only after changing group sorting method"] = true
L["Only in instances"] = true
L["Tanks > Melee > Ranged > Healers"] = true
L["Tanks > Healers > Melee > Ranged"] = true
L["Overall damage/healing done"] = true
L["Do not rearrange players"] = true

-- Options labels
L["User interface and chat"] = true
L["Show minimap icon"] = true
L["Add button to raid tab"] = true
L["Watch chat for requests to fix groups"] = true
L["Announce when players have been rearranged to instance chat"] = true
L["When raid leader"] = true
L["Give tanks assist"] = true
L["Fix offline master looter"] = true
L["When raid leader or assist"] = true
L["Rearrange players"] = true
L["Resume rearranging players when interrupted by combat"] = true
L["Check whether main tanks are set"] = true
L["Open raid tab when main tank needs to be set"] = true
L["Put target markers on tanks"] = true
L["Tanks are sorted alphabetically."] = true
L["Tank 1"] = true
L["Tank 2"] = true
L["Tank 3"] = true
L["Tank 4"] = true
L["Tank 5"] = true
L["Tank 6"] = true
L["Tank 7"] = true
L["Tank 8"] = true
L["Tank"] = true
L["Healer"] = true
L["DPS 1"] = true
L["DPS 2"] = true
L["DPS 3"] = true
L["When splitting groups, use odd/even groups"] = true
L["When in party (5 man content)"] = true
L["Put target markers on party members"] = true
L["Party members are sorted alphabetically."] = true
L["All options reset to default."] = true

-- Options tooltips
L["options.desc"] = "Organizing groups is an important, if sometimes tedious, part of running a raid. This addon helps automate the process."
L["options.buttonCommandSplit.desc"] = "Split raid into two sides based on overall damage/healing done."
L["options.buttonCommandHelp.desc"] = "Print the various options for the %s console/macro command."
L["options.addButtonToRaidTab.desc"] = "This adds a %s button to the default Blizzard UI on the raid tab. The default keybind to open the raid tab is O."
L["options.watchChat.desc"] = "When the keywords \"fix groups\" or \"mark tanks\" are seen in chat while not in combat, automatically open the raid tab."
L["options.sortMode.desc"] = "The overall damage/healing done sort method will only work if Recount, Skada, or Details is running.|n|nThis sort method can be useful for making quick decisions on who's worth an emergency heal or brez in PUGs.|n|nYou can also type %s to do a one-off sort without changing the setting."
L["options.splitOddEven.desc"] = "If this option is not checked then groups will be adjacent (i.e., 1-2 and 3-4, 1-3 and 4-6, or 1-4 and 5-8.)|n|nTo split groups, right click the minimap icon, type %s, or click the %s button."
L["options.fixOfflineML.desc"] = "If the master looter is offline, pass it to the raid leader (i.e., you)."
L["options.tankMainTank.desc"] = "Unfortunately WoW does not allow addons to automatically set main tanks, but we can check for it at least."
L["options.partyMarkIcon1.desc"] = "Or the 1st party member, if there is no tank (e.g., arenas)."
L["options.partyMarkIcon2.desc"] = "Or the 2nd party member, if there is no healer."

-- chat keywords
L["fix group"] = true
L["mark tank"] = true

-- GUI tooltip left
L["Left Click"] = true
L["Right Click"] = true
L["Hold Shift + Left Click"] = true
L["Hold Shift + Right Click"] = true
L["Hold Ctrl + Left Click"] = true
L["Hold Left Click + Drag"] = true

-- GUI tooltip right
L["Fix groups"] = true
L["Split raid into two sides based on"] = true
L["overall damage/healing done"] = true
L["Open config"] = true
L["Fix groups, sorting by"] = true
L["overall damage/healing done"] = true
L["Fix tanks and ML only, no sorting"] = true
L["Move minimap icon"] = true

-- Console
L["v%s by %s"] = true
L["Arguments for the %s command (or %s):"] = true
L["you're reading it"] = true
L["same as Esc>Interface>AddOns>%s"] = true
L["stop rearranging players"] = true
L["fix groups, no sorting"] = true
L["fix groups, sort by overall damage/healing done"] = true
L["split raid into two sides based on overall damage/healing done"] = true
L["fix groups"] = true
L["Groups can only be sorted while in a raid."] = true
L["Unknown argument %s. Type %s for valid arguments."] = true

-- Marker
L["%s is not set as main tank!"] = true
L["%s are not set as main tanks!"] = true
L["%s is incorrectly set as main tank!"] = true
L["%s are incorrectly set as main tanks!"] = true
L["To fix tanks, use the raid tab. WoW addons cannot set main tanks."] = true
L["To fix tanks, press O to open the raid tab. WoW addons cannot set main tanks."] = true

-- Sorter
L["Rearranging players paused due to combat."] = true
L["Rearranging players cancelled due to combat."] = true
L["Resumed rearranging players."] = true
L["Stopped rearranging players because it's taking too long. Perhaps someone else is simultaneously rearranging players?"] = true
L["You must be a raid leader or assistant to fix groups."] = true
L["sortMode.split"] = "Split players: groups %s."
L["sortMode.meter"] = "Rearranged players by damage/healing done."
L["sortMode.TMURH"] = "Rearranged tanks>melee>ranged>healers."
L["sortMode.THMUR"] = "Rearranged tanks>healers>melee>ranged."
L["Excluded %d %s sitting in groups %d-8."] = true
L["player"] = true
L["players"] = true
L["step"] = true
L["steps"] = true
L["second"] = true
L["seconds"] = true

-- SorterMeter
L["No supported damage/healing meter addon found."] = true
L["Using damage/healing data from %s."] = true
L["There is currently no data available from %s."] = true
