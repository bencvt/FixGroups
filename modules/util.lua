local A, L = unpack(select(2, ...))
local M = A:NewModule("util")
A.util = M
M.private = {
  tmp1 = {},
}
local R = M.private

M.TEXT_ICON = {
  ROLE = {
    -- TODO: other alternative sets including LFGROLE_BW, UI-LFG-ICON-ROLES, UI-LFG-ICON-PORTRAITROLES
    TANK      = INLINE_TANK_ICON,     -- alt: "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:32:48:0:16|t"
    HEALER    = INLINE_HEALER_ICON,   -- alt: "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:48:64:0:16|t"
    DAMAGER   = INLINE_DAMAGER_ICON,  -- alt: "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:16:32:0:16|t"
  },
  MARK = {
    STAR      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16:16:0:0|t",
    CIRCLE    = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16:16:0:0|t",
    DIAMOND   = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16:16:0:0|t",
    TRIANGLE  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16:16:0:0|t",
    MOON      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16:16:0:0|t",
    SQUARE    = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16:16:0:0|t",
    CROSS     = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16:16:0:0|t",
    SKULL     = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16:16:0:0|t",
  },
}
M.GROUP_COMP_STYLE = {
  ICONS_FULL = 1,
  ICONS_SHORT = 2,
  GROUP_TYPE_FULL = 3,
  GROUP_TYPE_SHORT = 4,
  TEXT_FULL = 5,
  TEXT_SHORT = 6,
  VERBOSE = 999,
}

local floor, format, gmatch, gsub, ipairs, max, pairs, select, sort, strfind, strlower, strmatch, strsplit, tinsert, tostring, tremove, wipe = floor, format, gmatch, gsub, ipairs, max, pairs, select, sort, strfind, strlower, strmatch, strsplit, tinsert, tostring, tremove, wipe
local tconcat = table.concat
local ChatTypeInfo, GetAddOnMetadata, GetInstanceInfo, GetRealmName, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitFullName, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName = ChatTypeInfo, GetAddOnMetadata, GetInstanceInfo, GetRealmName, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitFullName, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName
local LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS = LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS

local LOCALE_SERIAL_COMMA =  (GetLocale() == "enUS") and "," or ""
local LOCALE_UPPERCASE_NOUNS = (GetLocale() == "deDE")
-- Lazily built.
local WATCH_CHAT_KEYWORDS, WATCH_CHAT_KEYWORDS_LIST = false, false

function M:LocaleLowerNoun(noun)
  return LOCALE_UPPERCASE_NOUNS and noun or strlower(noun)
end

function M:LocaleTableConcat(t, conjunction)
  conjunction = conjunction or L["word.and"]
  local sz = #t
  if sz == 0 then
    return ""
  elseif sz == 1 then
    return t[1]
  elseif sz == 2 then
    return format("%s %s %s", t[1], conjunction, t[2])
  end
  -- Temporarily modify the table get the ", and " in, then restore.
  local saveY, saveZ = t[sz-1], t[sz]
  t[sz-1] = format("%s%s %s %s", t[sz-1], LOCALE_SERIAL_COMMA, conjunction, t[sz])
  tremove(t)
  local result = tconcat(t, ", ")
  t[sz-1], t[sz] = saveY, saveZ
  return result
end

function M:AutoConvertTableConcat(t, sep)
  local t2 = wipe(R.tmp1)
  for _, v in ipairs(t) do
    tinsert(t2, tostring(v))
  end
  return tconcat(t2, sep)
end

function M:Escape(text)
  return gsub(text, "|", "||")
end

local function buildWatchChatKeywords()
  WATCH_CHAT_KEYWORDS = {}
  WATCH_CHAT_KEYWORDS_LIST = {}
  for kw in gmatch(gsub(L["gui.chatKeywords"], "%s+", ""), "[^,]+") do
    if kw ~= "" then
      WATCH_CHAT_KEYWORDS[strlower(kw)] = true
      tinsert(WATCH_CHAT_KEYWORDS_LIST, M:Highlight(kw))
    end
  end
  WATCH_CHAT_KEYWORDS_LIST = M:LocaleTableConcat(WATCH_CHAT_KEYWORDS_LIST, L["word.or"])
end

function M:WatchChatKeywordMatches(messageLower)
  if not WATCH_CHAT_KEYWORDS then
    buildWatchChatKeywords()
  end
  for pattern, _ in pairs(WATCH_CHAT_KEYWORDS) do
    if strfind(messageLower, pattern) then
      return true
    end
  end
end

function M:GetWatchChatKeywordList()
  if not WATCH_CHAT_KEYWORDS_LIST then
    buildWatchChatKeywords()
  end
  return WATCH_CHAT_KEYWORDS_LIST
end

function M:SortedKeys(tbl, keys)
  keys = wipe(keys or {})
  for k, _ in pairs(tbl) do
    tinsert(keys, k)
  end
  sort(keys)
  return keys
end

function M:IsLeader()
  return IsInGroup() and UnitIsGroupLeader("player")
end

function M:IsLeaderOrAssist()
  if IsInRaid() then
    return UnitIsRaidOfficer("player") or UnitIsGroupLeader("player")
  end
  return IsInGroup()  
end

function M:GetMaxGroupsForInstance()
  if not IsInInstance() then
    return 8
  end
  return max(6, floor(select(5, GetInstanceInfo()) / 5))
end

function M:GetFixedInstanceSize()
  local d = select(3, GetInstanceInfo())
  if d == 16 then
    -- Mythic
    return 20
  elseif d == 17 then
    -- Raid Finder: technically flex but for our purposes it's fixed.
    return 25
  end
end

function M:GetAddonNameAndVersion(name)
  name = name or A.NAME
  local v = GetAddOnMetadata(name, "Version")
  if v then
    if strmatch(v, "v.*") then
      return name.." "..v
    end
    return name.." v"..v
  end
  return name
end

function M:GetGroupChannel()
  if IsInRaid() then
    return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
  end
  return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
end

local function compMRU(m, r, u)
  if u > 0 then
    return format("%d+%d+%d", m, r, u)
  else
    return format("%d+%d", m, r)
  end
end

function M:FormatGroupComp(style, t, h, m, r, u, isInRaid)
  if style == M.GROUP_COMP_STYLE.ICONS_FULL then
    return format("%d%s %d%s %d%s%s",
      t, M.TEXT_ICON.ROLE.TANK,
      h, M.TEXT_ICON.ROLE.HEALER,
      m+r+u, M.TEXT_ICON.ROLE.DAMAGER,
      M:HighlightDim(compMRU(m, r, u)))
  elseif style == M.GROUP_COMP_STYLE.ICONS_SHORT then
    return format("%d%s %d%s %d%s",
      t, M.TEXT_ICON.ROLE.TANK,
      h, M.TEXT_ICON.ROLE.HEALER,
      m+r+u, M.TEXT_ICON.ROLE.DAMAGER)
  elseif style == M.GROUP_COMP_STYLE.GROUP_TYPE_FULL then
    return format("%s: %s",
      (isInRaid or IsInRaid()) and L["word.raid"] or L["word.party"],
      M:Highlight(format("%d/%d/%d (%s)", t, h, m+r+u, compMRU(m, r, u))))
  elseif style == M.GROUP_COMP_STYLE.GROUP_TYPE_SHORT then
    return format("%s: %s",
      (isInRaid or IsInRaid()) and L["word.raid"] or L["word.party"],
      M:Highlight(format("%d/%d/%d", t, h, m+r+u)))
  elseif style == M.GROUP_COMP_STYLE.TEXT_FULL then
    return format("%d/%d/%d (%s)", t, h, m+r+u, compMRU(m, r, u))
  elseif style == M.GROUP_COMP_STYLE.TEXT_SHORT then
    return format("%d/%d/%d", t, h, m+r+u)
  elseif style == M.GROUP_COMP_STYLE.VERBOSE then
    local unknown = (u > 0) and format(", %d %s", u, ((u == 1) and L["word.unknown.singular"] or L["word.unknown.plural"])) or ""
    return format("%d %s / %d %s / %d %s (%d %s, %d %s%s)",
      t,      ((t == 1)     and L["word.tank.singular"]     or L["word.tank.plural"]    ),
      h,      ((h == 1)     and L["word.healer.singular"]   or L["word.healer.plural"]  ),
      m+r+u,  ((m+r+u == 1) and L["word.damager.singular"]  or L["word.damager.plural"] ),
      m,      ((m == 1)     and L["word.melee.singular"]    or L["word.melee.plural"]   ),
      r,      ((r == 1)     and L["word.ranged.singular"]   or L["word.ranged.plural"]  ),
      unknown)
  else
    return M:FormatGroupComp(M.GROUP_COMP_STYLE.ICONS_FULL, t, h, m, r, u)
  end
end

function M:Highlight(text)
  return "|cff1784d1"..(text or self).."|r"
end

function M:HighlightAddon(text)
  return "|cff33ff99"..(text or self).."|r"
end

function M:HighlightDim(text)
  return "|cff999999"..(text or self).."|r"
end

function M:ColorSystem(text)
  local c = format("|cff%02x%02x%02x", ChatTypeInfo["SYSTEM"].r*0xff, ChatTypeInfo["SYSTEM"].g*0xff, ChatTypeInfo["SYSTEM"].b*0xff)
  return c..gsub(text, "%|r", "%|r%"..c).."|r"
end

function M:ClassColor(class)
  if class and RAID_CLASS_COLORS[class] then
    class = RAID_CLASS_COLORS[class].colorStr
  else
    class = false
  end
  return (class or "ff999999")
end

function M:UnitNameWithColor(unitID)
  return "|c"..M:ClassColor(select(2, UnitClass(unitID)))..(UnitName(unitID) or "Unknown").."|r"
end

function M:NameAndRealm(name)
  if strfind(name, "%-") then
    return name
  end
  local realm = select(2, UnitFullName(name))
  if not realm then
    realm = gsub(GetRealmName(), "[ %-]", "")
  end
  return realm and (name.."-"..realm) or name
end

function M:StripRealm(name)
  return strsplit("-", name, 2)
end

function M:BlankInline(height, width)
  return format("|TInterface\\AddOns\\%s\\media\\blank.blp:%d:%d:0:0|t", A.NAME, height or 8, width or 8)
end
