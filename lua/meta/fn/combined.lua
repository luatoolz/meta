require 'compat53'
local t = require "meta"
local is = t.is
local unpak = unpack or table.unpack
local pak = pack or table.pack
return function(...)
  local func={...}
  return function(...)
    local rv=pak(...)
    for i,f in ipairs(func) do
      assert(is.callable(f))
      rv=pak(f(unpak(rv)))
    end
    return unpak(rv)
  end
end
