--- Tanks > Healers > Melee > Ranged.
local A, L = unpack(select(2, ...))
local P = A.sortModes
local M = P:NewModule("default", "AceEvent-3.0")
P.default = M

local format = format

function M:OnEnable()
  A.sortModes:Register({
    key = "sort",
    aliases = {"default"},
    order = 1000,
    name = L["sorter.mode.default"],
    desc = function(t)
      t:AddLine(L["gui.fixGroups.help.sort"], 1,1,0, true)
      t:AddLine(" ")
      t:AddLine(format(L["gui.fixGroups.help.note.sameAsLeftClicking"], A.util:Highlight(L["button.fixGroups.text"])), 1,1,1, true)
      t:AddLine(" ")
      t:AddLine(format(L["gui.fixGroups.help.note.defaultMode"], A.util:Highlight(A.sortModes:GetDefault().name)), 1,1,1, true)
    end,
  })
end
