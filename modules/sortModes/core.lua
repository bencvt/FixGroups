--- Bench (i.e., move to group 8) all guild members below a certain rank.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("core", "AceEvent-3.0")
P.core = M
local R = {
  core = {},
  nonCore = {},
}
M.private = R

local PADDING_PLAYER = {isDummy=true}

local format, gsub, ipairs, min, select, sort, strfind, strlower, tinsert, wipe = format, gsub, ipairs, min, select, sort, strfind, strlower, tinsert, wipe
local GuildControlGetNumRanks, GuildControlGetRankName, GetGuildInfo, GetRealmName, UnitIsInMyGuild = GuildControlGetNumRanks, GuildControlGetRankName, GetGuildInfo, GetRealmName, UnitIsInMyGuild

local function getGuildFullName()
  local guildName, _, _, realm = GetGuildInfo("player")
  if not guildName then
    return
  end
  return format("%s-%s", guildName, gsub(realm or GetRealmName(), "[ %-]", ""))
end

function M:GetCoreRank()
  return A.options.coreRaiderRank[getGuildFullName()]
end

function M:SetCoreRank(rank)
  A.options.coreRaiderRank[getGuildFullName()] = rank
end

function M:GetGuildRanks()
  if not A.db.global.guildRanks then
    A.db.global.guildRanks = {}
  end
  local guildName = getGuildFullName()
  if not guildName then
    return
  end
  if not A.db.global.guildRanks[guildName] then
    A.db.global.guildRanks[guildName] = {}
  end
  return A.db.global.guildRanks[guildName]
end

function M:UpdateGuildRanks()
  local ranks = M:GetGuildRanks()
  if not ranks then
    return
  end
  wipe(ranks)
  for i = 1, GuildControlGetNumRanks() do
    tinsert(ranks, GuildControlGetRankName(i))
  end
  local rank = M:GetCoreRank()
  if not rank or rank < 1 or rank > #ranks then
    -- Guess which rank is for core raiders.
    rank = nil
    local name
    -- First pass: first rank containing "core".
    for i = #ranks, 1, -1 do
      name = strlower(ranks[i])
      if not rank and strfind(name, "core") then
        rank = i
      end
    end
    if not rank then
      -- Second pass: last rank containing "raid" but not a keyword indicating
      -- the player is a fresh recruit or a non-raider.
      for i = 1, #ranks do
        name = strlower(ranks[i])
        if not rank and strfind(name, "raid") and not strfind(name, "no[nt]") and not strfind(name, "trial") and not strfind(name, "new") and not strfind(name, "recruit") and not strfind(name, "backup") and not strfind(name, "ex") and not strfind(name, "retire") and not strfind(name, "former") and not strfind(name, "casual") and not strfind(name, "alt") then
          rank = i
        end
      end
    end
    if not rank then
      -- Otherwise just guess 4, on the theory that many guilds' ranks are
      -- similar to:
      -- GM > Officer > Veteran > Core > Recruit > Alt > Casual > Muted.
      rank = min(#ranks, 4)
    end
    M:SetCoreRank(rank)
  end
end

function M:OnEnable()
  A.sortModes:Register({
    key = "core",
    name = L["sorter.mode.core"],
    desc = function(t)
      t:AddLine(format("%s: |n%s.", L["tooltip.right.fixGroups"], L["sorter.mode.core"]), 1,1,0)
      t:AddLine(" ")
      local guildName = GetGuildInfo("player")
      if guildName then
        M:UpdateGuildRanks()
        local rank = M:GetCoreRank()
        t:AddLine(format(L["gui.fixGroups.help.note.core.1"], A.util:HighlightGuild(guildName), A.util:HighlightGuild(M:GetGuildRanks()[rank]), rank), 1,1,1, true)
        t:AddLine(" ")
        t:AddLine(L["gui.fixGroups.help.note.core.2"], 1,1,1, true)
      else
        t:AddLine(format(L["sorter.print.notInGuild"], "core"), 1,1,1, true)
      end
    end,
    isIncludingSitting = true,
    onBeforeStart = M.verifyInGuild,
    onStart = M.UpdateGuildRanks,
    onBeforeSort = M.verifyInGuild,
    onSort = M.onSort,
  })
end

function M.verifyInGuild()
  if not GetGuildInfo("player") then
    A.console:Printf(L["sorter.print.notInGuild"], "core")
    return true
  end
end

function M.onSort(keys, players)
  -- Perform an initial sort.
  sort(keys, P:BaseGetCompareFunc(players))

  -- Split keys into core/nonCore.
  local maxRank = M:GetCoreRank()
  local core, nonCore = wipe(R.core), wipe(R.nonCore)
  local unitID
  for _, k in ipairs(keys) do
    unitID = players[k].unitID
    if unitID and UnitIsInMyGuild(unitID) and select(3, GetGuildInfo(unitID)) > maxRank then
      tinsert(nonCore, k)
    else
      -- Note that non-guildmates will be considered core.
      -- This is a good thing: if you have to PUG to fill in a key role,
      -- you definitely want them in the raid.
      tinsert(core, k)
    end
  end

  -- Recombine into keys, inserting padding to force nonCore to group 8.
  wipe(keys)
  for _, k in ipairs(core) do
    tinsert(keys, k)
  end
  local k
  for i = 1, (40 - #core - #nonCore) do
    k = format("_pad%02d", i)
    tinsert(keys, k)
    players[k] = PADDING_PLAYER
  end
  for _, k in ipairs(nonCore) do
    tinsert(keys, k)
  end
end
