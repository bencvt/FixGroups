--- Split raid into two sides based on overall damage/healing done.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("split", "AceEvent-3.0")
P.split = M

function M:OnEnable()
  A.sortModes:Register({
    key = "split",
    isSplit = true,
    order = 1000,
    name = L["sorter.mode.split"],
    desc = function(t)
      t:AddLine(L["gui.fixGroups.help.split"], 1,1,0)
      t:AddLine(" ")
      t:AddLine(L["gui.fixGroups.help.note.meter.1"], A.meter:GetSupportedAddonList(), 1,1,1, true)
      t:AddLine(" ")
      t:AddLine(A.meter:TestInterop(), 1,1,1, true)
    end,
    onStart = function()
      A.meter:BuildSnapshot(false)
    end,
    onSort = P.meter.onSort,
  })
end
