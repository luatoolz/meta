require "compat53"
local meta = require "meta"
local mt = meta.mt
local cache = meta.cache
local is = meta.is

local args, iter, of = table.args, table.iter, table.of

return mt({},{
  __item=tostring,
  __pow=table.of, -- set ^ t.net.link
  __call=function(self, ...)
    assert(is.callable(mt(self).__item))
    return setmetatable({}, getmetatable(self)) .. args(...)
  end,
  __concat=function(self, t)
    assert(is.table.callable(self) and is.table.indexable(self))
    if is.table(t) then for it in iter(t) do _ = self + it end end
    return self
  end,
  __add=function(self, it)
    assert(is.table.callable(self) and is.table.indexable(self))
    if it then self[it]=it end
    return self
  end,
  __sub=function(self, it)
    assert(is.table.callable(self) and is.table.indexable(self))
    it=mt(self).__item(it)
    if it then self[it]=nil end
    return self
  end,
  __index=function(self, it)
    assert(is.table.callable(self) and is.table.indexable(self))
    it=mt(self).__item(it)
    return it and rawget(self, it) or nil
  end,
  __newindex=function(self, it, v)
    assert(is.table.callable(self) and is.table.indexable(self))
    it=mt(self).__item(it)
    if it and not self[it] then rawset(self, it, it) end
  end,
  __le=function(a, b)
    assert(is.similar(a, b), 'require similar objects')
    for it in iter(a) do if not b[it] then return false end end
    return true
  end,
  __lt=function(a, b)
    assert(is.similar(a, b), 'require similar objects')
    return a <= b and not (b <= a)
  end,
  __eq=function(a, b)
    assert(is.similar(a, b), 'require similar objects')
    return a <= b and b <= a
  end,
})
