local L = LibStub("AceLocale-3.0")
L = L:NewLocale(..., "deDE")
if not L then return end

-- To fix any mistranslated or missing phrases:
-- http://wow.curseforge.com/addons/fixgroups/localization/

L["addonChannel.print.newerVersion"] = "%s Version %s ist verfügbar. Du benutzt momentan die Version %s."
-- L["button.choose.desc"] = ""
L["button.fixGroups.desc"] = "Der Button auf dem Schlachtzug-Reiter und das Minikarten-Symbol funktionieren auch, um Gruppen festzulegen."
-- L["button.fixGroupsHelp.desc.1"] = ""
-- L["button.fixGroupsHelp.desc.2"] = ""
L["button.fixGroups.paused.text"] = "Im Kampf..."
L["button.fixGroups.text"] = "Gruppen festlegen"
L["button.fixGroups.working.text"] = "Umordnung..."
L["button.resetAllOptions.print"] = "Alle Optionen zurückgesetzt."
L["button.resetAllOptions.text"] = "Alle Optionen auf die Standardeinstellung zurücksetzen"
L["button.splitGroups.desc"] = "Der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["button.splitGroups.text"] = "Gruppen aufteilen"
L["chatKeyword.fixGroups"] = "Gruppen festlegen"
L["chatKeyword.markTanks"] = "Tanks markieren"
L["choose.examples.giveUpOrNot"] = "Gib auf oder mach weiter"
L["choose.examples.header"] = "Hier sind einige Möglichkeiten, um den %s -Befehl zu verwenden:"
L["choose.examples.playerNames"] = "Hänsel Gretel"
L["choose.examples.raids"] = "Hochfels, Schwarzfelsgießerei, Höllenfeuerzitadelle"
-- L["choose.group"] = ""
L["choose.help.blank"] = "wählt einen zufälligen Spieler aus"
L["choose.help.class"] = "wählt einen zufälligen Spieler einer bestimmten Klasse aus"
L["choose.help.class.arg"] = "<Klasse>"
L["choose.help.examples"] = "Gib %s für Beispiele ein."
L["choose.help.header"] = "Argumente für den %s Befehl (oder %s):"
L["choose.help.option"] = "wählt eine zufällige Option aus"
-- L["choose.help.option.arg"] = ""
L["choose.help.role"] = "wählt einen zufälligen Spieler, dessen Rolle %s sein kann, aus"
L["choose.help.role.arg"] = "<Rolle>"
L["choose.help.tierToken"] = "wählt einen zufälligen Spieler mit einer bestimmten Tier-Marke aus: %s" -- Needs review
L["choose.help.tierToken.arg"] = "<Marke>" -- Needs review
L["choose.player.alive"] = "lebend" -- Needs review
-- L["choose.player.any"] = ""
-- L["choose.player.anyIncludingSitting"] = ""
-- L["choose.player.armor.cloth"] = ""
-- L["choose.player.armor.leather"] = ""
-- L["choose.player.armor.mail"] = ""
-- L["choose.player.armor.plate"] = ""
L["choose.player.dead"] = "tot" -- Needs review
-- L["choose.player.fromGroup"] = ""
-- L["choose.player.guildmate"] = ""
-- L["choose.player.notMe"] = ""
-- L["choose.player.primaryStat.agility"] = ""
-- L["choose.player.primaryStat.intellect"] = ""
-- L["choose.player.primaryStat.strength"] = ""
-- L["choose.player.sitting"] = ""
L["choose.player.tierToken.conqueror"] = "Eroberer" -- Needs review
L["choose.player.tierToken.conqueror.short"] = "Erob" -- Needs review
L["choose.player.tierToken.protector"] = "Beschützer" -- Needs review
L["choose.player.tierToken.protector.short"] = "Besc" -- Needs review
L["choose.player.tierToken.vanquisher"] = "Bezwinger" -- Needs review
L["choose.player.tierToken.vanquisher.short"] = "Bezw" -- Needs review
L["choose.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein."
-- L["choose.print.busy"] = ""
L["choose.print.choosing.alive"] = "Ein zufälliger lebender Spieler wird gerade ausgewählt..."
L["choose.print.choosing.any"] = "Ein zufälliger Spieler wird gerade ausgewählt..."
-- L["choose.print.choosing.anyIncludingSitting"] = ""
-- L["choose.print.choosing.armor"] = ""
L["choose.print.choosing.class"] = "Ein zufälliger %s wird gerade ausgewählt..."
L["choose.print.choosing.damager"] = "Ein zufälliger Schadensverursacher wird gerade ausgewählt..."
L["choose.print.choosing.dead"] = "Ein zufälliger toter Spieler wird gerade ausgewählt..."
-- L["choose.print.choosing.fromGroup"] = ""
-- L["choose.print.choosing.group"] = ""
-- L["choose.print.choosing.guildmate"] = ""
L["choose.print.choosing.healer"] = "Ein zufälliger Heiler wird gerade ausgewählt..."
L["choose.print.choosing.melee"] = "Ein zufälliger Nahkämpfer wird gerade ausgewählt..."
-- L["choose.print.choosing.notMe"] = ""
L["choose.print.choosing.option"] = "Eine zufällige Option wird gerade ausgewählt..."
-- L["choose.print.choosing.primaryStat"] = ""
L["choose.print.choosing.ranged"] = "Ein zufälliger Fernkämpfer wird gerade ausgewählt..."
-- L["choose.print.choosing.sitting"] = ""
-- L["choose.print.choosing.sitting.noGroups"] = ""
L["choose.print.choosing.tank"] = "Ein zufälliger Tank wird gerade ausgewählt..."
L["choose.print.choosing.tierToken"] = "Ein zufälliger %s wird gerade ausgewählt..."
-- L["choose.print.chose.option"] = ""
-- L["choose.print.chose.player"] = ""
L["choose.print.noPlayers"] = "Es gibt solche Spieler nicht in deiner Gruppe"
L["console.help.blank"] = "Gruppen festlegen"
L["console.help.cancel"] = "die Umordnung der Spieler stoppen"
L["console.help.config"] = "das gleiche wie Esc>Interface>AddOns>%s"
L["console.help.header"] = "Argumente für den %s Befehl (oder %s):"
L["console.help.help"] = "Das liest du gerade"
L["console.help.meter"] = "Gruppen festlegen, basierend auf dem/der gemachten Gesamt-Schaden/-Heilung sortieren"
L["console.help.nosort"] = "Gruppen festlegen, keine Sortierung"
L["console.help.seeChoose"] = "wählt eine(n) zufällige(n) Spieler oder Option aus, siehe %s"
L["console.help.split"] = "der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["console.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein."
L["console.print.notInRaid"] = "Gruppen können nur im Schlachtzug sortiert werden."
-- L["dataBroker.groupComp.groupQueued"] = ""
-- L["dataBroker.groupComp.name"] = ""
-- L["dataBroker.groupComp.notInGroup"] = ""
-- L["dataBroker.groupComp.openRaidTab"] = ""
-- L["dataBroker.groupComp.sitting"] = ""
L["marker.print.needClearMainTank.plural"] = "%s sind fälschlicherweise als Haupttanks festgelegt!"
L["marker.print.needClearMainTank.singular"] = "%s ist fälschlicherweise als Haupttank festgelegt!"
L["marker.print.needSetMainTank.plural"] = "%s sind nicht als Haupttanks festgelegt!"
L["marker.print.needSetMainTank.singular"] = "%s ist nicht als Haupttank festgelegt!"
L["marker.print.openRaidTab"] = "Um Tanks festzulegen, drücke O, um den Schlachtzug-Reiter zu öffnen. WoW-Addons können keine Haupttanks festlegen."
L["marker.print.useRaidTab"] = "Um Tanks festzulegen, benutze den Schlachtzug-Reiter. WoW-Addons können keine Haupttanks festlegen."
L["meter.print.noAddon"] = "Es wurde kein unterstütztes Schadens-/Heilungs-Meter gefunden."
L["meter.print.noDataFrom"] = "Momentan sind keine Daten von %s verfügbar."
L["meter.print.usingDataFrom"] = "Die Schadens-/Heilungs-Daten werden von %s benutzt."
-- L["options.header.console"] = ""
L["options.header.interop"] = "Addonintegration"
L["options.header.party"] = "Wenn du in einer Gruppe bist (5 Mann Inhalt)"
L["options.header.raidAssist"] = "Wenn du Leiter oder Assistent bist"
L["options.header.raidLead"] = "Wenn du Schlachtzugsleiter bist"
L["options.header.uiAndChat"] = "Benutzeroberfläche und Chat"
L["options.value.always"] = "Immer"
L["options.value.announceChatLimited"] = "Nur nachdem die Sortiermethode der Gruppe geändert wurde"
L["options.value.never"] = "Niemals"
L["options.value.noMark"] = "keine" -- Needs review
L["options.value.onlyInRaidInstances"] = "Nur in Schlachtzugsinstanzen"
L["options.value.onlyWhenLeadOrAssist"] = "Nur wenn du Leiter oder Assistent bist"
L["options.value.sortMode.meter"] = "dem/der gemachten Gesamtschaden/-Heilung"
L["options.value.sortMode.nosort"] = "Spieler nicht umordnen"
L["options.widget.addButtonToRaidTab.desc"] = "Fügt dem Schlachtzug-Reiter des Standard-Blizzard-UIs den %s Button hinzu, dieser funktioniert genauso wie das Minikarten-Symbol. Die Standard-Tastaturbelegung, um den Schlachtzug-Reiter zu öffnen, ist O."
L["options.widget.addButtonToRaidTab.text"] = "Button zum Schlachtzug-Reiter hinzufügen"
L["options.widget.announceChat.text"] = "In den Instanzchat ankündigen, wenn Spieler umgeordnet wurden."
-- L["options.widget.dataBrokerGroupCompStyle.desc.1"] = ""
-- L["options.widget.dataBrokerGroupCompStyle.desc.2"] = ""
-- L["options.widget.dataBrokerGroupCompStyle.text"] = ""
-- L["options.widget.enhanceGroupRelatedSystemMessages.desc.1"] = ""
-- L["options.widget.enhanceGroupRelatedSystemMessages.desc.2"] = ""
-- L["options.widget.enhanceGroupRelatedSystemMessages.desc.3"] = ""
-- L["options.widget.enhanceGroupRelatedSystemMessages.text"] = ""
L["options.widget.fixOfflineML.desc"] = "Wenn der Plündermeister offline ist, wirst du stattdessen der Plündermeister."
L["options.widget.fixOfflineML.text"] = "Ersatz-Plündermeister festlegen" -- Needs review
L["options.widget.openRaidTab.text"] = "Den Schlachtzug-Reiter öffnen, wenn ein Haupttank festgelegt werden muss"
L["options.widget.partyMark.desc"] = "Klicke auf das Minikarten-Symbol oder auf das %s Button-Symbol ein zweites Mal, um die Markierungen zu löschen."
L["options.widget.partyMarkIcon1.desc"] = "Oder das erste Gruppenmitglied, wenn es keinen Tank gibt (z.B. in Arenen)."
L["options.widget.partyMarkIcon2.desc"] = "Oder das zweite Gruppenmitglied, wenn es keinen Heiler gibt."
L["options.widget.partyMarkIcon.desc"] = "Gruppenmitglieder sind alphabetisch sortiert."
L["options.widget.partyMark.text"] = "Zielmarkierungssymbole auf Gruppenmitglieder setzen"
L["options.widget.raidTank.desc"] = "Tanks sind alphabetisch sortiert."
L["options.widget.resumeAfterCombat.text"] = "Die Umordnung der Spieler fortsetzen, wenn du wegen eines Kampfes unterbrochen wurdest."
L["options.widget.showMinimapIcon.text"] = "Minikarten-Symbol anzeigen"
L["options.widget.sortMode.desc.1"] = "Die gemachte/r Gesamtschaden/-Heilung Sortiermethode wird nur funktionieren, wenn %s läuft."
L["options.widget.sortMode.desc.2"] = "Diese Sortiermethode kann nützlich sein, um schnelle Entscheidungen zu machen, wer eine Notheilung oder einen Battle-Rezz in einer Zufallsgruppe wert ist."
L["options.widget.sortMode.desc.3"] = "Du kannst auch %s eingeben oder auf das Minikarten-Symbol (oder auf den %s Button) Shift + rechtsklicken, um eine einmalige Sortierung, ohne die Einstellung zu ändern, durchzuführen."
L["options.widget.sortMode.text"] = "Spieler umordnen"
L["options.widget.splitOddEven.desc.1"] = "Wenn diese Option nicht angehakt ist werden Gruppen benachbart sein (das heißt 1-2 und 3-4, 1-3 und 4-6 oder 1-4 und 5-8.)"
L["options.widget.splitOddEven.desc.2"] = "Um Gruppen aufzuteilen, Gib %s ein, Klicke auf den %s Button oder Rechtsklicke das Minikarten-Symbol."
L["options.widget.splitOddEven.text"] = "Gerade/Ungerade Gruppen bei der Gruppenaufteilung benutzen."
L["options.widget.tankAssist.text"] = "Tanks zu Assistenten machen"
L["options.widget.tankMainTank.desc"] = "WoW erlaubt Addons leider das automatische Festlegen von Haupttanks nicht, aber wir können es zumindest überprüfen."
L["options.widget.tankMainTank.text"] = "Überprüfen, ob Haupttanks festgelegt sind"
L["options.widget.tankMark.text"] = "Zielmarkierungssymbole auf Tanks setzen"
L["options.widget.top.desc"] = "Die Organisation von Gruppen ist ein wichtiger, wenn auch manchmal langweiliger Teil der Führung eines Schlachtzugs. Dieses Addon hilft diesen Prozess zu automatisieren."
L["options.widget.watchChat.desc"] = "Öffnet den Schlachtzug-Reiter automatisch, wenn die Schlüsselwörter %s oder %s im Chat gesehen werden und du nicht im Kampf bist."
L["options.widget.watchChat.text"] = "Den Chat nach Anfragen, für Festegungen von Gruppen, beobachten"
L["phrase.mouse.clickLeft"] = "Linksklick"
L["phrase.mouse.clickRight"] = "Rechtsklick"
L["phrase.mouse.ctrlClickLeft"] = "Strg halten + Linksklick"
L["phrase.mouse.ctrlClickRight"] = "Strg halten + Rechtsklick"
L["phrase.mouse.drag"] = "Linksklick halten + Ziehen"
L["phrase.mouse.shiftClickLeft"] = "Shift halten + Linksklick"
L["phrase.mouse.shiftClickRight"] = "Shift halten + Rechtsklick"
L["phrase.versionAuthor"] = "v%s von %s"
-- L["phrase.waitingOnDataFromServerFor"] = ""
L["sorter.print.alreadySorted"] = "Keine Änderung - der Schlachtzug ist bereits sortiert."
L["sorter.print.alreadySplit"] = "Keine Änderung - der Schlachtzug ist bereits aufgeteilt."
L["sorter.print.combatCancelled"] = "Die Umordnung der Spieler wurde, aufgrund des Kampfes, abgebrochen."
L["sorter.print.combatPaused"] = "Die Umordnung der Spieler wurde, aufgrund des Kampfes, pausiert."
L["sorter.print.combatResumed"] = "Umordnung der Spieler fortgesetzt."
L["sorter.print.excludedSitting.plural"] = "Es wurden %d Spieler, die in den Gruppen %d-8 sind, ausgeschlossen." -- Needs review
L["sorter.print.excludedSitting.singular"] = "Es wurde ein Spieler, der in der Gruppe %d-8 ist, ausgeschlossen." -- Needs review
L["sorter.print.meter"] = "Die Spieler wurden, basierend auf dem/der gemachten Schaden/Heilung, umgeordnet."
L["sorter.print.needRank"] = "Du musst Schlachtzugsleiter oder Assistent sein, um Gruppen festzulegen."
L["sorter.print.split"] = "Spieler aufteilen: Gruppen %s."
L["sorter.print.THMUR"] = "Umgeordnet: Tanks>Heiler>Nahkämpfer>Fernkämpfer."
L["sorter.print.timedOut"] = "Die Umordnung der Spieler wurde gestoppt, weil es zu lange dauert. Vielleicht ordnet jemand anderes gleichzeitig Spieler um?"
L["sorter.print.TMURH"] = "Umgeordnet: Tanks>Nahkämpfer>Fernkämpfer>Heiler."
L["tooltip.right.config"] = "Konfiguration öffnen"
L["tooltip.right.fixGroups"] = "Gruppen festlegen"
L["tooltip.right.meter.1"] = "Gruppen festlegen, Sortierung nach"
L["tooltip.right.meter.2"] = "dem/der gemachten Gesamtschaden/-Heilung"
L["tooltip.right.moveMinimapIcon"] = "Minikarten-Symbol bewegen"
L["tooltip.right.nosort"] = "Nur Tanks und Plündermeister festlegen, keine Sortierung"
L["tooltip.right.split.1"] = "Den Schlachtzug in zwei Seiten aufteilen,"
L["tooltip.right.split.2"] = "basierend auf gemachte/r Gesamt-Schaden/-Heilung"
L["word.and"] = "und"
L["word.damager.plural"] = "Schaden" -- Needs review
L["word.damager.singular"] = "Schaden" -- Needs review
L["word.healer.plural"] = "Heiler" -- Needs review
L["word.healer.singular"] = "Heiler" -- Needs review
L["word.melee.plural"] = "Nah" -- Needs review
L["word.melee.singular"] = "Nah" -- Needs review
L["word.or"] = "oder"
-- L["word.party"] = ""
-- L["word.raid"] = ""
L["word.ranged.plural"] = "Fern" -- Needs review
L["word.ranged.singular"] = "Fern" -- Needs review
L["word.tank.plural"] = "Tanks" -- Needs review
L["word.tank.singular"] = "Tank" -- Needs review
-- L["word.unknown.plural"] = ""
-- L["word.unknown.singular"] = ""
