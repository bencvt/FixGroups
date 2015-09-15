--- Sort by overall damage/healing done.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("meter", "AceEvent-3.0")
P.meter = M

local format, sort = format, sort

function M:OnEnable()
  A.sortModes:Register({
    key = "meter",
    order = 2100,
    name = L["sorter.mode.meter"],
    desc = function(t)
      t:AddLine(format("%s: |n%s.", L["options.widget.sortMode.text"], L["sorter.mode.meter"]), 1,1,0)
      t:AddLine(" ")
      t:AddLine(L["gui.fixGroups.help.note.meter.1"], A.meter:GetSupportedAddonList(), 1,1,1, true)
      t:AddLine(" ")
      t:AddLine(A.meter:TestInterop(), 1,1,1, true)
      t:AddLine(" ")
      t:AddLine(L["gui.fixGroups.help.note.meter.2"], 1,1,1, true)
    end,
    onStart = function()
      A.meter:BuildSnapshot(true)
    end,
    onSort = M.onSort,
  })
end

local TANK, HEALER = A.group.ROLE.TANK, A.group.ROLE.HEALER

function M.onSort(keys, players)
  local pa, pb
  sort(keys, function(a, b)
    pa, pb = players[a], players[b]
    if pa.role ~= pb.role then
      if pa.role == HEALER or pb.role == HEALER or pa.role == TANK or pb.role == TANK then
        -- Tanks and healers are in their own brackets.
        return a < b
      end
    end
    pa, pb = A.meter:GetPlayerMeter(pa.name), A.meter:GetPlayerMeter(pb.name)
    if pa == pb then
      -- Tie, or no data. Fall back to default sort.
      return a < b
    end
    return pa > pb
  end)
end
