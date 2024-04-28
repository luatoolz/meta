require "compat53"

local c = {
  m = '%',
  sep = _G.package.config:sub(1,1),
  dot = '.',
}
c.msep = c.m .. c.sep
c.mdot = c.m .. c.dot
return c
