local A, L = unpack(select(2, ...))
local M = A:NewModule("modJoinLeave", "AceEvent-3.0", "AceTimer-3.0")
A.modJoinLeave = M

local format, gsub, pairs, strmatch, tostring = format, gsub, pairs, strmatch, tostring
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local _G = _G

-- Lazily built.
local PATTERNS = false

-- TODO maybe eventually extend this to include "You joined the group" and "%s is now Damage" messages.

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

function M:FilterSystemMsg(event, message, ...)
  if not A.options.enhanceGroupRelatedSystemMessages then
    return false, message, ...
  end
  local matchedName, isJoin = matchMessage(message)
  if not matchedName then
    return false, message, ...
  end
  if A.DEBUG >= 1 then A.console:Debugf(M, "message=[%s] matchedName=%s isJoin=%s", A.util:Escape(message), matchedName, tostring(isJoin)) end
  if isJoin then
    A.group:ForceBuildRoster(M, event..":Joined")
  end
  local player = A.group:FindPlayer(matchedName)
  if not isJoin then
    A.group:ForceBuildRoster(M, event..":Left")
    -- Despite the rebuild, it's still safe to keep using the player reference
    -- for the rest of this method.
  end
  local newComp = A.group:GetComp(5)
  local role = player and A.group.ROLE_NAMES[player.role]
  if role and role ~= "unknown" then
    role = format(" (%s)", A.util:LocaleLowerNoun(L["word."..role..".singular"]))
  elseif player and player.isDamager then
    role = format(" (%s)", A.util:LocaleLowerNoun(L["word.damager.singular"]))
  else
    role = ""
  end
  local color = A.util:ClassColor(player and player.class)
  local namePattern = gsub(matchedName, "%-", "%%-")
  message = gsub(message, namePattern, format("|c%s%s|r%s", color, matchedName, role), 1)
  message = format("%s %s.", message, newComp)
  return false, message, ...
end

function M:OnEnable()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", M.FilterSystemMsg)
end

function M:OnDisable()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", M.FilterSystemMsg)
end

