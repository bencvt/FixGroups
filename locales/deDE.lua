local L = LibStub("AceLocale-3.0")
L = L:NewLocale(..., "deDE")
if not L then return end

-- To fix any mistranslated or missing phrases:
-- http://wow.curseforge.com/addons/fixgroups/localization/

L["addonChannel.print.newerVersion"] = "%s Version %s ist verfügbar. Du benutzt momentan die Version %s."
L["button.commandInfo.desc"] = "Gibt die verschiedenen Optionen für den \"%s\" Eingabefenster/Makro Befehl aus."
L["button.commandInfo.text"] = "/fg Befehlsliste"
L["button.fixGroups.desc"] = "Der Button auf dem \"Schlachtzug\" Reiter und das Minikarten-Symbol funktionieren auch, um Gruppen festzulegen."
L["button.fixGroups.paused.text"] = "Im Kampf..."
L["button.fixGroups.text"] = "Gruppen festlegen"
L["button.fixGroups.working.text"] = "Umordnung..."
L["button.resetAllOptions.print"] = "Alle Optionen zurückgesetzt."
L["button.resetAllOptions.text"] = "Alle Optionen auf die Standardeinstellung zurücksetzen"
L["button.splitGroups.desc"] = "Der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["button.splitGroups.text"] = "Gruppen aufteilen"
L["chatKeyword.fixGroups"] = "Gruppen festlegen"
L["chatKeyword.markTanks"] = "Tanks markieren"
-- L["choose.examples.header"] = ""
-- L["choose.help.blank"] = ""
-- L["choose.help.class"] = ""
L["choose.help.class.arg"] = "<Klasse>" -- Needs review
L["choose.help.examples"] = "Beispiele: %s"
L["choose.help.header"] = "Argumente für den %s Befehl (oder %s):"
-- L["choose.help.option"] = ""
-- L["choose.help.option.arg"] = ""
-- L["choose.help.role"] = ""
L["choose.help.role.arg"] = "<Rolle>"
-- L["choose.help.token"] = ""
-- L["choose.help.token.arg"] = ""
L["choose.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein."
-- L["choose.print.busy"] = ""
-- L["choose.print.choosing.class"] = ""
-- L["choose.print.choosing.dps"] = ""
-- L["choose.print.choosing.healer"] = ""
-- L["choose.print.choosing.melee"] = ""
-- L["choose.print.choosing.option"] = ""
-- L["choose.print.choosing.player"] = ""
-- L["choose.print.choosing.ranged"] = ""
-- L["choose.print.choosing.tank"] = ""
-- L["choose.print.choosing.token"] = ""
-- L["choose.print.chose.option"] = ""
-- L["choose.print.chose.player"] = ""
L["choose.print.noPlayers"] = "Es gibt solche Spieler nicht in deiner Gruppe"
-- L["choose.role.any"] = ""
-- L["choose.role.damager"] = ""
L["choose.role.healer"] = "Heiler"
-- L["choose.role.melee"] = ""
-- L["choose.role.ranged"] = ""
L["choose.role.tank"] = "Tank"
-- L["choose.tierToken.conqueror"] = ""
-- L["choose.tierToken.conqueror.short"] = ""
-- L["choose.tierToken.protector"] = ""
-- L["choose.tierToken.protector.short"] = ""
-- L["choose.tierToken.vanquisher"] = ""
-- L["choose.tierToken.vanquisher.short"] = ""
L["console.help.blank"] = "Gruppen festlegen"
L["console.help.cancel"] = "die Umordnung der Spieler stoppen"
L["console.help.config"] = "das gleiche wie Esc>Interface>AddOns>%s"
L["console.help.header"] = "Argumente für den %s Befehl (oder %s):"
L["console.help.help"] = "Du liest es gerade"
L["console.help.meter"] = "Gruppen festlegen, basierend auf dem/der gemachten Gesamt-Schaden/-Heilung sortieren"
L["console.help.nosort"] = "Gruppen festlegen, keine Sortierung"
-- L["console.help.seeChoose"] = ""
L["console.help.split"] = "der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["console.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein."
L["console.print.notInRaid"] = "Gruppen können nur im Schlachtzug sortiert werden."
L["marker.print.needClearMainTank"] = "%s ist fälschlicherweise als Haupttank festgelegt!"
L["marker.print.needClearMainTanks"] = "%s sind fälschlicherweise als Haupttanks festgelegt!"
L["marker.print.needSetMainTank"] = "%s ist nicht als Haupttank festgelegt!"
L["marker.print.needSetMainTanks"] = "%s sind nicht als Haupttanks festgelegt!"
L["marker.print.openRaidTab"] = "Um Tanks festzulegen, drücke O, um den \"Schlachtzug\" Reiter zu öffnen. WoW Addons können keine Haupttanks festlegen."
L["marker.print.useRaidTab"] = "Um Tanks festzulegen, benutze den \"Schlachtzug\" Reiter. WoW Addons können keine Haupttanks festlegen."
L["meter.print.noAddon"] = "Es wurde kein unterstütztes Schadens/Heilungs Meter gefunden."
L["meter.print.noDataFrom"] = "Momentan sind keine Daten von %s verfügbar."
L["meter.print.usingDataFrom"] = "Die Schadens/Heilungs Daten werden von %s benutzt."
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
L["options.value.sortMode.meter"] = "Insgesamt gemachte/r Schaden/Heilung" -- Needs review
L["options.value.sortMode.nosort"] = "Spieler nicht umordnen"
L["options.value.sortMode.THMUR"] = "Tanks > Heiler > Nahkämpfer > Fernkämpfer"
L["options.value.sortMode.TMURH"] = "Tanks > Nahkämpfer > Fernkämpfer > Heiler"
L["options.widget.addButtonToRaidTab.desc"] = "Fügt dem \"Schlachtzug\" Reiter des Standard-Blizzard UIs den \"%s\" Button hinzu, dieser funktioniert genauso wie das Minikarten-Symbol. Die Standard-Tastaturbelegung, um den \"Schlachtzug\" Reiter zu öffnen, ist O."
L["options.widget.addButtonToRaidTab.text"] = "Button zum \"Schlachtzug\" Reiter hinzufügen"
L["options.widget.announceChat.text"] = "In den Instanzchat ankündigen, wenn Spieler umgeordnet wurden."
L["options.widget.fixOfflineML.desc"] = "Wenn der Plündermeister offline ist, wirst du stattdessen der Plündermeister."
L["options.widget.fixOfflineML.text"] = "offline Plündermeister " -- Needs review
L["options.widget.openRaidTab.text"] = "Den \"Schlachtzug\" Reiter öffnen, wenn ein Haupttank festgelegt werden muss"
L["options.widget.partyMark.desc"] = "Klicke auf das Minikarten-Symbol oder auf das %s Button Symbol ein zweites Mal, um die Markierungen zu löschen."
L["options.widget.partyMarkIcon1.desc"] = "Oder das erste Gruppenmitglied, wenn es keinen Tank gibt (z.B. in Arenen)."
L["options.widget.partyMarkIcon1.text"] = "Tank"
L["options.widget.partyMarkIcon2.desc"] = "Oder das zweite Gruppenmitglied, wenn es keinen Heiler gibt."
L["options.widget.partyMarkIcon2.text"] = "Heiler"
L["options.widget.partyMarkIcon3.text"] = "DPS 1"
L["options.widget.partyMarkIcon4.text"] = "DPS 2"
L["options.widget.partyMarkIcon5.text"] = "DPS 3"
L["options.widget.partyMarkIcon.desc"] = "Gruppenmitglieder sind alphabetisch sortiert."
L["options.widget.partyMark.text"] = "Zielmarkierungssymbole auf Gruppenmitglieder setzen"
L["options.widget.raidTank1.text"] = "Tank 1"
L["options.widget.raidTank2.text"] = "Tank 2"
L["options.widget.raidTank3.text"] = "Tank 3"
L["options.widget.raidTank4.text"] = "Tank 4"
L["options.widget.raidTank5.text"] = "Tank 5"
L["options.widget.raidTank6.text"] = "Tank 6"
L["options.widget.raidTank7.text"] = "Tank 7"
L["options.widget.raidTank8.text"] = "Tank 8"
L["options.widget.raidTank.desc"] = "Tanks sind alphabetisch sortiert."
L["options.widget.resumeAfterCombat.text"] = "Die Umordnung der Spieler fortsetzen, wenn du wegen eines Kampfes unterbrochen wirst."
L["options.widget.showMinimapIcon.text"] = "Minikarten-Symbol anzeigen"
L["options.widget.sortMode.desc"] = "Die gemachte/r Gesamtschaden/-Heilung Sortiermethode wird nur funktionieren, wenn Recount, Skada oder Details! läuft.|n|nDiese Sortiermethode kann nützlich sein, um schnelle Entscheidungen zu machen, wer eine Notheilung oder einen Battle-Rezz in einer Zufallsgruppe wert ist.|n|nDu kannst auch \"%s\" eingeben oder auf das Minikarten-Symbol (oder auf den \"%s\" Button) Shift + rechtsklicken, um eine einmalige Sortierung, ohne die Einstellung zu ändern, durchzuführen." -- Needs review
L["options.widget.sortMode.text"] = "Spieler umordnen"
-- L["options.widget.splitOddEven.desc"] = ""
L["options.widget.splitOddEven.text"] = "Gerade/Ungerade Gruppen bei der Gruppenaufteilung benutzen."
L["options.widget.tankAssist.text"] = "Tanks zu Assistenten machen"
L["options.widget.tankMainTank.desc"] = "WoW erlaubt Addons leider das automatische Festlegen von Haupttanks nicht, aber wir können es zumindest überprüfen."
L["options.widget.tankMainTank.text"] = "Überprüfen, ob Haupttanks festgelegt sind"
L["options.widget.tankMark.text"] = "Zielmarkierungssymbole auf Tanks setzen"
L["options.widget.top.desc"] = "Die Organisation von Gruppen ist ein wichtiger, wenn auch manchmal langweiliger Teil der Führung eines Schlachtzugs. Dieses Addon hilft diesen Prozess zu automatisieren."
L["options.widget.watchChat.desc"] = "Öffnet den \"Schlachtzug\" Reiter automatisch, wenn die Schlüsselwörter %s oder %s im Chat gesehen werden und du nicht im Kampf bist."
L["options.widget.watchChat.text"] = "Den Chat nach Anfragen, für Festegungen von Gruppen, beobachten"
L["sorter.print.alreadySorted"] = "Keine Änderung - der Schlachtzug ist bereits sortiert."
L["sorter.print.alreadySplit"] = "Keine Änderung - der Schlachtzug ist bereits aufgeteilt."
L["sorter.print.combatCancelled"] = "Die Umordnung der Spieler wurde, aufgrund des Kampfes, abgebrochen."
L["sorter.print.combatPaused"] = "Die Umordnung der Spieler wurde, aufgrund des Kampfes, pausiert."
L["sorter.print.combatResumed"] = "Umordnung der Spieler fortgesetzt."
-- L["sorter.print.excludedSitting.plural"] = ""
-- L["sorter.print.excludedSitting.singular"] = ""
L["sorter.print.meter"] = "Die Spieler wurden, basierend auf dem/der gemachten Schaden/Heilung, umgeordnet." -- Needs review
L["sorter.print.needRank"] = "Du musst Schlachtzugsleiter oder Assistent sein, um Gruppen festzulegen."
L["sorter.print.split"] = "Spieler aufteilen: Gruppen %s."
L["sorter.print.THMUR"] = "Umgeordnet: Tanks>Heiler>Nahkämpfer>Fernkämpfer."
L["sorter.print.timedOut"] = "Die Umordnung der Spieler wurde gestoppt, weil es zu lange dauert. Vielleicht ordnet jemand anderes gleichzeitig Spieler um?"
L["sorter.print.TMURH"] = "Umgeordnet: Tanks>Nahkämpfer>Fernkämpfer>Heiler."
L["tooltip.header.raidComp"] = "Schlachtzug: %s"
L["tooltip.left.clickLeft"] = "Linksklick"
L["tooltip.left.clickRight"] = "Rechtsklick"
L["tooltip.left.ctrlClickLeft"] = "Strg halten + Linksklick"
L["tooltip.left.ctrlClickRight"] = "Strg halten + Rechtsklick"
L["tooltip.left.drag"] = "Linksklick halten + Ziehen"
L["tooltip.left.shiftClickLeft"] = "Shift halten + Linksklick"
L["tooltip.left.shiftClickRight"] = "Shift halten + Rechtsklick"
L["tooltip.right.config"] = "Konfiguration öffnen"
L["tooltip.right.fixGroups"] = "Gruppen festlegen"
L["tooltip.right.meter.1"] = "Gruppen festlegen, Sortierung nach"
L["tooltip.right.meter.2"] = "dem/der gemachten Gesamtschaden/-Heilung"
L["tooltip.right.moveMinimapIcon"] = "Minikarten-Symbol bewegen"
L["tooltip.right.nosort"] = "Tanks und Plündermeister festlegen, keine Sortierung"
L["tooltip.right.split.1"] = "Den Schlachtzug in zwei Seiten aufteilen,"
L["tooltip.right.split.2"] = "basierend auf gemachte/r Gesamt-Schaden/-Heilung"
L["versionAuthor"] = "v%s von %s"
L["word.and"] = "und"
L["word.or"] = "oder"
