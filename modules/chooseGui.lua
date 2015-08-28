local A, L = unpack(select(2, ...))
local M = A:NewModule("chooseGui")
A.chooseGui = M
M.private = {
--TODO
}
local R = M.private

function M:Open()
  A.console:Debugf(M, "open")
end
