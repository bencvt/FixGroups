local L = LibStub("AceLocale-3.0")
L = L:NewLocale(..., "deDE")
if not L then return end

-- To fix any mistranslated or missing phrases:
-- http://wow.curseforge.com/addons/fixgroups/localization/

L["addonChannel.print.newerVersion"] = "%s Version %s ist verfügbar. Du benutzt momentan die Version %s."
L["button.close.text"] = "Schließen"
L["button.fixGroups.desc"] = "Der Button auf dem Schlachtzug-Reiter und das Minikarten-Symbol funktionieren auch, um Gruppen festzulegen."
L["button.fixGroups.paused.text"] = "Im Kampf..."
L["button.fixGroups.text"] = "Gruppen festlegen"
L["button.fixGroups.working.text"] = "Umordnung..."
L["button.resetAllOptions.print"] = "Alle Optionen zurückgesetzt."
L["button.resetAllOptions.text"] = "Alle Optionen auf die Standardeinstellung zurücksetzen"
L["button.splitGroups.desc"] = "Der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["button.splitGroups.text"] = "Gruppen aufteilen"
-- L["character.liandrin"] = ""
L["character.thrall"] = "Thrall"
-- L["character.velen"] = ""
L["choose.choosing.print"] = "Ein zufälliger %s wird ausgewählt..."
L["choose.choosing.tooltip"] = "Ein zufälliger %s wird ausgewählt."
L["choose.classAliases.deathknight"] = "Todes,Ritter,TR"
L["choose.classAliases.demonhunter"] = ","
L["choose.classAliases.druid"] = ","
L["choose.classAliases.hunter"] = ","
L["choose.classAliases.mage"] = ","
L["choose.classAliases.monk"] = ","
L["choose.classAliases.paladin"] = "Pal,Pala"
L["choose.classAliases.priest"] = ","
L["choose.classAliases.rogue"] = ","
L["choose.classAliases.shaman"] = "Scham"
L["choose.classAliases.warlock"] = "Hexe"
L["choose.classAliases.warrior"] = "Krieg,warri"
-- L["choose.list.print"] = ""
-- L["choose.list.tooltip"] = ""
L["choose.modeAliases.agility"] = "Beweglichkeit"
L["choose.modeAliases.alive"] = "lebend"
L["choose.modeAliases.any"] = "irgendeiner,irgendjemand,beliebig,beliebiger,jemand"
-- L["choose.modeAliases.anyIncludingSitting"] = ""
L["choose.modeAliases.cloth"] = "Stoff"
L["choose.modeAliases.conqueror"] = "Eroberer,Erob"
L["choose.modeAliases.damager"] = "DPS"
L["choose.modeAliases.dead"] = "tot"
L["choose.modeAliases.fromGroup"] = "Gruppe"
L["choose.modeAliases.group"] = "Gruppe"
L["choose.modeAliases.gui"] = "Fenster" -- Needs review
L["choose.modeAliases.guildmate"] = "Gildenmitglied,Gilde"
L["choose.modeAliases.healer"] = "Heiler"
L["choose.modeAliases.intellect"] = "Intelligenz"
L["choose.modeAliases.last"] = "letzter,letzte,vorheriger,erneut,wiederholen,zuletzt,vorherig,wieder,nochmal,nochmals"
L["choose.modeAliases.leather"] = "Leder"
L["choose.modeAliases.mail"] = "Kette"
L["choose.modeAliases.melee"] = "Nahkämpfer,Nah"
L["choose.modeAliases.notMe"] = "nichtmich"
L["choose.modeAliases.plate"] = "Platte"
L["choose.modeAliases.protector"] = "Beschützer,Besc"
L["choose.modeAliases.ranged"] = "Fernkämpfer,Fern"
L["choose.modeAliases.sitting"] = "sitzend,sitze,sitzen,bank,inaktiv,still,untätig,brachliegend,brach,passiv,faul,ungenutzt"
L["choose.modeAliases.strength"] = "Stärke"
L["choose.modeAliases.tank"] = "Tank"
L["choose.modeAliases.vanquisher"] = "Bezwinger,Bezw"
L["choose.print.busy"] = "Du würfelst bereits gerade. Bitte warte ein paar Sekunden." -- Needs review
L["choose.print.choosing.alive"] = "lebender Spieler"
L["choose.print.choosing.any"] = "Spieler"
-- L["choose.print.choosing.anyIncludingSitting"] = ""
L["choose.print.choosing.armor"] = "%s-Träger" -- Needs review
L["choose.print.choosing.dead"] = "toter Spieler" -- Needs review
L["choose.print.choosing.fromGroup"] = "Spieler aus der Gruppe %d" -- Needs review
L["choose.print.choosing.group"] = "Gruppe, die Spieler enthält," -- Needs review
L["choose.print.choosing.guildmate"] = "Gildenmitglied von <%s>" -- Needs review
-- L["choose.print.choosing.guildmate.noGuild"] = ""
L["choose.print.choosing.notMe"] = "Spieler, der nicht %s ist," -- Needs review
L["choose.print.choosing.option"] = "Option" -- Needs review
L["choose.print.choosing.primaryStat"] = "%s-Benutzer" -- Needs review
-- L["choose.print.choosing.sitting"] = ""
-- L["choose.print.choosing.sitting.noGroups"] = ""
L["choose.print.chose.option"] = "Wähle Option #%d: %s."
L["choose.print.chose.player"] = "Wähle Option #%d: %s in Gruppe %d."
L["choose.print.last"] = "Der letzte %s Befehl wird wiederholt."
L["choose.print.noLastCommand"] = "Es gibt keinen vorherigen %s Befehl."
L["choose.print.noPlayers"] = "Es gibt solche Spieler nicht in deiner Gruppe" -- Needs review
L["dataBroker.groupComp.groupQueued"] = "Deine Gruppe ist in der Warteschlange des Dungeonbrowsers."
L["dataBroker.groupComp.notInGroup"] = "nicht in einer Gruppe"
L["dataBroker.groupComp.openRaidTab"] = "Schlachtzug-Reiter öffnen"
-- L["dataBroker.groupComp.sitting"] = ""
L["gui.chatKeywords"] = "Gruppen festlegen,Tanks markieren" -- Needs review
L["gui.choose.intro"] = "Du musste eine Münze werfen, um eine Entscheidung zu fällen? Benutze den %s Befehl, um eine Option oder einen Spieler zufällig auszuwählen. Die Wahl wird, dank des im WoW eingebauten /wuerfeln-Befehls, sofort, transparent und fair sein. " -- Needs review
L["gui.choose.note.multipleClasses"] = "Du kannst auch mehrere Klassen angeben. Zum Beispiel: %s" -- Needs review
-- L["gui.choose.note.option.1"] = ""
L["gui.choose.note.option.2"] = "Du kannst Kommas oder Leerzeichen verwenden, um die Optionen zu trennen." -- Needs review
L["gui.fixGroups.help.cancel"] = "Die Umordnung der Spieler stoppen."
L["gui.fixGroups.help.choose"] = "Wählt eine(n) zufällige(n) Spieler oder Option aus."
-- L["gui.fixGroups.help.clear1"] = ""
-- L["gui.fixGroups.help.clear2"] = ""
L["gui.fixGroups.help.config"] = "Das gleiche wie Esc>Interface>AddOns>%s."
-- L["gui.fixGroups.help.list"] = ""
-- L["gui.fixGroups.help.listself"] = ""
L["gui.fixGroups.help.nosort"] = "Gruppen festlegen, keine Sortierung." -- Needs review
-- L["gui.fixGroups.help.note.clearSkip"] = ""
-- L["gui.fixGroups.help.note.defaultMode"] = ""
L["gui.fixGroups.help.note.meter.1"] = "Die Sortiermethode \"gemachte(r) Gesamtschaden/-heilung\" wird nur funktionieren, wenn %s läuft." -- Needs review
L["gui.fixGroups.help.note.meter.2"] = "Diese Sortiermethode kann nützlich sein, um schnelle Entscheidungen zu machen, wer eine Notheilung oder einen Battle-Rezz in einer Zufallsgruppe wert ist." -- Needs review
L["gui.fixGroups.help.note.meter.3"] = "Du kannst auch %s, um eine einmalige Sortierung, ohne die Einstellung zu ändern, durchzuführen."
-- L["gui.fixGroups.help.note.sameAsCommand"] = ""
-- L["gui.fixGroups.help.note.sameAsLeftClicking"] = ""
-- L["gui.fixGroups.help.skip1"] = ""
-- L["gui.fixGroups.help.skip2"] = ""
-- L["gui.fixGroups.help.sort"] = ""
L["gui.fixGroups.help.split"] = "Der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["gui.fixGroups.intro"] = "Der %s (oder %s) Befehl erlaubt dir, das Addon ohne Verwendung des GUIs zu steuern. Du kannst diesen Befehl in einem Makro verwenden oder du gibst ihn einfach in den Chat ein." -- Needs review
L["gui.header.buttons"] = "%s Befehlsargumente" -- Needs review
L["gui.header.examples"] = "Beispiele des %s Befehls in Aktion" -- Needs review
-- L["gui.list.intro"] = ""
L["gui.title"] = "%s Befehl" -- Needs review
L["letter.1"] = "A"
L["letter.2"] = "B"
L["letter.3"] = "C"
L["marker.print.needClearMainTank.plural"] = "%s sind fälschlicherweise als Haupttanks festgelegt!"
L["marker.print.needClearMainTank.singular"] = "%s ist fälschlicherweise als Haupttank festgelegt!"
L["marker.print.needSetMainTank.plural"] = "%s sind nicht als Haupttanks festgelegt!"
L["marker.print.needSetMainTank.singular"] = "%s ist nicht als Haupttank festgelegt!"
L["marker.print.openRaidTab"] = "Um Tanks festzulegen, drücke O, um den Schlachtzug-Reiter zu öffnen. WoW-Addons können keine Haupttanks festlegen."
L["marker.print.useRaidTab"] = "Um Tanks festzulegen, benutze den Schlachtzug-Reiter. WoW-Addons können keine Haupttanks festlegen."
L["meter.print.noAddon"] = "Es wurde kein unterstütztes Schadens-/Heilungs-Meter gefunden."
L["meter.print.noDataFrom"] = "Momentan sind keine Daten von %s verfügbar."
L["meter.print.usingDataFrom"] = "Die Schadens-/Heilungs-Daten werden von %s benutzt."
L["options.header.console"] = "Konsolenbefehle"
L["options.header.interop"] = "Addonintegration" -- Needs review
L["options.header.party"] = "Wenn du in einer Gruppe bist (5 Mann Inhalt)"
L["options.header.raidAssist"] = "Wenn du Leiter oder Assistent bist"
L["options.header.raidLead"] = "Wenn du Schlachtzugsleiter bist"
L["options.header.sysMsg"] = "Gruppenbezogene Systemnachrichten verbessern" -- Needs review
-- L["options.tab.main"] = ""
-- L["options.tab.marking"] = ""
-- L["options.tab.sorting"] = ""
L["options.tab.userInterface"] = "Benutzeroberfläche"
L["options.value.always"] = "Immer"
L["options.value.announceChatLimited"] = "Nur nachdem die Sortiermethode der Gruppe geändert wurde"
L["options.value.never"] = "Niemals"
L["options.value.noMark"] = "keins"
L["options.value.onlyInRaidInstances"] = "Nur in Schlachtzugsinstanzen"
L["options.value.onlyWhenLeadOrAssist"] = "Nur wenn du Leiter oder Assistent bist"
L["options.value.sortMode.meter"] = "gemachte(r) Gesamtschaden/-heilung"
L["options.value.sortMode.nosort"] = "Spieler nicht umordnen"
L["options.widget.addButtonToRaidTab.desc"] = "Fügt dem Schlachtzug-Reiter des Standard-Blizzard-UIs den %s Button hinzu, dieser funktioniert genauso wie das Minikarten-Symbol. Die Standard-Tastaturbelegung, um den Schlachtzug-Reiter zu öffnen, ist O."
L["options.widget.addButtonToRaidTab.text"] = "Button zum Schlachtzug-Reiter hinzufügen"
L["options.widget.announceChat.text"] = "In den Instanzchat ankündigen, wenn Spieler umgeordnet wurden."
L["options.widget.clearRaidMarks.text"] = "Zielmarkierungssymbole von allen anderen Schlachtzugsmitgliedern entfernen"
L["options.widget.dataBrokerGroupCompStyle.desc.1"] = "%s ist als Data-Broker-Objekt verfügbar (auch bekannt als ein LDB-Plugin). Wenn du ein Addon verwendest, dass Data-Broker-Objekte anzeigt, kannst du die Gruppenzusammensetzung jederzeit auf dem Bildschirm sehen."
L["options.widget.dataBrokerGroupCompStyle.desc.2"] = "Es gibt eine Menge Data-Broker-Anzeigeaddons. Einige der beliebtesten sind %s."
L["options.widget.dataBrokerGroupCompStyle.text"] = "%s-Darstellungsstil" -- Needs review
L["options.widget.fixOfflineML.desc"] = "Wenn der Plündermeister offline ist, wirst du stattdessen der Plündermeister."
L["options.widget.fixOfflineML.text"] = "Ersatz-Plündermeister festlegen"
L["options.widget.openRaidTab.text"] = "Den Schlachtzug-Reiter öffnen, wenn ein Haupttank festgelegt werden muss"
L["options.widget.partyMark.desc"] = "Klicke auf das Minikarten-Symbol oder auf das %s Button-Symbol ein zweites Mal, um die Markierungen zu löschen."
L["options.widget.partyMarkIcon1.desc"] = "Oder das erste Gruppenmitglied, wenn es keinen Tank gibt (z.B. in Arenen)."
L["options.widget.partyMarkIcon2.desc"] = "Oder das zweite Gruppenmitglied, wenn es keinen Heiler gibt."
L["options.widget.partyMarkIcon.desc"] = "Gruppenmitglieder sind alphabetisch sortiert."
L["options.widget.partyMark.text"] = "Zielmarkierungssymbole auf Gruppenmitglieder setzen"
L["options.widget.raidTank.desc"] = "Tanks sind alphabetisch sortiert."
L["options.widget.resumeAfterCombat.text"] = "Die Umordnung der Spieler fortsetzen, wenn du wegen eines Kampfes unterbrochen wurdest."
L["options.widget.showMinimapIcon.text"] = "Minikarten-Symbol anzeigen"
L["options.widget.sortMode.text"] = "Spieler umordnen"
L["options.widget.splitOddEven.desc.1"] = "Wenn diese Option nicht angehakt ist werden Gruppen benachbart sein (das heißt 1-2 und 3-4, 1-3 und 4-6 oder 1-4 und 5-8.)"
L["options.widget.splitOddEven.desc.2"] = "Um Gruppen aufzuteilen, Gib %s ein, Klicke auf den %s Button oder Rechtsklicke das Minikarten-Symbol."
L["options.widget.splitOddEven.text"] = "Gerade/Ungerade Gruppen bei der Gruppenaufteilung benutzen."
L["options.widget.sysMsgClassColor.text"] = "Klassenfarbe hinzufügen"
L["options.widget.sysMsg.desc"] = "Die Systemnachricht, die auftaucht, wenn ein Spieler einer Gruppe beitritt oder sie verlässt, kann verändert werden, um sie informativer zu machen." -- Needs review
L["options.widget.sysMsgGroupCompHighlight.text"] = "Neue Gruppenzusammensetzung hervorheben"
L["options.widget.sysMsgGroupComp.text"] = "Neue Gruppenzusammensetzung hinzufügen"
L["options.widget.sysMsgRoleIcon.text"] = "Rollensymbol hinzufügen"
L["options.widget.sysMsgRoleName.text"] = "Rollenname hinzufügen"
L["options.widget.tankAssist.text"] = "Tanks zu Assistenten machen"
L["options.widget.tankMainTank.desc"] = "WoW erlaubt Addons leider das automatische Festlegen von Haupttanks nicht, aber wir können es zumindest überprüfen."
L["options.widget.tankMainTank.text"] = "Überprüfen, ob Haupttanks festgelegt sind"
L["options.widget.tankMark.text"] = "Zielmarkierungssymbole auf Tanks setzen"
L["options.widget.top.desc"] = "Die Organisation von Gruppen ist ein wichtiger, wenn auch manchmal langweiliger Teil der Führung eines Schlachtzugs. Dieses Addon hilft diesen Prozess zu automatisieren." -- Needs review
L["options.widget.watchChat.desc"] = "Öffnet den Schlachtzug-Reiter automatisch, wenn die Schlüsselwörter %s im Chat gesehen werden und du nicht im Kampf bist."
L["options.widget.watchChat.text"] = "Den Chat nach Anfragen, für Festegungen von Gruppen, beobachten"
-- L["phrase.assumingRangedForNow.plural"] = ""
-- L["phrase.assumingRangedForNow.singular"] = ""
L["phrase.groupComp"] = "Gruppenzusammensetzung"
L["phrase.mouse.clickLeft"] = "Linksklick"
L["phrase.mouse.clickRight"] = "Rechtsklick"
L["phrase.mouse.ctrlClickLeft"] = "Strg halten + Linksklick"
L["phrase.mouse.ctrlClickRight"] = "Strg halten + Rechtsklick"
L["phrase.mouse.drag"] = "Linksklick halten + Ziehen"
L["phrase.mouse.shiftClickLeft"] = "Shift halten + Linksklick"
L["phrase.mouse.shiftClickRight"] = "Shift halten + Rechtsklick"
L["phrase.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein." -- Needs review
L["phrase.print.notInRaid"] = "Gruppen können nur im Schlachtzug sortiert werden." -- Needs review
L["phrase.versionAuthor"] = "v%s von %s"
-- L["phrase.waitingOnDataFromServerFor"] = ""
L["sorter.mode.meter"] = "die Spieler wurden, basierend auf dem/der gemachten Schaden/Heilung" -- Needs review
-- L["sorter.mode.nosort"] = ""
L["sorter.mode.thmr"] = "Tanks>Heiler>Nahkämpfer>Fernkämpfer" -- Needs review
L["sorter.mode.tmrh"] = "Tanks>Nahkämpfer>Fernkämpfer>Heiler" -- Needs review
L["sorter.print.alreadySorted"] = "Keine Änderung - der Schlachtzug ist bereits nach \"%s\" sortiert."
L["sorter.print.alreadySplit"] = "Keine Änderung - der Schlachtzug ist bereits aufgeteilt."
L["sorter.print.combatCancelled"] = "Die Umordnung nach \"%s\" wurde, aufgrund des Kampfes, abgebrochen."
L["sorter.print.combatPaused"] = "Die Umordnung nach \"%s\" wurde, aufgrund des Kampfes, pausiert."
L["sorter.print.combatResumed"] = "Die Umordnung nach \"%s\" wurde fortgesetzt."
L["sorter.print.excludedSitting.plural"] = "Es wurden %d Spieler, die in den Gruppen %d-8 sind, ausgeschlossen." -- Needs review
L["sorter.print.excludedSitting.singular"] = "Es wurde ein Spieler, der in der Gruppe %d-8 ist, ausgeschlossen." -- Needs review
L["sorter.print.needRank"] = "Du musst Schlachtzugsleiter oder Assistent sein, um Gruppen festzulegen."
L["sorter.print.sorted"] = "Umgeordnet: %s." -- Needs review
L["sorter.print.split"] = "Spieler aufteilen: Gruppen %s."
L["sorter.print.timedOut"] = "Die Umordnung nach \"%s\" wurde gestoppt, weil es zu lange dauert. Vielleicht ordnet jemand anderes gleichzeitig Spieler um?"
L["tooltip.right.config"] = "Konfiguration öffnen"
L["tooltip.right.fixGroups"] = "Gruppen festlegen,"
-- L["tooltip.right.gui"] = ""
L["tooltip.right.meter.1"] = "Gruppen festlegen, Sortierung nach"
L["tooltip.right.meter.2"] = "dem/der gemachten Gesamtschaden/-Heilung"
L["tooltip.right.moveMinimapIcon"] = "Minikarten-Symbol bewegen"
L["tooltip.right.nosort"] = "Nur Tanks und Plündermeister festlegen, keine Sortierung"
L["tooltip.right.split.1"] = "Den Schlachtzug in zwei Seiten aufteilen,"
L["tooltip.right.split.2"] = "basierend auf gemachte/r Gesamt-Schaden/-Heilung"
L["word.alias.plural"] = "Aliasse"
L["word.alias.singular"] = "Alias"
L["word.and"] = "und"
L["word.damager.plural"] = "Schaden" -- Needs review
L["word.damager.singular"] = "Schaden" -- Needs review
L["word.healer.plural"] = "Heiler"
L["word.healer.singular"] = "Heiler"
L["word.melee.plural"] = "Nah"
L["word.melee.singular"] = "Nah"
-- L["word.none"] = ""
L["word.or"] = "oder"
L["word.party"] = "Gruppe"
L["word.raid"] = "Schlachtzug"
L["word.ranged.plural"] = "Fern"
L["word.ranged.singular"] = "Fern"
L["word.tank.plural"] = "Tanks"
L["word.tank.singular"] = "Tank"
L["word.unknown.plural"] = "Unbekannte"
L["word.unknown.singular"] = "Unbekannte"
