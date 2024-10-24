local is, mt, array, export, args, iter, noop = require "meta.is", require "meta.mt",
  require "meta.array", require "meta.exporter", table.args, table.iter, require "meta.fn.noop"

return setmetatable({},{
  of=table.of,
  __array=true,
  __preserve=true,
  __add=function(self, it)
    assert(is.ofset(self))
    if not it then return self end
    if is.bulk(it) then return self .. it end
    if it and not self[it] then self[it]=it end
    return self
  end,
  __call=function(self, ...)
    assert(is.ofset(self))
    assert(is.callable(mt(self).__item) or mt(self).__item==nil)
    return setmetatable({}, getmetatable(self)) .. args(...)
  end,
  __concat=function(self, o)
    assert(is.ofset(self))
    if is.bulk(o) then for it in iter(o) do _ = self + it end end
    return self
  end,
  __eq=function(a, b)
    if (not is.ofset(a)) or (not is.ofset(b)) then return nil end
    assert(is.similar(a, b), 'require similar objects, but got: ' .. type(b))
    return a <= b and b <= a
  end,
  __index=function(self, it)
    if type(it)=='nil' then return nil end
    assert(is.ofset(self))
    local item=mt(self).__item or noop
    local rv
    if type(it)=='string' then rv=mt(self)[it] end
    return rv or rawget(self, it) or rawget(self, item(it))
  end,
  __iter=function(self)
    local k
    return function(...)
      k,_ = next(self, k)
      if k~=nil then
        return k
      end
    end
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
  __mod=table.filter,
  __mode='v',
  __mul=table.map,
  __name='set',
  __newindex=function(self, it, v)
    assert(is.ofset(self))
    if it and is.callable(mt(self).__item) then it=mt(self).__item(it) end
    if it and v and not self[it] then rawset(self, it, it) end
  end,
  __sub=function(self, it)
    assert(is.ofset(self))
    if is.bulk(it) then for o in iter(it) do _=self-o end; return self end
    if it and is.callable(mt(self).__item) then it=mt(self).__item(it) end
    if it and self[it] then rawset(self, it, nil) end
    return self
  end,
  __export=function(self, fix) local rv=array(self); table.sort(rv); return export(rv, fix) end,
  __tostring=function(self) return table.concat(array(self)*tostring, "\n") end,
})
