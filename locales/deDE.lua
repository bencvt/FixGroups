local L = LibStub("AceLocale-3.0")
L = L:NewLocale(..., "deDE")
if not L then return end

-- To fix any mistranslated or missing phrases:
-- http://wow.curseforge.com/addons/fixgroups/localization/

L["addonChannel.print.newerVersion"] = "%s Version %s ist verfügbar. Du benutzt momentan die Version %s."
L["button.close.text"] = "Schließen"
L["button.fixGroups.desc"] = "Der Button auf dem Schlachtzug-Reiter und das Minikarten-Symbol funktionieren auch, um Gruppen festzulegen."
L["button.fixGroupsHelp.desc.1"] = "Der %s (oder %s) Befehl erlaubt dir, das Addon ohne Verwendung des GUIs zu steuern. Du kannst diesen Befehl in einem Makro verwenden oder du gibst ihn einfach in den Chat ein."
L["button.fixGroupsHelp.desc.2"] = "Klicke auf diesen Button, um %s auszuführen, dieser Befehl wird dir die verschiedenen Argumente anzeigen."
L["button.fixGroups.paused.text"] = "Im Kampf..."
L["button.fixGroups.text"] = "Gruppen festlegen"
L["button.fixGroups.working.text"] = "Umordnung..."
L["button.resetAllOptions.print"] = "Alle Optionen zurückgesetzt."
L["button.resetAllOptions.text"] = "Alle Optionen auf die Standardeinstellung zurücksetzen"
L["button.splitGroups.desc"] = "Der Schlachtzug wird in zwei Seiten, basierend auf dem/der gemachten Gesamtschaden/-Heilung, aufgeteilt."
L["button.splitGroups.text"] = "Gruppen aufteilen"
L["character.thrall"] = "Thrall"
L["chatKeyword.fixGroups"] = "Gruppen festlegen"
L["chatKeyword.markTanks"] = "Tanks markieren"
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
L["choose.gui.header.buttons"] = "%s Befehlsargumente"
L["choose.gui.header.examples"] = "Beispiele des %s Befehls in Aktion"
L["choose.gui.intro"] = "Du musste eine Münze werfen, um eine Entscheidung zu fällen? Benutze den %s Befehl, um eine Option oder einen Spieler zufällig auszuwählen. Die Wahl wird, dank des im WoW eingebauten /wuerfeln-Befehls, sofort, transparent und fair sein. "
L["choose.gui.note.multipleClasses"] = "Du kannst auch mehrere Klassen angeben. Zum Beispiel: %s"
-- L["choose.gui.note.option.1"] = ""
L["choose.gui.note.option.2"] = "Du kannst Kommas oder Leerzeichen verwenden, um die Optionen zu trennen."
L["choose.gui.title"] = "%s Befehl"
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
L["choose.print.badArgument"] = "Unbekanntes Argument %s. Gib %s für gültige Argumente ein."
L["choose.print.busy"] = "Du würfelst bereits gerade. Bitte warte ein paar Sekunden." -- Needs review
L["choose.print.choosing.alive"] = "Ein zufälliger lebender Spieler wird ausgewählt..."
L["choose.print.choosing.any"] = "Ein zufälliger Spieler wird ausgewählt..."
-- L["choose.print.choosing.anyIncludingSitting"] = ""
L["choose.print.choosing.armor"] = "Ein zufälliger %s-Träger (%s) wird ausgewählt..."
L["choose.print.choosing.class"] = "Ein zufälliger %s wird ausgewählt..."
L["choose.print.choosing.damager"] = "Ein zufälliger Schadensverursacher wird ausgewählt..."
L["choose.print.choosing.dead"] = "Ein zufälliger toter Spieler wird ausgewählt..."
L["choose.print.choosing.fromGroup"] = "Ein zufälliger Spieler aus der Gruppe %d wird ausgewählt..."
L["choose.print.choosing.group"] = "Eine zufällige Gruppe, die Spieler enthält, wird ausgewählt..."
L["choose.print.choosing.guildmate"] = "Ein zufälliges Gildenmitglied von <%s> wird ausgewählt..."
-- L["choose.print.choosing.guildmate.noGuild"] = ""
L["choose.print.choosing.healer"] = "Ein zufälliger Heiler wird ausgewählt..."
L["choose.print.choosing.last"] = "Der letzte %s Befehl wird wiederholt..."
L["choose.print.choosing.melee"] = "Ein zufälliger Nahkämpfer wird ausgewählt..."
L["choose.print.choosing.notMe"] = "Ein zufälliger Spieler, der nicht %s ist, wird ausgewählt..."
L["choose.print.choosing.option"] = "Eine zufällige Option wird ausgewählt..."
L["choose.print.choosing.primaryStat"] = "Ein zufälliger %s-Benutzer (%s) wird ausgewählt..."
L["choose.print.choosing.ranged"] = "Ein zufälliger Fernkämpfer wird ausgewählt..."
-- L["choose.print.choosing.sitting"] = ""
-- L["choose.print.choosing.sitting.noGroups"] = ""
L["choose.print.choosing.tank"] = "Ein zufälliger Tank wird ausgewählt..."
L["choose.print.choosing.tierToken"] = "Ein zufälliger %s (%s) wird ausgewählt..."
L["choose.print.chose.option"] = "Wähle Option #%d: %s."
L["choose.print.chose.player"] = "Wähle Option #%d: %s in Gruppe %d."
L["choose.print.noLastCommand"] = "Es gibt keinen vorherigen %s Befehl."
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
L["dataBroker.groupComp.groupQueued"] = "Deine Gruppe ist in der Warteschlange des Dungeonbrowsers."
L["dataBroker.groupComp.name"] = "Gruppenzusammensetzung"
L["dataBroker.groupComp.notInGroup"] = "nicht in einer Gruppe"
L["dataBroker.groupComp.openRaidTab"] = "Schlachtzug-Reiter öffnen"
-- L["dataBroker.groupComp.sitting"] = ""
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
L["options.header.interop"] = "Addonintegration"
L["options.header.party"] = "Wenn du in einer Gruppe bist (5 Mann Inhalt)"
L["options.header.raidAssist"] = "Wenn du Leiter oder Assistent bist"
L["options.header.raidLead"] = "Wenn du Schlachtzugsleiter bist"
L["options.header.sysMsg"] = "Gruppenbezogene Systemnachrichten verbessern"
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
L["options.widget.sortMode.desc.1"] = "Die gemachte/r Gesamtschaden/-Heilung-Sortiermethode wird nur funktionieren, wenn %s läuft." -- Needs review
L["options.widget.sortMode.desc.2"] = "Diese Sortiermethode kann nützlich sein, um schnelle Entscheidungen zu machen, wer eine Notheilung oder einen Battle-Rezz in einer Zufallsgruppe wert ist."
L["options.widget.sortMode.desc.3"] = "Du kannst auch %s eingeben oder auf das Minikarten-Symbol (oder auf den %s Button) Shift + rechtsklicken, um eine einmalige Sortierung, ohne die Einstellung zu ändern, durchzuführen."
L["options.widget.sortMode.text"] = "Spieler umordnen"
L["options.widget.splitOddEven.desc.1"] = "Wenn diese Option nicht angehakt ist werden Gruppen benachbart sein (das heißt 1-2 und 3-4, 1-3 und 4-6 oder 1-4 und 5-8.)"
L["options.widget.splitOddEven.desc.2"] = "Um Gruppen aufzuteilen, Gib %s ein, Klicke auf den %s Button oder Rechtsklicke das Minikarten-Symbol."
L["options.widget.splitOddEven.text"] = "Gerade/Ungerade Gruppen bei der Gruppenaufteilung benutzen."
L["options.widget.sysMsgClassColor.text"] = "Klassenfarbe hinzufügen"
L["options.widget.sysMsgGroupCompHighlight.text"] = "Neue Gruppenzusammensetzung hervorheben"
L["options.widget.sysMsgGroupComp.text"] = "Neue Gruppenzusammensetzung hinzufügen"
L["options.widget.sysMsgLabel.name"] = "Die Systemnachricht, die auftaucht, wenn ein Spieler einer Gruppe beitritt oder sie verlässt, kann verändert werden, um sie informativer zu machen. Zum Beispiel:"
L["options.widget.sysMsgRoleIcon.text"] = "Rollensymbol hinzufügen"
L["options.widget.sysMsgRoleName.text"] = "Rollenname hinzufügen"
L["options.widget.tankAssist.text"] = "Tanks zu Assistenten machen"
L["options.widget.tankMainTank.desc"] = "WoW erlaubt Addons leider das automatische Festlegen von Haupttanks nicht, aber wir können es zumindest überprüfen."
L["options.widget.tankMainTank.text"] = "Überprüfen, ob Haupttanks festgelegt sind"
L["options.widget.tankMark.text"] = "Zielmarkierungssymbole auf Tanks setzen"
L["options.widget.top.desc"] = "Die Organisation von Gruppen ist ein wichtiger, wenn auch manchmal langweiliger Teil der Führung eines Schlachtzugs. Dieses Addon hilft diesen Prozess zu automatisieren."
L["options.widget.watchChat.desc"] = "Öffnet den Schlachtzug-Reiter automatisch, wenn die Schlüsselwörter %s oder %s im Chat gesehen werden und du nicht im Kampf bist."
L["options.widget.watchChat.text"] = "Den Chat nach Anfragen, für Festegungen von Gruppen, beobachten"
-- L["phrase.assumingRangedForNow.plural"] = ""
-- L["phrase.assumingRangedForNow.singular"] = ""
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
L["word.alias.plural"] = "Aliasse"
L["word.alias.singular"] = "Alias"
L["word.and"] = "und"
L["word.damager.plural"] = "Schaden"
L["word.damager.singular"] = "Schaden"
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
