local A, L = unpack(select(2, ...))
local M = A:NewModule("util")
A.util = M

local floor, max, pairs, select, sort, strmatch, strsplit, tconcat, tinsert, tremove, wipe = math.floor, math.max, pairs, select, sort, string.match, strsplit, table.concat, table.insert, table.remove, wipe
local GetAddOnMetadata, GetInstanceInfo, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitFullName, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName = GetAddOnMetadata, GetInstanceInfo, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitFullName, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName
local LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS = LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS 

local SERIAL_COMMA = ((GetLocale() == "enUS") and "," or "")

function M:tconcat2(t)
  local sz = #t
  if sz == 0 then
    return ""
  elseif sz == 1 then
    return t[1]
  elseif sz == 2 then
    return t[1].." "..L["word.and"].." "..t[2]
  end
  -- Temporarily modify the table get the ", and " in, then restore.
  local saveY, saveZ = t[sz-1], t[sz]
  t[sz-1] = t[sz-1]..SERIAL_COMMA.." "..L["word.and"].." "..t[sz]
  tremove(t)
  local result = tconcat(t, ", ")
  t[sz-1], t[sz] = saveY, saveZ
  return result
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

function M:GetAddonNameAndVersion(name)
  name = name or A.name
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

function M:UnitClassColor(unitID)
  local c = select(2, UnitClass(unitID))
  if c and RAID_CLASS_COLORS[c] then
    c = RAID_CLASS_COLORS[c].colorStr
  end
  return (c or "ff00991a")
end

function M:UnitNameWithColor(unitID)
  return "|c"..M:UnitClassColor(unitID)..(UnitName(unitID) or "Unknown").."|r"
end

function M:UnitNameWithRealm(unitID)
  local name, realm = UnitFullName(unitID)
  return name.."-"..realm
end

function M:StripRealm(name)
  return strsplit("-", name, 2)
end
