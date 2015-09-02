local A, L = unpack(select(2, ...))
local M = A:NewModule("modJoinLeave", "AceEvent-3.0", "AceTimer-3.0")
A.modJoinLeave = M

local format, gsub, pairs, strmatch, tostring = format, gsub, pairs, strmatch, tostring
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local _G = _G

-- Lazily built.
local PATTERNS = false

-- TODO extend this to include:
--ERR_RAID_YOU_JOINED = "You have joined a raid group.";
--ROLE_CHANGED_INFORM = "%s is now %s.";
--ROLE_CHANGED_INFORM_WITH_SOURCE = "%s is now %s. (Changed by %s.)";

local function matchMessage(message)
  if not PATTERNS then
    local function makePattern(s)
      -- Change a formatting string into a string matching pattern.
      -- Example: "%s joins the party." becomes "([^%s]+) joins the party%."
      s = format(_G[s], "!NAME!")
      s = gsub(s, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      s = gsub(s, "!NAME!", "([^%%s]+)")
      return s
    end
    PATTERNS = {
      [makePattern("ERR_JOINED_GROUP_S")]           = true,
      [makePattern("ERR_LEFT_GROUP_S")]             = false,
      [makePattern("ERR_RAID_MEMBER_ADDED_S")]      = true,
      [makePattern("ERR_RAID_MEMBER_REMOVED_S")]    = false,
      [makePattern("ERR_INSTANCE_GROUP_ADDED_S")]   = true,
      [makePattern("ERR_INSTANCE_GROUP_REMOVED_S")] = false,
    }
  end
  local name
  for pattern, isJoin in pairs(PATTERNS) do
    name = strmatch(message, pattern)
    if name then
      return name, isJoin
    end
  end
end

function M:Modify(message, isPreview)
  -- Exit early if no modifications enabled in options.
  local found
  for _, value in pairs(A.options.sysMsg) do
    if value then
      found = true
    end
  end
  if not found then
    return message
  end

  -- Verify that this is a message we should modify.
  local matchedName, isJoin = matchMessage(message)
  if not matchedName then
    return message
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "message=[%s] matchedName=%s isJoin=%s", A.util:Escape(message), matchedName, tostring(isJoin)) end

  -- Get player from roster.
  local player
  if isPreview then
    player = A.group.EXAMPLE_PLAYER
  else
    if isJoin then
      A.group:ForceBuildRoster(M, "joined")
    end
    player = A.group:FindPlayer(matchedName)
    if not isJoin then
      A.group:ForceBuildRoster(M, "left")
      -- Despite the rebuild, it's still safe to keep using the player reference
      -- for the rest of this method.
    end
  end

  local namePattern = gsub(matchedName, "%-", "%%-")

  if A.options.sysMsg.roleName or A.options.sysMsg.roleIcon then
    local role = player and A.group.ROLE_NAME[player.role]
    local n = ""
    if role and role ~= "unknown" then
      if A.options.sysMsg.roleIcon then
        if role == "tank" then
          n = A.util.TEXT_ICON.ROLE.TANK
        elseif role == "healer" then
          n = A.util.TEXT_ICON.ROLE.HEALER
        else
          n = A.util.TEXT_ICON.ROLE.DAMAGER
        end
      end
      if A.options.sysMsg.roleName then
        n = n..((n == "") and n or " ")..L["word."..role..".singular"]
      end
    elseif player and player.isDamager then
      if A.options.sysMsg.roleIcon then
        n = A.util.TEXT_ICON.ROLE.DAMAGER
      end
      if A.options.sysMsg.roleName then
        n = n..((n == "") and n or " ")..L["word.damager.singular"]
      end
    end
    role = (n == "") and n or format(" (%s)", n)
    message = gsub(message, namePattern, format("%s%s", matchedName, role), 1)
  end

  if A.options.sysMsg.classColor then
    local color = A.util:ClassColor(player and player.class)
    message = gsub(message, namePattern, format("|c%s%s|r", color, matchedName), 1)
  end

  if A.options.sysMsg.groupComp then
    local newComp
    if isPreview then
      newComp = A.util:FormatGroupComp(5, 2,3,10, 4,6,0)
    else
      newComp = A.group:GetComp(5)
    end
    if A.options.sysMsg.groupCompDim then
      message = format("%s %s.", message, A.util:HighlightDim(newComp))
    else
      message = format("%s %s.", message, newComp)
    end
  end

  return message
end

function M:FilterSystemMsg(event, message, ...)
  return false, M:Modify(message, false), ...
end

function M:OnEnable()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", M.FilterSystemMsg)
end

function M:OnDisable()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", M.FilterSystemMsg)
end

