require 'compat53'
local call = require "meta.call"

local function goodargs(x, ...)
  if x then return table.pack(x, ...) end end

-- specific type checks handled in every caller
return function(self, key)
  if type(self)=='table' and getmetatable(self) then
  local g = getmetatable(self)
  local rv
  for _,f in ipairs(rawget(g, '__indexer') or g) do
    rv = goodargs(call(f, self, key))
    if rv then return table.unpack(rv) end
  end
  end end