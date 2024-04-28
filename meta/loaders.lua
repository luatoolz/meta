require "compat53"

local loaders = {}
return setmetatable(loaders, {
  __call = function(self, m, o)
    assert(type(m)=='string' and #m>0, "type(m) should be string, got " .. type(m))
    assert(type(o)=='table', "type(o) should be table, got " .. type(o))
      rawset(self, m, o)
      rawset(self, o, m)
    return o
  end,
})
