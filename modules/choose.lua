local A, L = unpack(select(2, ...))
local M = A:NewModule("choose", "AceConsole-3.0", "AceEvent-3.0")
A.choose = M
M.private = {
  options = {},
  optionsArePlayers = false,
  rollTimestamp = false,
  rollPrefix = false,
  tmp1 = {},
  tmp2 = {},
}
local R = M.private

-- Indexes correspond to A.raid.ROLES constants.
local ROLE_NAMES = {"tank", "melee", "unknown", "ranged", "healer"}
-- Actually it's 255, but we'll be conservative.
local MAX_CHAT_LINE_LEN = 250
local ROLL_TIMEOUT = 10.0
-- Lazily populated.
local CLASS_ALIASES = false

local format, ipairs, pairs, print, select, sort, strfind, strgmatch, strgsub, strlen, strlower, strsplit, strsub, strtrim, tconcat, time, tinsert, tonumber, tostring, wipe = string.format, ipairs, pairs, print, select, sort, string.find, string.gmatch, string.gsub, string.len, string.lower, string.split, string.sub, string.trim, table.concat, time, table.insert, tonumber, tostring, wipe
local GetSpecialization, GetSpecializationInfo, IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitName, UnitGroupRolesAssigned = GetSpecialization, GetSpecializationInfo, IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitName, UnitGroupRolesAssigned
local CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT = CLASS_SORT_ORDER, LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT

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
end

local function sendMessage(message)
  if IsInGroup() then
    SendChatMessage(message, A.util:GetGroupChannel())
  else
    A.console:Print(message)
  end
end

function M:CHAT_MSG_SYSTEM(event, message)
  if A.debug >= 2 then A.console:Debugf(M, "event=%s message=[%s] rollPrefix=[%s]", event, message, tostring(R.rollPrefix)) end
  if not R.rollTimestamp or (R.rollTimestamp + ROLL_TIMEOUT - time() <= 0) then
    R.rollTimestamp = false
    return
  end
  local i = strfind(message, R.rollPrefix)
  if not i then
    return
  end
  R.rollTimestamp = false
  local v = strsub(message, i + strlen(R.rollPrefix))
  v = strsub(v, 1, strfind(v, " "))
  local choseIndex = tonumber(strtrim(v))
  local choseValue = choseIndex > 0 and choseIndex <= #R.options and R.options[choseIndex] or "?"
  if R.optionsArePlayers then
    local player = A.raid:FindPlayer(choseValue)
    if player and player.group then
      sendMessage(format(L["choose.print.chose.player"], choseIndex, choseValue, player.group))
      return
    end
  end
  sendMessage(format(L["choose.print.chose.option"], choseIndex, choseValue))
end

function M:PrintHelp()
  local validOptions
  A.console:Printf(L["versionAuthor"], A.version, "|cff33ff99"..A.author.."|r")
  print(format(L["choose.help.header"], "|cff1784d1/choose|r", "|cff1784d1/fg choose|r"))
  --print(format("  |cff1784d1/choose help|r %s |cff1784d1/choose about|r - %s", L["word.or"], L["choose.help.help"]))
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.option.arg"], L["choose.help.option"]))
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.class.arg"], L["choose.help.class"]))
  validOptions = format("|cff1784d1%s|r, |cff1784d1%s|r%s %s |cff1784d1%s|r", L["choose.tierToken.conqueror.short"], L["choose.tierToken.protector.short"], A.util:LocaleSerialComma(), L["word.or"], L["choose.tierToken.vanquisher.short"])
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.token.arg"], format(L["choose.help.token"], validOptions)))
  validOptions = format("|cff1784d1%s|r, |cff1784d1%s|r, |cff1784d1%s|r, |cff1784d1%s|r, |cff1784d1%s|r%s %s |cff1784d1%s|r", L["choose.role.any"], L["choose.role.tank"], L["choose.role.healer"], L["choose.role.damager"], L["choose.role.melee"], A.util:LocaleSerialComma(), L["word.or"], L["choose.role.ranged"])
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.role.arg"], format(L["choose.help.role"], validOptions)))
  print(format(L["choose.help.examples"], "|cff1784d1/choose examples|r"))
end

function M:PrintExamples()
  A.console:Printf(L["versionAuthor"], A.version, "|cff33ff99"..A.author.."|r")
  print(format(L["choose.examples.header"], "|cff1784d1/choose|r"))
  print(format("  |cff1784d1/choose %s|r", L["choose.role.melee"]))
  print(format("  |cff1784d1/choose %s|r", A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE["HUNTER"])))
  print("  |cff1784d1/choose Thisplayer Thatplayer|r")
  print("  |cff1784d1/choose give up,keep trying|r")
  print("  |cff1784d1/choose Highmaul, Blackrock Foundry, Hellfire Citadel")
end

local function isWaitingOnPreviousRoll()
  if R.rollTimestamp then
    local wait = R.rollTimestamp + ROLL_TIMEOUT - time()
    if wait > 0 then
      A.console:Printf(L["choose.print.busy"], wait)
      return true
    end
  end
end

local function announceAndRoll(mode, arg)
  -- Announce options, on multiple lines if needed.
  local line = L["choose.print.choosing."..mode]
  if arg then
    line = format(line, arg)
  end
  local numOptions = #R.options
  for i, option in ipairs(R.options) do
    option = tostring(i).."="..tostring(option)..((i < numOptions and numOptions > 1) and "," or ".")
    if line and strlen(line) + 1 + strlen(option) >= MAX_CHAT_LINE_LEN then
      sendMessage(line, A.util:GetGroupChannel())
      line = false
    end
    if line then
      line = line.." "..option
    else
      line = option
    end
  end
  if line then
    sendMessage(line, A.util:GetGroupChannel())
  end

  -- Roll.
  RandomRoll(1, numOptions)
  R.rollPrefix = format(RANDOM_ROLL_RESULT, UnitName("player"), 867, 530, 9)
  R.rollPrefix = strsub(R.rollPrefix, 1, strfind(R.rollPrefix, "867") - 1)
  R.rollTimestamp = time()
end

local function choosePlayer(mode, arg)
  if isWaitingOnPreviousRoll() then
    return
  end

  local validClasses = wipe(R.tmp1)
  if mode == "class" then
    validClasses[arg] = true
  elseif mode == "token" then
    if arg == "conqueror" then
      validClasses["PALADIN"] = true
      validClasses["PRIEST"] = true
      validClasses["WARLOCK"] = true
      validClasses["DEMONHUNTER"] = true
    elseif arg == "protector" then
      validClasses["WARRIOR"] = true
      validClasses["MONK"] = true
      validClasses["SHAMAN"] = true
      validClasses["HUNTER"] = true
    elseif arg == "vanquisher" then
      validClasses["DEATHKNIGHT"] = true
      validClasses["MAGE"] = true
      validClasses["DRUID"] = true
      validClasses["ROGUE"] = true
    else
      A.console:Errorf(M, "invalid tier token %s!", tostring(arg or "<nil>"))
      return
    end
  end
  
  R.optionsArePlayers = true
  wipe(R.options)
  if IsInRaid() then
    A.raid:BuildUniqueNames()
    for _, player in pairs(A.raid:GetRoster()) do
      if not player.isUnknown and not player.isSitting then
        if (mode == "player") or (mode == ROLE_NAMES[player.role]) or (mode == "dps" and player.isDPS) or ((mode == "class" or mode == "token") and validClasses[player.class]) then
          tinsert(R.options, player.uniqueName)
        end
      end
    end
  else
    -- Party.
    if mode == "melee" or mode == "ranged" then
      mode = "dps"
    end
    local unitID, include, role
    for i = 1, 5 do
      unitID = (i == 5) and "player" or ("party"..i)
      if UnitExists(unitID) then
        if mode == "player" then
          include = true
        elseif mode == "class" or mode == "token" then
          include = validClasses[select(2, UnitClass(unitID))]
        else
          role = UnitGroupRolesAssigned(unitID)
          if (not role or role == "NONE") and unitID == "player" then
            role = select(6, GetSpecializationInfo(GetSpecialization()))
          end
          if mode == "tank" then
            include = (role == "TANK")
          elseif mode == "healer" then
            include = (role == "HEALER")
          else
            include = (role ~= "TANK" and role ~= "HEALER")
          end
        end
        if include then
          tinsert(R.options, A.util:GetUniqueNameParty(unitID))
        end
      end
    end
  end
  
  if #R.options == 0 then
    A.console:Print(L["choose.print.noPlayers"])
    return
  end
  sort(R.options)
  
  if mode == "class" then
    local cFemale = A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_FEMALE[arg])
    arg = A.util:LocaleLowerNoun(LOCALIZED_CLASS_NAMES_MALE[arg])
    if arg ~= cFemale then
      arg = format("%s %s %s", arg, L["word.or"], cFemale)
    end
  elseif mode == "token" then
    local localClasses = wipe(R.tmp2)
    local cMale, cFemale
    for _, class in ipairs(CLASS_SORT_ORDER) do
      if validClasses[class] then
        cMale, cFemale = LOCALIZED_CLASS_NAMES_MALE[class], LOCALIZED_CLASS_NAMES_FEMALE[class]
        tinsert(localClasses, cMale)
        if cMale ~= cFemale then
          tinsert(localClasses, cFemale)
        end
      end
    end
    arg = format("%s (%s)", L["choose.tierToken."..arg], tconcat(localClasses, "/"))
  end
  
  announceAndRoll(mode, arg)
end

local function chooseOption(sep, args)
  if isWaitingOnPreviousRoll() then
    return
  end
  
  R.optionsArePlayers = false
  wipe(R.options)
  for option in strgmatch(args, "[^"..sep.."]+") do
    option = strtrim(option)
    if option ~= "" then
      tinsert(R.options, option)
    end
  end
  
  announceAndRoll("option", false)
end

local function getClass(className)
  if not CLASS_ALIASES then
    CLASS_ALIASES = {}
    for key, alias in pairs(LOCALIZED_CLASS_NAMES_MALE) do
      CLASS_ALIASES[strlower(key)] = key
      alias = strlower(alias)
      CLASS_ALIASES[strgsub(alias, " ", "")] = key
      alias = strsplit(alias, " ", 2)
      CLASS_ALIASES[alias] = key
    end
    for key, alias in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
      alias = strlower(alias)
      CLASS_ALIASES[strgsub(alias, " ", "")] = key
      alias = strsplit(alias, " ", 2)
      CLASS_ALIASES[alias] = key
    end
    CLASS_ALIASES["lock"] = "WARLOCK"
    CLASS_ALIASES["hexen"] = "WARLOCK" -- deDE Hexenmeister/Hexenmeisterin
    CLASS_ALIASES["dk"] = "DEATHKNIGHT"
    CLASS_ALIASES["dh"] = "DEMONHUNTER"
    CLASS_ALIASES["pal"] = "PALADIN"
    CLASS_ALIASES["pally"] = "PALADIN"
    CLASS_ALIASES["sham"] = "SHAMAN"
    CLASS_ALIASES["shammy"] = "SHAMAN"
  end
  return CLASS_ALIASES[strlower(strtrim(className))]
end

function M:Command(args)
  local argsLower = strlower(strtrim(args))
  if argsLower == "" or argsLower == "about" or argsLower == "help" then
    M:PrintHelp()
  elseif argsLower == "examples" or argsLower == "example" then
    M:PrintExamples()
  elseif argsLower == "player" or argsLower == "any" or argsLower == strlower(L["choose.role.any"]) then
    choosePlayer("player")
  elseif argsLower == "tank" or argsLower == strlower(L["choose.role.tank"]) then
    choosePlayer("tank")
  elseif argsLower == "healer" or argsLower == "heal" or argsLower == strlower(L["choose.role.healer"]) then
    choosePlayer("healer")
  elseif argsLower == "dps" or argsLower == "damager" or argsLower == strlower(L["choose.role.damager"]) then
    choosePlayer("dps")
  elseif argsLower == "melee" or argsLower == strlower(L["choose.role.melee"]) then
    choosePlayer("melee")
  elseif argsLower == "ranged" or argsLower == strlower(L["choose.role.ranged"]) then
    choosePlayer("ranged")
  elseif argsLower == "conq" or argsLower == "conqueror" or argsLower == strlower(L["choose.tierToken.conqueror"]) or argsLower == strlower(L["choose.tierToken.conqueror.short"]) then
    choosePlayer("token", "conqueror")
  elseif argsLower == "prot" or argsLower == "protector" or argsLower == strlower(L["choose.tierToken.protector"]) or argsLower == strlower(L["choose.tierToken.protector.short"]) then
    choosePlayer("token", "protector")
  elseif argsLower == "vanq" or argsLower == "vanquisher" or argsLower == strlower(L["choose.tierToken.vanquisher"]) or argsLower == strlower(L["choose.tierToken.vanquisher.short"]) then
    choosePlayer("token", "vanquisher")
  elseif strfind(args, ",") then
    chooseOption(",", args)
  elseif strfind(args, " ") then
    chooseOption(" ", args)
  else
    local class = getClass(args)
    if class then
      choosePlayer("class", class)
    else
      A.console:Printf(L["choose.print.badArgument"], "|cff1784d1"..args.."|r", "|cff1784d1/choose help|r")
    end
  end
end
