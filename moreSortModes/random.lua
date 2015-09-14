--- Pseudo-random sort.
local A, P, L = unpack(select(2, ...))
local M = P:NewModule("random", "AceEvent-3.0")

local random, sort, strbyte, strlen, wipe = random, sort, strbyte, strlen, wipe
local fmod = math.fmod

local salt = ""
local hashCache = {}

local function hash(text)
  local v = hashCache[text]
  if v then
    return v
  end
  -- Credit to Mikk for the original hashing function this code is adapted from:
  -- http://wow.gamepedia.com/StringHash
  local src = salt..text
  local len = strlen(src)
  v = 1
  for i = 1, len, 3 do 
    v = fmod(v*8161, 4294967279) +  -- 2^32 - 17: Prime!
      (strbyte(src,i)*16776193) +
      ((strbyte(src,i+1) or (len-i+256))*8372226) +
      ((strbyte(src,i+2) or (len-i+256))*3932164)
  end
  v = fmod(v, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
  hashCache[text] = v
  return v
end

function M:OnEnable()
  A.plugins:RegisterSortMode({
    key = "random",
    name = L["plugin.moreSortModes.random"],
    desc = {L["plugin.moreSortModes.note.notUseful"]},
    onBeforeStart = function()
      salt = random()
      wipe(hashCache)
    end,
    onSort = function(keys, players)
      sort(keys, function(a, b)
        return hash(a) < hash(b)
      end)
    end,
  })
end
