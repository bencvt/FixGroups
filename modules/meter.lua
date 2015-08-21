local A, L = unpack(select(2, ...))
local M = A:NewModule("meter")
A.meter = M
M.private = {
  snapshot = {},
  tmp1 = {},
}
local R = M.private

local DETAILS_SEGMENTS = {"overall", "current"}
local EMPTY = {}

local ipairs, pairs, select, tinsert, wipe = ipairs, pairs, select, table.insert, wipe
local GetUnitName = GetUnitName

local function loadTinyDPS()
  if not tdpsPlayer or not tdpsPet then
    return "TinyDPS", false
  end
  local found
  for _, player in pairs(tdpsPlayer) do
    if player.fight and player.fight[1] then
      found = true
      R.snapshot[player.name] = (player.fight[1].d or 0) + (player.fight[1].h or 0)
      for _, pet in ipairs(player.pet or EMPTY) do
        pet = tdpsPet[pet]
        if pet and pet.fight and pet.fight[1] then
          R.snapshot[player.name] = R.snapshot[player.name] + (pet.fight[1].d or 0) + (pet.fight[1].h or 0)
        end
      end
    end
  end
  if not found then
    return "TinyDPS", false
  end
  return "TinyDPS", true
end

local function loadSkada()
  if not Skada.total or not Skada.total.players then
    return "Skada", false
  end
  -- Skada strips the realm name.
  -- For simplicity's sake, we do not attempt to handle cases where two
  -- players with the same name from different realms are in the same raid.
  local fullPlayerNames = wipe(R.tmp1)
  for name, _ in pairs(A.raid:GetRoster()) do
    fullPlayerNames[A.util:StripRealm(name)] = name
  end
  for _, p in pairs(Skada.total.players) do
    if fullPlayerNames[p.name] then
      R.snapshot[fullPlayerNames[p.name]] = (p.damage or 0) + (p.healing or 0)
    end
  end
  return "Skada", true
end

local function loadRecount()
  if not Recount.db2 or not Recount.db2.combatants or not Recount.db2.combatants[GetUnitName("player")] then
    return "Recount", false
  end
  local c
  for name, _ in pairs(A.raid:GetRoster()) do
    c = Recount.db2.combatants[name]
    if c and c.Fights and c.Fights.OverallData then
      -- Recount stores healing and absorbs separately internally.
      R.snapshot[name] = (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
    else
      R.snapshot[name] = 0
    end
  end
  -- Merge pet data.
  for _, c in pairs(Recount.db2.combatants) do
    if c.type == "Pet" and c.Fights and c.Fights.OverallData then
      if A.raid:GetPlayer(c.Owner) then
        R.snapshot[c.Owner] = R.snapshot[c.Owner] + (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
      end
    end
  end
  return "Recount", true
end

local function loadDetails()
  -- Details! has a different concept of what "overall" means. Trash and even
  -- boss fights, except previous attempts on the current boss, are excluded by
  -- default. So it's entirely possible that there is a current segment but no
  -- overall segment. We check for both: some data is better than no data.
  local found
  for _, segment in ipairs(DETAILS_SEGMENTS) do
    if not found and Details.GetActor and (Details:GetActor(segment, 1) or Details:GetActor(segment, 2)) then
      found = true
      local damage, healing
      for name, _ in pairs(A.raid:GetRoster()) do
        damage = Details:GetActor(segment, 1, name)
        healing = Details:GetActor(segment, 2, name)
        R.snapshot[name] = (damage and damage.total or 0) + (healing and healing.total or 0)
      end
    end
  end
  if not found then
    return "Details", false
  end
  return "Details", true
end

local function calculateAverages()
  local countDamage, totalDamage = 0, 0
  local countHealing, totalHealing = 0, 0
  for name, amount in pairs(R.snapshot) do
    -- Ignore tanks.
    if A.raid:IsDPS(name) then
      countDamage = countDamage + 1
      totalDamage = totalDamage + amount
    elseif A.raid:IsHealer(name) then
      countHealing = countHealing + 1
      totalHealing = totalHealing + amount
    end
  end
  R.snapshot["_averageDamage"] = (countDamage > 0) and (totalDamage / countDamage) or 0
  R.snapshot["_averageHealing"] = (countHealing > 0) and (totalHealing / countHealing) or 0
end

function M:BuildSnapshot()
  wipe(R.snapshot)
  local addon, success
  if tdps then
    addon, success = loadTinyDPS()
  elseif Skada then
    addon, success = loadSkada()
  elseif Recount then
    addon, success = loadRecount()
  elseif Details then
    addon, success = loadDetails()
  else
    A.console:Print(L["meter.print.noAddon"])
    return
  end
  if success then
    A.console:Printf(L["meter.print.usingDataFrom"], A.util:HighlightAddon(A.util:GetAddonNameAndVersion(addon)))
  else
    A.console:Printf(L["meter.print.noDataFrom"], A.util:HighlightAddon(A.util:GetAddonNameAndVersion(addon)))
  end
  calculateAverages()
  if A.debug >= 1 then M:DebugPrintMeterSnapshot() end
end

function M:GetPlayerMeter(name)
  if not R.snapshot[name] then
    R.snapshot[name] = R.snapshot[A.raid:IsHealer(name) and "_averageHealing" or "_averageDamage"] or 0
  end
  return R.snapshot[name]
end

function M:DebugPrintMeterSnapshot()
  A.console:Debug(M, "snapshot:")
  local sorted = A.util:SortedKeys(R.snapshot, R.tmp1)
  for _, k in ipairs(sorted) do
    A.console:DebugMore(M, "  "..k.."="..R.snapshot[k])
  end
end
