local P = FixGroups
local L = P.L
local A = ...
P[A] = LibStub("AceAddon-3.0"):NewAddon(A)
A = P[A]

function A:OnEnable()
  A.test = true
end
