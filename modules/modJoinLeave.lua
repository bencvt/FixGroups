local A, L = unpack(select(2, ...))
local M = A:NewModule("modJoinLeave", "AceEvent-3.0", "AceTimer-3.0")
A.modJoinLeave = M

local format, gsub, pairs, strmatch, tostring = format, gsub, pairs, strmatch, tostring
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local ERR_RAID_YOU_JOINED = ERR_RAID_YOU_JOINED
local _G = _G

-- Lazily built.
local PATTERNS = false

-- TODO extend this to include role change messages. These aren't actual system messages though. Will need to hook ChatFrame_DisplaySystemMessageInPrimary.
--ROLE_CHANGED_INFORM = "%s is now %s.";
--ROLE_CHANGED_INFORM_WITH_SOURCE = "%s is now %s. (Changed by %s.)";
--ROLE_REMOVED_INFORM = "%s no longer has a selected role.";
--ROLE_REMOVED_INFORM_WITH_SOURCE = "%s no longer has a selected role. (Changed by %s.)";

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
  if message == ERR_RAID_YOU_JOINED then
    return UnitName("player"), true
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
  if A.DEBUG >= 2 then A.console:Debugf(M, "message=[%s]", A.util:Escape(message)) end

  -- Verify that this is a message we should modify.
  local matchedName, isJoin = matchMessage(message)
  if not matchedName then
    return message
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "matchedName=%s isJoin=%s", matchedName, tostring(isJoin)) end

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

  if A.options.sysMsg.roleName then
    local role = player and A.group.ROLE_NAME[player.role]
    if role and role ~= "unknown" then
      role = L["word."..role..".singular"]
    elseif player and player.isDamager then
      role = L["word.damager.singular"]
    end
    if role then
      message = gsub(message, namePattern, format("%s (%s)", matchedName, role), 1)
    end
  end

  if A.options.sysMsg.roleIcon then
    local role = player and A.group.ROLE_NAME[player.role]
    if role and role ~= "unknown" then
      if role == "tank" then
        role = A.util.TEXT_ICON.ROLE.TANK
      elseif role == "healer" then
        role = A.util.TEXT_ICON.ROLE.HEALER
      else
        role = A.util.TEXT_ICON.ROLE.DAMAGER
      end
    elseif player and player.isDamager then
      role = A.util.TEXT_ICON.ROLE.DAMAGER
    end
    if role then
      message = gsub(message, namePattern, format("%s %s", matchedName, role), 1)
    end
  end

  if A.options.sysMsg.classColor then
    local color = A.util:ClassColor(player and player.class)
    message = gsub(message, namePattern, format("|c%s%s|r", color, matchedName), 1)
  end

  if A.options.sysMsg.groupComp then
    local newComp = isPreview or A.group:GetComp(5)
    if A.options.sysMsg.groupCompHighlight then
      if isJoin then
        message = format("%s |cff00ff00%s.|r", message, newComp)
      else
        message = format("%s |cff999999%s.|r", message, newComp)
      end
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

