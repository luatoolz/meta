require "compat53"
local pkg = (...) or 'meta.wrapper'
local meta = require "meta"
local cache, is, mt, iter = meta.cache, meta.is, meta.mt, table.iter

--  self[true]: source loader
--  self[false]:
--      name    - wrapper name
--      handler - function handler
return mt({}, {
  __call = function(self, m, handler, name, needkey)
    if type(m) == 'nil' then return nil, '%s: await module/loader (string/table), got: nil' % pkg end
    local src = cache.loader(m)
    if type(src) == 'nil' then return nil, '%s: loader not found: %s' % {pkg, m} end
    return setmetatable({[true]=src,[false]={name=name,handler=handler,len=0,needkey=needkey}}, getmetatable(self))
  end,
  __concat = function(self, it)
    if type(it)=='boolean' or type(it)=='table' then
      local keys = type(it)=='table' and it or (self[true] .. it)
      for k in iter(keys) do
        local _ = self[k]
      end
    end
    return self
  end,
  __iter = function(self) return iter(self[true]) end,
  __index = function(self, key)
    if type(key)=='nil' then return end
    assert(is.wrapper(self), '%s: self should be wrapper object, got: %s' % {pkg, type(self)})
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', '%s: await key as string or nil, got: %s' % {pkg, type(key)})

    local handler=self[false].handler
    if not is.callable(handler) then return nil, '%s: handler undefined' % pkg end

    local arg2
    if self[false].needkey then arg2=key end
    local rv=handler(self[true][key], arg2)
    if type(rv)~='nil' then self[false].len=self[false].len+1 end
    return table.save(self, key, rv)
  end,
  __mod = function(self, to) if is.callable(to) then return table.filter(self, to) end; return self end,
  __mul = function(self, to) if is.callable(to) then return table.map   (self, to) end; return self end,
  __name = pkg,
  __pairs = function(self) if self[false].len==0 then local _ = self .. true end;
    return table.nextstring, self, nil end,
  __pow = function(self, to) if is.callable(to) then self[false].handler=to end; return self end,
  __tostring = function(self) return self[false].name or cache.type[self] or '' end,
})