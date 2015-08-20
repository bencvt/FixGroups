local A, L = unpack(select(2, ...))
local M = A:NewModule("choose", "AceConsole-3.0", "AceEvent-3.0")
A.choose = M
M.private = {
  tmp1 = {},
  options = {},
  optionsArePlayers = false,
  rollTimestamp = false,
  rollPrefix = false,
}
local R = M.private

-- Indexes correspond to A.raid.ROLES constants.
local ROLE_NAMES = {"tank", "melee", "unknown", "ranged", "healer"}
-- Actually it's 255, but we'll be conservative.
local MAX_CHAT_LINE_LEN = 250
local ROLL_TIMEOUT = 10.0
-- Lazily populated.
local CLASS_ALIASES = false

local format, ipairs, pairs, print, select, sort, strfind, strgmatch, strgsub, strlen, strlower, strsub, strtrim, time, tinsert, tonumber, tostring, wipe = string.format, ipairs, pairs, print, select, sort, string.find, string.gmatch, string.gsub, string.len, string.lower, string.sub, string.trim, time, table.insert, tonumber, tostring, wipe
local IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitName, UnitGroupRolesAssigned = IsInGroup, IsInRaid, RandomRoll, SendChatMessage, UnitClass, UnitExists, UnitName, UnitGroupRolesAssigned
local LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT = LOCALIZED_CLASS_NAMES_FEMALE, LOCALIZED_CLASS_NAMES_MALE, RANDOM_ROLL_RESULT

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
  A.console:Printf(L["versionAuthor"], A.version, "|cff33ff99"..A.author.."|r")
  print(format(L["choose.help.header"], "|cff1784d1/choose|r", "|cff1784d1/fg choose|r"))
  print(format("  |cff1784d1/choose help|r %s |cff1784d1/choose about|r - %s", L["word.or"], L["choose.help.help"]))
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.option.arg"], L["choose.help.option"]))
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.class.arg"], L["choose.help.class"]))
  print(format("  |cff1784d1/choose %s|r - %s", L["choose.help.role.arg"], format(L["choose.help.role"], "|cff1784d1tank|r, |cff1784d1healer|r, |cff1784d1dps|r, |cff1784d1ranged|r "..L["word.or"].." |cff1784d1melee|r")))
  print(format("  |cff1784d1/choose|r - %s", L["choose.help.blank"]))
  print(format(L["choose.help.examples"], "\"|cff1784d1/choose melee|r\", \"|cff1784d1/choose hunter|r\", \"|cff1784d1/choose A B C|r\", \"|cff1784d1/choose give up,keep trying|r\", \"|cff1784d1/choose Highmaul, Blackrock Foundry, Hellfire Citadel|r\""))
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
    elseif line then
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

local function choosePlayer(mode, class)
  if isWaitingOnPreviousRoll() then
    return
  end
  
  R.optionsArePlayers = true
  wipe(R.options)
  if IsInRaid() then
    A.raid:BuildUniqueNames()
    for _, player in pairs(A.raid:GetRoster()) do
      if not player.isUnknown and not player.isSitting then
        if (mode == "player") or (mode == ROLE_NAMES[player.role]) or (mode == "dps" and player.isDPS) or (mode == "class" and class == player.class) then
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
        elseif mode == "class" then
          include = (class == select(2, UnitClass(unitID)))
        else
          role = UnitGroupRolesAssigned(unitID)
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
    class = LOCALIZED_CLASS_NAMES_MALE[class]
    local classFemale = LOCALIZED_CLASS_NAMES_FEMALE[class]
    if classFemale and class ~= classFemale then
      class = class.." "..L["word.or"].." "..classFemale
    end
  end
  
  announceAndRoll(mode, class)
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
      CLASS_ALIASES[strlower(strgsub(key, " ", ""))] = key
      CLASS_ALIASES[strlower(strgsub(alias, " ", ""))] = key
    end
    for key, alias in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
      CLASS_ALIASES[strlower(strgsub(alias, " ", ""))] = key
    end
    CLASS_ALIASES["lock"] = "WARLOCK"
    CLASS_ALIASES["hexen"] = "WARLOCK" -- deDE Hexenmeister
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
  -- TODO accept localized roles
  if argsLower == "about" or argsLower == "help" then
    M:PrintHelp()
  elseif argsLower == "tank" then
    choosePlayer("tank")
  elseif argsLower == "healer" or argsLower == "heal" then
    choosePlayer("healer")
  elseif argsLower == "dps" or argsLower == "damager" then
    choosePlayer("dps")
  elseif argsLower == "melee" then
    choosePlayer("melee")
  elseif argsLower == "ranged" then
    choosePlayer("ranged")
  elseif argsLower == "" or argsLower == "any" or argsLower == "player" then
    choosePlayer("player")
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
