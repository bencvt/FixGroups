local A, L = unpack(select(2, ...))
local M = A.sorter:NewModule("SorterMeter")
A.sorter.meter = M

local tmp1 = {}
local format, ipairs, pairs, select, strsplit, tinsert, wipe = string.format, ipairs, pairs, select, strsplit, table.insert, wipe

M.snapshot = {}

local function loadSkada()
  if not Skada.total or not Skada.total.players then
    return "Skada", false
  end
  -- Skada strips the realm name.
  -- For simplicity's sake, we do not attempt to handle cases where two
  -- players with the same name from different realms are in the same raid.
  local playerKeys = wipe(tmp1)
  local name
  for g = 1, 8 do
    for key, _ in pairs(A.sorter.core.groups[g]) do
      name = A.sorter.core:KeyGetName(key)
      name = select(1, strsplit("-", name, 2)) or name
      playerKeys[name] = key
    end
  end
  for _, p in pairs(Skada.total.players) do
    if playerKeys[p.name] then
      M.snapshot[playerKeys[p.name]] = (p.damage or 0) + (p.healing or 0)
    end
  end
  return "Skada", true
end

local function loadRecount()
  if not Recount.db2 or not Recount.db2.combatants or not Recount.db2.combatants[GetUnitName("player")] then
    return "Recount", false
  end
  local playerKeys = wipe(tmp1)
  local name, c
  for g = 1, 8 do
    for key, _ in pairs(A.sorter.core.groups[g]) do
      name = A.sorter.core:KeyGetName(key)
      playerKeys[name] = key
      c = Recount.db2.combatants[name]
      if c and c.Fights and c.Fights.OverallData then
        -- Recount stores healings and absorbs separately internally.
        M.snapshot[key] = (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
      else
        M.snapshot[key] = 0
      end
    end
  end
  -- Merge pet data
  for _, c in pairs(Recount.db2.combatants) do
    if c.type == "Pet" and c.Fights and c.Fights.OverallData and c.Owner and playerKeys[c.Owner] then
      M.snapshot[playerKeys[c.Owner]] = M.snapshot[playerKeys[c.Owner]] + (c.Fights.OverallData.Damage or 0) + (c.Fights.OverallData.Healing or 0) + (c.Fights.OverallData.Absorbs or 0)
    end
  end
  return "Recount", true
end

local function loadDetails()
  -- Details has a different concept of what "overall" means. Trash and even
  -- boss fights, except previous attempts on the current boss, are excluded by
  -- default. So it's entirely possible that there is a current segment but no
  -- overall segment. We check for both: some data is better than no data.
  local found
  local segments = wipe(tmp1)
  tinsert(segments, "overall")
  tinsert(segments, "current")
  for _, segment in ipairs(segments) do
    if not found and Details.GetActor and (Details:GetActor(segment, 1) or Details:GetActor(segment, 2)) then
      found = true
      local name, damage, healing
      for g = 1, 8 do
        for key, _ in pairs(A.sorter.core.groups[g]) do
          name = A.sorter.core:KeyGetName(key)
          damage = Details:GetActor(segment, 1, name)
          healing = Details:GetActor(segment, 2, name)
          M.snapshot[key] = (damage and damage.total or 0) + (healing and healing.total or 0)
        end
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
  for key, amount in pairs(M.snapshot) do
    -- Ignore tanks.
    if A.sorter.core:KeyIsDps(key) then
      countDamage = countDamage + 1
      totalDamage = totalDamage + amount
    elseif A.sorter.core:KeyIsHealer(key) then
      countHealing = countHealing + 1
      totalHealing = totalHealing + amount
    end
  end
  M.snapshot["_averageDamage"] = (countDamage > 0) and (totalDamage / countDamage) or 0
  M.snapshot["_averageHealing"] = (countHealing > 0) and (totalHealing / countHealing) or 0
end

function M:BuildSnapshot()
  wipe(M.snapshot)
  local addon, success
  if Skada then
    addon, success = loadSkada()
  elseif Recount then
    addon, success = loadRecount()
  elseif Details then
    addon, success = loadDetails()
  else
    A.console:Print(L["No supported damage/healing meter addon found."])
    return
  end
  if success then
    A.console:Print(format(L["Using damage/healing data from %s."], A.util:GetAddonNameAndVersion(addon)))
  else
    A.console:Print(format(L["There is currently no data available from %s."], A.util:GetAddonNameAndVersion(addon)))
  end
  calculateAverages()
end