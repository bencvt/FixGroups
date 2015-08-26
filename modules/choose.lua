local A, L = unpack(select(2, ...))
local M = A:NewModule("choose", "AceConsole-3.0", "AceEvent-3.0")
A.choose = M
M.private = {
  options = {},
  optionsArePlayers = false,
  requestTimestamp = false,
  expectNumChatMsgs = false,
  expectSystemMsgPrefix = false,
  tmp1 = {},
  tmp2 = {},
}
local R = M.private
local H, HA = A.util.Highlight, A.util.HighlightAddon

-- Indexes correspond to A.group.ROLES constants.
local ROLE_NAMES = {"tank", "healer", "melee", "ranged", "unknown"}
-- Actually it's 255, but we'll be conservative.
local MAX_CHAT_LINE_LEN = 200
local SERVER_TIMEOUT = 5.0
local DELAY_ROLL = 0.5
-- Lazily populated.
local DISPATCH_TABLE, CLASS_ALIASES = false, false
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
  M:ScheduleTimer(function() RandomRoll(1, #R.options) end, DELAY_ROLL)
end

local function watchChat(event, message, sender)
  if not R.expectNumChatMsgs or not isExpecting(true) or not message then
    return
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "watchChat event=%s message=[%s] sender=%s expectNumChatMsgs=[%s]", event, message, sender, R.expectNumChatMsgs) end
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

function M:PrintHelp()
  local validTokens = format("%s, %s%s %s %s", H(L["choose.player.tierToken.conqueror.short"]), H(L["choose.player.tierToken.protector.short"]), A.util:LocaleSerialComma(), L["word.or"], H(L["choose.player.tierToken.vanquisher.short"]))
  local validRoles = format("%s, %s, %s, %s, %s%s %s %s", H(L["choose.player.any"]), H(L["choose.player.tank"]), H(L["choose.player.healer"]), H(L["choose.player.damager"]), H(L["choose.player.melee"]), A.util:LocaleSerialComma(), L["word.or"], H(L["choose.player.ranged"]))
  A.console:Printf(L["versionAuthor"], A.VERSION, HA(A.AUTHOR))
  print(format(L["choose.help.header"], H("/choose"), H("/fg choose")))
  print(format("  %s - %s", H("/choose "..L["choose.help.option.arg"]), L["choose.help.option"]))
  print(format("  %s - %s", H("/choose "..L["choose.help.class.arg"]), L["choose.help.class"]))
  print(format("  %s - %s", H("/choose "..L["choose.help.tierToken.arg"]), format(L["choose.help.tierToken"], validTokens)))
  print(format("  %s - %s", H("/choose "..L["choose.help.role.arg"]), format(L["choose.help.role"], validRoles)))
  print(format(L["choose.help.examples"], H("/choose examples")))
end

function M:PrintExamples()
  A.console:Printf(L["versionAuthor"], A.VERSION, HA(A.AUTHOR))
  print(format(L["choose.examples.header"], H("/choose")))
  print("  "..H(format("/choose %s", L["choose.role.melee"])))
  print("  "..H(format("/choose %s", A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["HUNTER"]))))
  print("  "..H(format("/choose %s", L["choose.examples.playerNames"])))
  print("  "..H(format("/choose %s", L["choose.examples.giveUpOrNot"])))
  print("  "..H(format("/choose %s", L["choose.examples.raids"])))
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

local function getValidClasses(mode, arg)
  if mode == "class" then
    return arg
  elseif mode == "tierToken" then
    local c = wipe(R.tmp1)
    if arg == "conqueror" then
      c["PALADIN"] = true
      c["PRIEST"] = true
      c["WARLOCK"] = true
      c["DEMONHUNTER"] = true
    elseif arg == "protector" then
      c["WARRIOR"] = true
      c["MONK"] = true
      c["SHAMAN"] = true
      c["HUNTER"] = true
    elseif arg == "vanquisher" then
      c["DEATHKNIGHT"] = true
      c["MAGE"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
    else
      A.console:Errorf(M, "invalid tier token %s!", tostring(arg or "<nil>"))
    end
    return c
  elseif mode == "armor" then
    local c = wipe(R.tmp1)
    if arg == "cloth" then
      c["PRIEST"] = true
      c["MAGE"] = true
      c["WARLOCK"] = true
    elseif arg == "leather" then
      c["MONK"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
      c["DEMONHUNTER"] = true
    elseif arg == "mail" then
      c["SHAMAN"] = true
      c["HUNTER"] = true
    elseif arg == "plate" then
      c["WARRIOR"] = true
      c["DEATHKNIGHT"] = true
      c["PALADIN"] = true
    else
      A.console:Errorf(M, "invalid armor type %s!", tostring(arg or "<nil>"))
    end
    return c
  elseif mode == "primaryStat" then
    local c = wipe(R.tmp1)
    if arg == "intellect" then
      c["PALADIN"] = true
      c["MONK"] = true
      c["DRUID"] = true
      c["PRIEST"] = true
      c["MAGE"] = true
      c["WARLOCK"] = true
      c["SHAMAN"] = true
    elseif arg == "agility" then
      c["MONK"] = true
      c["DRUID"] = true
      c["ROGUE"] = true
      c["SHAMAN"] = true
      c["HUNTER"] = true
      c["DEMONHUNTER"] = true
    elseif arg == "strength" then
      c["WARRIOR"] = true
      c["DEATHKNIGHT"] = true
      c["PALADIN"] = true
    else
      A.console:Errorf(M, "invalid primary stat %s!", tostring(arg or "<nil>"))
    end
    return c
  end
end

local function choosePlayer(mode, arg)
  if isExpecting() then
    return
  end

  local validClasses = getValidClasses(mode, arg)
  R.optionsArePlayers = true
  wipe(R.options)
  local include
  A.group:BuildUniqueNames()
  for _, player in pairs(A.group:GetRoster()) do
    if not player.isUnknown then
      if mode == "fromGroup" then
        include = (player.group == arg)
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
      elseif mode == ROLE_NAMES[player.role] then
        include = true
      else
        include = validClasses[player.class]
      end
      if include then
        tinsert(R.options, player.uniqueName)
      end
    end
  end
  sort(R.options)
  
  local arg2
  if validClasses then
    local localClasses = wipe(R.tmp2)
    local cMale, cFemale
    for _, class in ipairs(CLASS_SORT_ORDER) do
      if validClasses[class] then
        cMale, cFemale = LOCALIZED_CLASS_NAMES_MALE[class], LOCALIZED_CLASS_NAMES_FEMALE[class]
        tinsert(localClasses, (mode == "class") and A.util:LocaleLowerNoun(cMale) or cMale)
        if cMale ~= cFemale then
          tinsert(localClasses, (mode == "class") and A.util:LocaleLowerNoun(cFemale) or cFemale)
        end
      end
    end
    if mode == "class" then
      arg = A.util:LocaleTableConcat(localClasses, L["word.or"])
    else
      arg, arg2 = L["choose.player."..mode.."."..arg], tconcat(localClasses, "/")
    end
  elseif mode == "sitting" then
    arg = A.util:GetMaxGroupsForInstance() + 1
  elseif mode == "notMe" then
    if IsInRaid() then
      arg = A.group:GetPlayer(UnitName("player")).uniqueName
    else
      arg = A.util:GetUniqueNameParty("player")
    end
  elseif mode == "guildmate" then
    arg = GetGuildInfo("player")
  end

  local line = format(L["choose.print.choosing."..mode], arg, arg2)
  if mode == "sitting" and arg >= 8 then
    line = L["choose.print.choosing.sitting.noGroups"]
  end

  if #R.options > 0 then
    announceChoicesAndRoll(true, line)
  else
    announceChoicesAndRoll(false, line)
    A.console:Print(L["choose.print.noPlayers"])
  end
end

local function chooseMultipleClasses(args)
  local validClasses = wipe(R.tmp1)
  local found
  for c in gmatch(strlower(args), "[^/]+") do
    c = CLASS_ALIASES[strtrim(c)]
    if not c then
      return false
    end
    found = true
    validClasses[c] = true
  end
  if not found then
    return false
  end
  choosePlayer("class", validClasses)
  return true
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

local function buildDispatchTable()
  if DISPATCH_TABLE then
    return
  end

  -- Base dispatch table.
  DISPATCH_TABLE = {
    help          ={M.PrintHelp},
    about         ={M.PrintHelp},
    example       ={M.PrintExamples},
    examples      ={M.PrintExamples},
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
    conqueror     ={choosePlayer, "tierToken", "conqueror"},
    conq          ={choosePlayer, "tierToken", "conqueror"},
    protector     ={choosePlayer, "tierToken", "protector"},
    prot          ={choosePlayer, "tierToken", "protector"},
    vanquisher    ={choosePlayer, "tierToken", "vanquisher"},
    vanq          ={choosePlayer, "tierToken", "vanquisher"},
    intellect     ={choosePlayer, "primaryStat", "intellect"},
    intel         ={choosePlayer, "primaryStat", "intellect"},
    int           ={choosePlayer, "primaryStat", "intellect"},
    agility       ={choosePlayer, "primaryStat", "agility"},
    agi           ={choosePlayer, "primaryStat", "agility"},
    strength      ={choosePlayer, "primaryStat", "strength"},
    str           ={choosePlayer, "primaryStat", "strength"},
    cloth         ={choosePlayer, "armor", "cloth"},
    leather       ={choosePlayer, "armor", "leather"},
    mail          ={choosePlayer, "armor", "mail"},
    plate         ={choosePlayer, "armor", "plate"},
  }
  -- Add non-localized class names.
  CLASS_ALIASES = {}
  for _, class in ipairs(CLASS_SORT_ORDER) do
    CLASS_ALIASES[strlower(class)] = class
    DISPATCH_TABLE[strlower(class)] = {choosePlayer, "class", {[class]=true}}
  end

  -- Start a second table of command aliases, to be merged into
  -- DISPATCH_TABLE later on.
  local add = wipe(R.tmp1)

  -- Add localized class names.
  for class, alias in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    CLASS_ALIASES[gsub(strlower(alias), " ", "")] = class
  end
  for class, alias in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    CLASS_ALIASES[gsub(strlower(alias), " ", "")] = class
  end
  -- Add shorthand aliases.
  CLASS_ALIASES["warr"] = "WARRIOR"
  CLASS_ALIASES["dk"] = "DEATHKNIGHT"
  CLASS_ALIASES["pal"] = "PALADIN"
  CLASS_ALIASES["pala"] = "PALADIN"
  CLASS_ALIASES["pally"] = "PALADIN"
  CLASS_ALIASES["lock"] = "WARLOCK"
  CLASS_ALIASES["sham"] = "SHAMAN"
  CLASS_ALIASES["shammy"] = "SHAMAN"
  CLASS_ALIASES["dh"] = "DEMONHUNTER"
  -- Best guesses at non-English shorthand. Feel free to open a ticket if
  -- there's a commonly-used shorthand/slang for a WoW class in your language
  -- missing from this list.
  CLASS_ALIASES["guerr"] = "WARRIOR"
  CLASS_ALIASES["chevalier"] = "DEATHKNIGHT" -- frFR Chevalier de la mort
  CLASS_ALIASES["caballero"] = "DEATHKNIGHT" -- esES/esMX Caballero de la Muerte
  CLASS_ALIASES["cavaleiro"] = "DEATHKNIGHT" -- ptBR Cavaleiro da Morte
  CLASS_ALIASES["cavaliere"] = "DEATHKNIGHT" -- itIT Cavaliere della Morte
  CLASS_ALIASES["chev"] = "DEATHKNIGHT"
  CLASS_ALIASES["cab"] = "DEATHKNIGHT"
  CLASS_ALIASES["cav"] = "DEATHKNIGHT"
  CLASS_ALIASES["hexen"] = "WARLOCK" -- deDE Hexenmeister/Hexenmeisterin
  CLASS_ALIASES["scham"] = "SHAMAN"
  CLASS_ALIASES["cham"] = "SHAMAN"
  CLASS_ALIASES["xam"] = "SHAMAN"
  local d
  for alias, class in pairs(CLASS_ALIASES) do
    d = DISPATCH_TABLE[strlower(class)]
    if d then
      add[alias] = d
    end
  end

  -- Add localized aliases for chooseGroup and choosePlayer commands.
  add[strlower(L["choose.group"])] = DISPATCH_TABLE.group
  for cmd, d in pairs(DISPATCH_TABLE) do
    if d[1] == choosePlayer and d[2] ~= "class" then
      if d[3] then
        add[strlower(L["choose.player."..d[2].."."..d[3]])] = d
      else
        add[strlower(L["choose.player."..d[2]])] = d
      end
    end
  end
  add[strlower(L["choose.player.tierToken.conqueror.short"])] = DISPATCH_TABLE.conq
  add[strlower(L["choose.player.tierToken.protector.short"])] = DISPATCH_TABLE.prot
  add[strlower(L["choose.player.tierToken.vanquisher.short"])] = DISPATCH_TABLE.vanq

  -- Add group1, group2, etc., and their localized aliases.
  for i = 1, 8 do
    local d = {choosePlayer, "fromGroup", i}
    add["g"..i] = d
    add["group"..i] = d
    add["party"..i] = d
    add[strlower(L["choose.player.fromGroup"])..i] = d
  end

  -- Finally, merge into DISPATCH_TABLE, with original entries taking
  -- precedence over aliases.
  for cmd, d in pairs(add) do
    if strfind(cmd, "[ /,]") or cmd ~= strlower(strtrim(cmd)) or cmd == "" then
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
  elseif args == "" then
    -- TODO: GUI
    M:PrintHelp()
  elseif strfind(args, SPACE_OR_SPACE) then
    chooseOption(",", gsub(args, SPACE_OR_SPACE, ","))
  elseif strfind(args, ",") then
    chooseOption(",", args)
  elseif strfind(args, " ") then
    chooseOption(" ", args)
  elseif strfind(args, "/") and chooseMultipleClasses(args) then
    return
  else
    A.console:Printf(L["choose.print.badArgument"], H(args), H("/choose"))
  end
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
  A.console:Debug(M, "CLASS_ALIASES:")
  for _, alias in pairs(A.util:SortedKeys(CLASS_ALIASES, R.tmp1)) do
    A.console:DebugMore(M, format("  %s=%s", alias, CLASS_ALIASES[alias]))
  end
end
