local A, L = unpack(select(2, ...))
local M = A:NewModule("Util")
A.util = M

local floor, max, select, strmatch, tconcat = math.floor, math.max, select, string.match, table.concat
local GetAddOnMetadata, GetInstanceInfo, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName = GetAddOnMetadata, GetInstanceInfo, IsInGroup, IsInInstance, IsInRaid, UnitClass, UnitIsGroupLeader, UnitIsRaidOfficer, UnitName
local LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS = LE_PARTY_CATEGORY_INSTANCE, RAID_CLASS_COLORS 

function M:tconcat2(t)
  local sz = #t
  if sz == 0 then
    return ""
  elseif sz == 1 then
    return t[1]
  elseif sz == 2 then
    return t[1].." "..L["and"].." "..t[2]
  end
  local tmp = t[sz]
  t[sz] = L["and"].." "..t[sz]
  local result = tconcat(t, ", ")
  t[sz] = tmp
  return result
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

function M:GetChannel()
  if IsInRaid() then
    return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
  end
  return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
end

function M:UnitNameWithColor(unitID)
  local c = select(2, UnitClass(unitID))
  if c and RAID_CLASS_COLORS[c] then
    c = RAID_CLASS_COLORS[c].colorStr
  end
  return "|c"..(c or "ff00991a")..(UnitName(unitID) or "Unknown").."|r"
end
