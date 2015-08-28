local A, L = unpack(select(2, ...))
local M = A:NewModule("chooseCommand", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
A.chooseCommand = M
M.private = {
  options = {},
  optionsArePlayers = false,
  requestTimestamp = false,
  expectNumChatMsgs = false,
  expectSystemMsgPrefix = false,
  lastCommand = false,
  tmp1 = {},
  tmp2 = {},
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

-- Actually it's 255, but we'll be conservative.
local MAX_CHAT_LINE_LEN = 200
local SERVER_TIMEOUT = 5.0
local DELAY_GROUP_ROLL = 0.5
-- Lazily populated.
local DISPATCH_TABLE, CLASS_ALIAS = false, false
local SPACE_OR_SPACE = " "..strlower(L["word.or"]).." "

local format, gmatch, gsub, ipairs, pairs, print, select, sort, strfind, strlen, strlower, strmatch, strsplit, strsub, strtrim, time, tinsert, tonumber, tostring, unpack, wipe = format, gmatch, gsub, ipairs, pairs, print, select, sort, strfind, strlen, strlower, strmatch, strsplit, strsub, strtrim, time, tinsert, tonumber, tostring, unpack, wipe
local tconcat = table.concat
local GetGuildInfo, IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitIsDeadOrGhost, UnitIsInMyGuild, UnitIsUnit, UnitName, UnitGroupRolesAssigned = GetGuildInfo, IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitIsDeadOrGhost, UnitIsInMyGuild, UnitIsUnit, UnitName, UnitGroupRolesAssigned
local CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT = CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT

local function startExpecting(numChatMsgs, systemMsgPrefix)
  R.requestTimestamp = time()
  R.expectNumChatMsgs = numChatMsgs
  R.expectSystemMsgPrefix = systemMsgPrefix
  if A.DEBUG >= 1 then A.console:Debugf(M, "startExpecting numChatMsgs=%s systemMsgPrefix=[%s]", tostring(numChatMsgs), tostring(systemMsgPrefix)) end
end

local function stopExpecting()
  R.requestTimestamp = false
  R.expectNumChatMsgs = false
  R.expectSystemMsgPrefix = false
  if A.DEBUG >= 1 then A.console:Debugf(M, "stopExpecting") end
end

local function isExpecting(quiet)
  if R.requestTimestamp then
    if R.requestTimestamp + SERVER_TIMEOUT - time() < 0 then
      if A.DEBUG >= 1 then A.console:Debugf(M, "isExpecting timed out") end
      stopExpecting()
    else
      if not quiet then
        A.console:Print(L["choose.print.busy"])
      end
      return true
    end
  end
end

local function startRoll()
  local rollPrefix = format(RANDOM_ROLL_RESULT, UnitName("player"), 867, 530, 9)
  rollPrefix = strsub(rollPrefix, 1, strfind(rollPrefix, "867") - 1)
  startExpecting(false, rollPrefix)
  if IsInGroup() then
    -- Slow your roll some more.
    -- See comment in the announceChoicesAndRoll method for why.
    M:ScheduleTimer(function() RandomRoll(1, #R.options) end, DELAY_GROUP_ROLL)
  else
    RandomRoll(1, #R.options)
  end
end

local function watchChat(event, message, sender)
  if not R.expectNumChatMsgs or not isExpecting(true) or not message then
    return
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "watchChat event=%s message=[%s] sender=%s expectNumChatMsgs=[%s]", event, A.util:Escape(message), sender, R.expectNumChatMsgs) end
  if not UnitExists(sender) then
    sender = A.util:StripRealm(sender)
  end
  if sender ~= UnitName("player") then
    return
  end
  R.expectNumChatMsgs = R.expectNumChatMsgs - 1
  if R.expectNumChatMsgs <= 0 then
    if A.DEBUG >= 1 then A.console:Debugf(M, "received all expectNumChatMsgs, starting roll") end
    stopExpecting()
    startRoll()
  end
end

function M:OnEnable()
  local function slashCmd(args)
    M:Command(args)
  end
  -- "/pick" would be better, but that's already an emote.
  -- "/fg choose <args>" works as well, defined in the console module.
  M:RegisterChatCommand("choose", slashCmd)
  M:RegisterChatCommand("chose", slashCmd)
  M:RegisterChatCommand("choo", slashCmd)
  M:RegisterChatCommand("cho", slashCmd)
  M:RegisterEvent("CHAT_MSG_SYSTEM")
  M:RegisterEvent("CHAT_MSG_INSTANCE_CHAT",         watchChat)
  M:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER",  watchChat)
  M:RegisterEvent("CHAT_MSG_RAID",                  watchChat)
  M:RegisterEvent("CHAT_MSG_RAID_LEADER",           watchChat)
  M:RegisterEvent("CHAT_MSG_PARTY",                 watchChat)
  M:RegisterEvent("CHAT_MSG_PARTY_LEADER",          watchChat)
end

local function sendMessage(message, localOnly, prefixAddonName)
  if localOnly or not IsInGroup() then
    A.console:Print(message)
  elseif prefixAddonName then
    SendChatMessage(format("[%s] %s", A.NAME, message), A.util:GetGroupChannel())
  else
    SendChatMessage(message, A.util:GetGroupChannel())
  end
end

function M:CHAT_MSG_SYSTEM(event, message)
  local prefix = R.expectSystemMsgPrefix
  if A.DEBUG >= 2 then A.console:Debugf(M, "event=%s message=[%s] prefix=[%s]", event, message, tostring(prefix)) end
  if not prefix or not isExpecting(true) then
    return
  end
  local i = strfind(message, prefix)
  if not i then
    -- Some other system message.
    return
  end

  -- We have a match. Reset for the next /choose command and parse it.
  stopExpecting()
  local v = strsub(message, i + strlen(prefix))
  v = strsub(v, 1, strfind(v, " "))
  local choseIndex = tonumber(strtrim(v))
  local choseValue = choseIndex > 0 and choseIndex <= #R.options and R.options[choseIndex] or "?"

  -- Announce the winner.
  if R.optionsArePlayers then
    local player = A.group:FindPlayer(choseValue)
    if player and player.group then
      sendMessage(format(L["choose.print.chose.player"], choseIndex, choseValue, player.group), false, true)
      return
    end
  end
  sendMessage(format(L["choose.print.chose.option"], choseIndex, choseValue), false, true)
end

local function announceChoicesAndRoll(reallyRoll, line)
  -- Announce exactly what we'll be rolling on.
  -- Use on multiple lines if needed.
  local numOptions = #R.options
  local numLines = 0
  for i, option in ipairs(R.options) do
    option = tostring(i).."="..tostring(option)..((i < numOptions and numOptions > 1) and "," or ".")
    if line and strlen(line) + 1 + strlen(option) >= MAX_CHAT_LINE_LEN then
      sendMessage(line, not reallyRoll, false)
      numLines = numLines + 1
      line = false
    end
    if line then
      line = line.." "..option
    else
      line = option
    end
  end
  if line then
    numLines = numLines + 1
    sendMessage(line, not reallyRoll, false)
  end
  if reallyRoll then
    if IsInGroup() then
      -- Wait until our announcement of the options to chat gets echoed back to
      -- us before we /roll. If we don't, thanks to lag it's possible the /roll
      -- result will reach everyone BEFORE the announcement, which defeats the
      -- entire purpose of the /choose command.
      --
      -- We only trigger off the NUMBER of lines we're sending, not the actual
      -- content of the lines. The content could be modified by an addon, the
      -- mature language filter, or if the player is drunk.
      startExpecting(numLines, false)
    else
      startRoll()
    end
  end
end

local function getValidClasses(mode, modeType)
  if modeType == "class" then
    local c = wipe(R.tmp1)
    local class, found
    for alias in gmatch(gsub(strlower(mode), "%s+", ""), "[^/%+%|]+") do
      class = CLASS_ALIAS[alias]
      if not class then
        return false
      end
      found = true
      c[class] = true
    end
    return found and c or false
  elseif modeType == "tierToken" then
    local c = wipe(R.tmp1)
    if mode == "conqueror" then
      c["PALADIN"] = true
      c["PRIEST"] = true
      c["WARLOCK"] = true
      c["DEMONHUNTER"] = true
    elseif mode == "protector" then
      c["WARRIOR"] = true
      c["MONK"] = true
      c["SHAMAN"] = true
      c["HUNTER"] = true
    elseif mode == "vanquisher" then
      c["DEATHKNIGHT"] = true
      c["MAGE"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
    else
      A.console:Errorf(M, "invalid %s %s!", modeType, tostring(mode))
    end
    return c
  elseif modeType == "armor" then
    local c = wipe(R.tmp1)
    if mode == "cloth" then
      c["PRIEST"] = true
      c["MAGE"] = true
      c["WARLOCK"] = true
    elseif mode == "leather" then
      c["MONK"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
      c["DEMONHUNTER"] = true
    elseif mode == "mail" then
      c["SHAMAN"] = true
      c["HUNTER"] = true
    elseif mode == "plate" then
      c["WARRIOR"] = true
      c["DEATHKNIGHT"] = true
      c["PALADIN"] = true
    else
      A.console:Errorf(M, "invalid %s %s!", modeType, tostring(mode))
    end
    return c
  elseif modeType == "primaryStat" then
    local c = wipe(R.tmp1)
    if mode == "intellect" then
      c["PALADIN"] = true
      c["MONK"] = true
      c["DRUID"] = true
      c["PRIEST"] = true
      c["MAGE"] = true
      c["WARLOCK"] = true
      c["SHAMAN"] = true
    elseif mode == "agility" then
      c["MONK"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
      c["SHAMAN"] = true
      c["HUNTER"] = true
      c["DEMONHUNTER"] = true
    elseif mode == "strength" then
      c["WARRIOR"] = true
      c["DEATHKNIGHT"] = true
      c["PALADIN"] = true
    else
      A.console:Errorf(M, "invalid %s %s!", modeType, tostring(mode))
    end
    return c
  end
end

local function choosePlayer(mode, modeType)
  if A.DEBUG >= 1 then A.console:Debugf(M, "choosePlayer mode=%s modeType=%s", tostring(mode), tostring(modeType)) end
  if isExpecting() then
    return
  end

  local validClasses = getValidClasses(mode, modeType)
  R.optionsArePlayers = true
  wipe(R.options)
  local include
  A.group:ForceBuildRoster(M, "choosePlayer")
  A.group:BuildUniqueNames()
  for _, player in pairs(A.group:GetRoster()) do
    if not player.isUnknown then
      if modeType == "fromGroup" then
        include = (player.group == mode)
      elseif mode == "anyIncludingSitting" then
        include = true
      elseif player.isSitting or mode == "sitting" then
        include = (mode == "sitting")
      elseif mode == "any" then
        include = true
      elseif mode == "notMe" then
        include = not UnitIsUnit(player.unitID, "player")
      elseif mode == "dead" then
        include = UnitIsDeadOrGhost(player.unitID)
      elseif mode == "alive" then
        include = not UnitIsDeadOrGhost(player.unitID)
      elseif mode == "guildmate" then
        include = UnitIsInMyGuild(player.unitID)
      elseif mode == "damager" then
        include = player.isDamager
      elseif mode == "tank" or mode == "healer" or mode == "melee" then
        include = (A.group.ROLE_NAME[player.role] == mode)
      elseif mode == "ranged" then
        include = (A.group.ROLE_NAME[player.role] == "ranged" or A.group.ROLE_NAME[player.role] == "unknown")
      else
        include = validClasses[player.class]
      end
      if include then
        tinsert(R.options, player.uniqueName)
      end
    end
  end
  sort(R.options)
  
  local arg1 = mode
  local arg2
  if validClasses then
    local localClasses = wipe(R.tmp2)
    local cMale, cFemale
    for _, class in ipairs(CLASS_SORT_ORDER) do
      if validClasses[class] then
        cMale, cFemale = LOCALIZED_CLASS_NAMES_MALE[class], LOCALIZED_CLASS_NAMES_FEMALE[class]
        tinsert(localClasses, (modeType == "class") and A.util:LocaleLowerNoun(cMale) or cMale)
        if cMale ~= cFemale then
          tinsert(localClasses, (modeType == "class") and A.util:LocaleLowerNoun(cFemale) or cFemale)
        end
      end
    end
    if modeType == "class" then
      arg1 = A.util:LocaleTableConcat(localClasses, L["word.or"])
    else
      arg1 = strtrim(tostring(strsplit(",", L["choose.modeAliases."..mode])))
      arg2 = tconcat(localClasses, "/")
    end
  elseif mode == "sitting" then
    arg1 = A.util:GetMaxGroupsForInstance() + 1
  elseif mode == "notMe" then
    if IsInRaid() then
      arg1 = A.group:GetPlayer(UnitName("player")).uniqueName
    else
      arg1 = A.util:GetUniqueNameParty("player")
    end
  elseif mode == "guildmate" then
    arg1 = GetGuildInfo("player")
  end

  local line = format(L["choose.print.choosing."..(modeType or mode)], arg1, arg2)
  if mode == "sitting" and arg1 >= 8 then
    line = L["choose.print.choosing.sitting.noGroups"]
  end

  if mode == "melee" or mode == "ranged" then
    A.group:PrintIfThereAreUnknowns()
  end

  if #R.options > 0 then
    announceChoicesAndRoll(true, line)
  else
    announceChoicesAndRoll(false, line)
    A.console:Print(L["choose.print.noPlayers"])
  end
end

local function chooseClasses(args)
  if getValidClasses(args, "class") then
    choosePlayer(args, "class")
    return true
  end
end

local function chooseGroup()
  if isExpecting() then
    return
  end
  
  wipe(R.options)
  if IsInRaid() then
    for g = 1, 8 do
      if A.group:GetGroupSize(g) > 0 then
        tinsert(R.options, format("%s %d", L["choose.group"], g))
      end
    end
  else
    tinsert(R.options, format("%s %d", L["choose.group"], 1))
  end
  
  announceChoicesAndRoll(true, L["choose.print.choosing.group"])
end

local function chooseOption(sep, args)
  if isExpecting() then
    return
  end
  
  R.optionsArePlayers = false
  wipe(R.options)
  for option in gmatch(args, "[^"..sep.."]+") do
    option = strtrim(option)
    if option ~= "" then
      tinsert(R.options, option)
    end
  end

  announceChoicesAndRoll(true, L["choose.print.choosing.option"])
end

local function chooseLast()
  if R.lastCommand then
    M:Command(R.lastCommand)
  else
    A.console:Printf(L["choose.print.noLastCommand"], H("/choose"))
  end
end

local function buildDispatchTable()
  if DISPATCH_TABLE then
    return
  end

  -- Base dispatch table.
  DISPATCH_TABLE = {
    [""]          ={A.chooseGui.Open},
    window        ={A.chooseGui.Open},
    gui           ={A.chooseGui.Open},
    ui            ={A.chooseGui.Open},
    help          ={A.chooseGui.Open},
    about         ={A.chooseGui.Open},
    example       ={A.chooseGui.Open},
    examples      ={A.chooseGui.Open},
    group         ={chooseGroup},
    party         ={chooseGroup},
    guildmate     ={choosePlayer, "guildmate"},
    guildie       ={choosePlayer, "guildmate"},
    guildy        ={choosePlayer, "guildmate"},
    guild         ={choosePlayer, "guildmate"},
    any           ={choosePlayer, "any"},
    anyone        ={choosePlayer, "any"},
    anybody       ={choosePlayer, "any"},
    someone       ={choosePlayer, "any"},
    somebody      ={choosePlayer, "any"},
    player        ={choosePlayer, "any"},
    sitting       ={choosePlayer, "sitting"},
    bench         ={choosePlayer, "sitting"},
    standby       ={choosePlayer, "sitting"},
    inactive      ={choosePlayer, "sitting"},
    idle          ={choosePlayer, "sitting"},
    anyincludingsitting ={choosePlayer, "anyIncludingSitting"},
    anysitting          ={choosePlayer, "anyIncludingSitting"},
    ["any+sitting"]     ={choosePlayer, "anyIncludingSitting"},
    ["any|sitting"]     ={choosePlayer, "anyIncludingSitting"},
    ["any/sitting"]     ={choosePlayer, "anyIncludingSitting"},
    notme         ={choosePlayer, "notMe"},
    somebodyelse  ={choosePlayer, "notMe"},
    dead          ={choosePlayer, "dead"},
    alive         ={choosePlayer, "alive"},
    live          ={choosePlayer, "alive"},
    living        ={choosePlayer, "alive"},
    tank          ={choosePlayer, "tank"},
    healer        ={choosePlayer, "healer"},
    heal          ={choosePlayer, "healer"},
    damager       ={choosePlayer, "damager"},
    damage        ={choosePlayer, "damager"},
    dps           ={choosePlayer, "damager"},
    dd            ={choosePlayer, "damager"},
    melee         ={choosePlayer, "melee"},
    ranged        ={choosePlayer, "ranged"},
    conqueror     ={choosePlayer, "conqueror", "tierToken"},
    conq          ={choosePlayer, "conqueror", "tierToken"},
    protector     ={choosePlayer, "protector", "tierToken"},
    prot          ={choosePlayer, "protector", "tierToken"},
    vanquisher    ={choosePlayer, "vanquisher", "tierToken"},
    vanq          ={choosePlayer, "vanquisher", "tierToken"},
    intellect     ={choosePlayer, "intellect", "tierToken"},
    intel         ={choosePlayer, "intellect", "tierToken"},
    int           ={choosePlayer, "intellect", "tierToken"},
    agility       ={choosePlayer, "agility", "tierToken"},
    agi           ={choosePlayer, "agility", "tierToken"},
    strength      ={choosePlayer, "strength", "tierToken"},
    str           ={choosePlayer, "strength", "tierToken"},
    cloth         ={choosePlayer, "cloth", "armor"},
    leather       ={choosePlayer, "leather", "armor"},
    mail          ={choosePlayer, "mail", "armor"},
    plate         ={choosePlayer, "plate", "armor"},
    last          ={chooseLast},
    again         ={chooseLast},
    previous      ={chooseLast},
    prev          ={chooseLast},
    ["repeat"]    ={chooseLast},
    ["^"]         ={chooseLast},
    ["\""]        ={chooseLast},
  }
  -- Add non-localized class names.
  CLASS_ALIAS = {}
  local classLower
  for _, class in ipairs(CLASS_SORT_ORDER) do
    classLower = strlower(class)
    CLASS_ALIAS[classLower] = class
    DISPATCH_TABLE[classLower] = {choosePlayer, classLower, "class"}
  end

  -- Start a second table of command aliases, staged to be merged into
  -- DISPATCH_TABLE later on.
  local add = wipe(R.tmp1)

  -- Add localized class names.
  for class, alias in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    CLASS_ALIAS[gsub(strlower(alias), "%s+", "")] = class
  end
  for class, alias in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    CLASS_ALIAS[gsub(strlower(alias), "%s+", "")] = class
  end
  -- Add non-localized shorthand class aliases.
  CLASS_ALIAS["warr"] = "WARRIOR"
  CLASS_ALIAS["dk"] = "DEATHKNIGHT"
  CLASS_ALIAS["pal"] = "PALADIN"
  CLASS_ALIAS["pala"] = "PALADIN"
  CLASS_ALIAS["pally"] = "PALADIN"
  CLASS_ALIAS["lock"] = "WARLOCK"
  CLASS_ALIAS["sham"] = "SHAMAN"
  CLASS_ALIAS["shammy"] = "SHAMAN"
  CLASS_ALIAS["dh"] = "DEMONHUNTER"
  -- Add localized shorthand class aliases.
  for _, class in ipairs(CLASS_SORT_ORDER) do
    for alias in gmatch(gsub(strlower(L["choose.classAliases."..strlower(class)]), "%s+", ""), "[^,]+") do
      if alias ~= "" then
        CLASS_ALIAS[alias] = class
      end
    end
  end
  -- Add all class aliases to the staging table.
  local d
  for alias, class in pairs(CLASS_ALIAS) do
    d = DISPATCH_TABLE[strlower(class)]
    if d then
      add[alias] = d
    end
  end

  -- Add group1, group2, etc., and their localized aliases.
  for i = 1, 8 do
    local d = {choosePlayer, i, "fromGroup"}
    add["g"..i] = d
    add["group"..i] = d
    add["party"..i] = d
    for alias in gmatch(gsub(strlower(L["choose.modeAliases.fromGroup"]), "%s+", ""), "[^,]+") do
      if alias ~= "" then
        add[alias..i] = d
      end
    end
  end

  -- Add localized aliases for various other modes.
  for mode in gmatch("group,guildmate,any,sitting,anyIncludingSitting,notMe,dead,alive,tank,healer,damager,melee,ranged,conqueror,protector,vanquisher,intellect,agility,strength,cloth,leather,mail,plate", "[^,]+") do
    for alias in gmatch(gsub(strlower(L["choose.modeAliases."..mode]), "%s+", ""), "[^,]+") do
      if alias ~= "" then
        add[alias] = DISPATCH_TABLE[strlower(mode)]
      end
    end
  end
  -- Just in case they got missed in the locale file:
  for _, role in ipairs({"tank", "healer", "damager", "melee", "ranged"}) do
    for _, number in ipairs({"singular", "plural"}) do
      add[gsub(strlower(L["word."..role.."."..number]), "%s+", "")] = DISPATCH_TABLE[role]
    end
  end

  -- Finally, merge into DISPATCH_TABLE, with original entries taking
  -- precedence over aliases.
  for cmd, d in pairs(add) do
    if strfind(cmd, "[%s,]") or cmd ~= strlower(strtrim(cmd)) or cmd == "" then
      A.console:Errorf(M, "bad localized key [%s] for {%s}", cmd, A.util:AutoConvertTableConcat(d, ","))
    elseif not DISPATCH_TABLE[cmd] then
      DISPATCH_TABLE[cmd] = d
    end
  end
end

function M:Command(args)
  buildDispatchTable()
  args = strtrim(args)
  local dispatch = DISPATCH_TABLE[strlower(args)]
  if dispatch then
    local func, mode, args = unpack(dispatch)
    func(mode, args)
    if func == chooseLast then
      return
    end
  elseif strfind(args, SPACE_OR_SPACE) then
    chooseOption(",", gsub(args, SPACE_OR_SPACE, ","))
  elseif strfind(args, ",") then
    chooseOption(",", args)
  elseif strfind(args, " ") then
    chooseOption(" ", args)
  elseif strfind(args, "[/%+%|]") and chooseClasses(args) then
    -- Do nothing. The action is in the if clause above.
  else
    A.console:Printf(L["choose.print.badArgument"], H(args), H("/choose"))
    return
  end
  R.lastCommand = args
end

function M:Mockup(addLine)
  local cmd = function(t) return format("|cffffffff> %s|r", t) end
  local THRALL = format("|r|c%s%s|r", A.util:ClassColor("SHAMAN"), L["character.thrall"])
  local lead = function(t) return format("|cffff4809[Raid Leader] [%s|cffff4809] %s|r", THRALL, t) end
  local raid = function(s, c, t) return format("|cffff7f00[Raid] [|c%s%s|r|cffff7f00] %s|r", A.util:ClassColor(c), s, t) end
  local roll = function(r, lo, hi) return "|cffffff00"..format(RANDOM_ROLL_RESULT, L["character.thrall"], r, lo, hi).."|r" end
  addLine(lead("who is kiting the siegemakers?"))
  addLine(lead("no volunteers...i'll just pick someone"))
  addLine(cmd("/choose hunter"))
  addLine(lead(format(L["choose.print.choosing.class"], "hunter").." 1=Hemet 2=Rexxar 3=Sylvanas"))
  addLine(roll(2, 1, 3))
  addLine(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 2, "Rexxar", 4)))
  addLine(" ")
  addLine(" ")
  addLine(lead("any volunteers to get the last interrupt?"))
  addLine(lead("no one? okay, i'll find a \"volunteer\" =p"))
  addLine(cmd("/choose melee"))
  addLine(lead(format(L["choose.print.choosing.melee"]).." 1=Darion 2=Garona 3=Garrosh 4=Staghelm 5=Taran 6="..L["character.thrall"].." 7=Valeera 8=Varian 9=Yrel"))
  addLine(roll(9, 1, 9))
  addLine(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 9, "Yrel", 2)))
  addLine(" ")
  addLine(" ")
  addLine(lead("let's flip a coin to see what boss we do next lol"))
  addLine(cmd("/choose high council or kormrok"))
  addLine(lead(format(L["choose.print.choosing.option"]).." 1=high council 2=kormrok"))
  addLine(roll(1, 1, 2))
  addLine(lead("["..A.NAME.."] "..format(L["choose.print.chose.option"], 1, "high council")))
  addLine(" ")
  addLine(" ")
  addLine(lead("which healer wants to go in the second portal?"))
  addLine(raid("Liandrin", "PALADIN", "me i guess"))
  addLine(raid("Anduin", "PRIEST", "I can"))
  addLine(raid("Drekthar", "SHAMAN", "doesn't matter, i can if you want"))
  addLine(lead("yay, volunteers!"))
  addLine(lead("we only need one, so"))
  addLine(cmd("/choose Liandrin, Anduin, Drek"))
  addLine(lead(format(L["choose.print.choosing.option"]).." 1=Liandrin 2=Anduin 3=Drek"))
  addLine(roll(1, 1, 3))
  addLine(lead("["..A.NAME.."] "..format(L["choose.print.chose.option"], 1, "Liandrin")))
  addLine(" ")
  addLine(" ")
  addLine(lead("since no one rolled on this tier token, i'll just loot it to someone at random for a chance at warforged/socket/etc."))
  addLine(cmd("/choose vanq"))
  addLine(lead(format(L["choose.print.choosing.tierToken"], "Vanquisher", "death knight/druid/rogue/mage").." 1=Celestine 2=Darion 3=Garona 4=Jaina 5=Khadgar 6=Malfurion 7=Staghelm 8=Valeera"))
  addLine(roll(5, 1, 8))
  addLine(lead("["..A.NAME.."] "..format(L["choose.print.chose.player"], 5, "Khadgar", 4)))
end

function M:PrintMockup()
  M:Mockup(function(line) print(line) end)
end

function M:DebugPrintDispatchTable()
  buildDispatchTable()
  A.console:Debug(M, "DISPATCH_TABLE:")
  for _, cmd in pairs(A.util:SortedKeys(DISPATCH_TABLE, R.tmp1)) do
    A.console:DebugMore(M, format("  %s={%s}", cmd, A.util:AutoConvertTableConcat(DISPATCH_TABLE[cmd], ",")))
  end
end

function M:DebugPrintClassAliases()
  buildDispatchTable()
  A.console:Debug(M, "CLASS_ALIAS:")
  for _, alias in pairs(A.util:SortedKeys(CLASS_ALIAS, R.tmp1)) do
    A.console:DebugMore(M, format("  %s=%s", alias, CLASS_ALIAS[alias]))
  end
end
