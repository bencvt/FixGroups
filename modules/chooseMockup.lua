--- Implement the /choose, /list, and /listself console commands.
local A, L = unpack(select(2, ...))
local M = A:NewModule("chooseMockup")
A.chooseMockup = M

local format, print = format, print
local RANDOM_ROLL_RESULT = RANDOM_ROLL_RESULT

local THRALL = format("|r|c%s%s|r", A.util:ClassColor("SHAMAN"), L["character.thrall"])

local function lead(message)
  return format("|cffff7f00[Raid] [%s|cffff7f00] %s|r", THRALL, message)
end

local function raid(sender, class, message)
  return format("|cffff7f00[Raid] [|c%s%s|r|cffff7f00] %s|r", A.util:ClassColor(class), sender, message)
end

local function inpt(cmd)
  return format("|cffffffff> %s|r", cmd)
end

local function roll(result, lo, hi)
  return A.util:ColorSystem(format(RANDOM_ROLL_RESULT, L["character.thrall"], result, lo, hi))
end

function M:Mockup(addLineFunc)
  local a = addLineFunc
  a(lead("who is picking up ammo?"))
  a(lead("no volunteers...i'll just pick someone"))
  a(inpt("/choose hunter"))
  a(lead(format(L["choose.print.choosing.class"], "hunter").." 1=Hemet 2=Rexxar 3=Sylvanas"))
  a(roll(2, 1, 3))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 2, "Rexxar", 4)))
  a(" ")
  a(" ")
  a(lead("any volunteers to get the first interrupt?"))
  a(lead("no one? okay, i'll find a \"volunteer\" =p"))
  a(inpt("/choose melee"))
  a(lead(format(L["choose.print.choosing.melee"]).." 1=Darion 2=Garona 3=Garrosh 4=Staghelm 5=Taran 6="..L["character.thrall"].." 7=Valeera 8=Varian 9=Yrel"))
  a(roll(9, 1, 9))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 9, "Yrel", 2)))
  a(" ")
  a(" ")
  a(lead("let's flip a coin to see what boss we do next lol"))
  a(inpt("/choose high council or kormrok"))
  a(lead(format(L["choose.print.choosing.option"]).." 1=high council 2=kormrok"))
  a(roll(1, 1, 2))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.option"], 1, "high council")))
  a(" ")
  a(" ")
  a(raid("Garona", "ROGUE", "sorry guys I need to be afk for this next pull, my kid just made a mess"))
  a(lead("okay, i know everyone sitting out wants to get in for these mythic bosses"))
  a(lead("you're all equally skilled so i'm just going to roll the dice to see who gets to sub in"))
  a(inpt("/choose sitting"))
  a(lead(format(L["choose.print.choosing.sitting"], 7).." 1=Edwin 2=Rhonin 3=Senjin 4=Vanessa"))
  a(roll(2, 1, 4))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 2, "Rhonin", 8)))
  a(" ")
  a(" ")
  a(lead("which healer wants to go in the second portal?"))
  a(raid("Liadrin", "PALADIN", "me i guess"))
  a(raid("Anduin", "PRIEST", "I can"))
  a(raid("Drekthar", "SHAMAN", "doesn't matter, i can if you want"))
  a(lead("yay, volunteers!"))
  a(lead("we only need one, so"))
  a(inpt("/choose Liadrin, Anduin, Drek"))
  a(lead(format(L["choose.print.choosing.option"]).." 1=Liadrin 2=Anduin 3=Drek"))
  a(roll(1, 1, 3))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.option"], 1, "Liadrin")))
  a(" ")
  a(" ")
  a(lead("since no one rolled on this tier token, i'll just loot it to someone at random for a chance at warforged/socket/etc."))
  a(inpt("/choose vanq"))
  a(lead(format(L["choose.print.choosing.tierToken"], "Vanquisher", "Death Knight/Druid/Rogue/Mage").." 1=Celestine 2=Darion 3=Garona 4=Jaina 5=Khadgar 6=Malfurion 7=Staghelm 8=Valeera"))
  a(roll(5, 1, 8))
  a(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 5, "Khadgar", 4)))
end

function M:PrintMockup()
  M:Mockup(function(line) print(line) end)
end
