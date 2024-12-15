local pkg = ...
local pcall, cache, is, mt, iter, _ = require "meta.pcall", require "meta.cache", require("meta.is"), require "meta.mt", table.iter
local wrapper = {}
--local root = require "meta.cache.root"

--  self[true]: source (loader/module), string or table
--  self[false]: handler, callable
return mt(wrapper, {
  __call = function(self, m, handler)
    if type(m) == 'nil' then return nil, '%s: await module/loader (string/table), got: nil' % pkg end
    if type(m)~='string' and type(m)~='table' then return nil, '%s: await module/loader name (string) without loaded module, got: %s' % {pkg, type(m)} end
    if not is.callable(handler) then return nil, '%s: require callable handler, got: %s' % {pkg, type(handler)} end
    return setmetatable({[true]=m,[false]=handler,[0]=0}, getmetatable(self))
  end,
  __concat = function(self, it)
    if type(it)=='boolean' or type(it)=='table' then
      if is.loader(self[true]) then
        if type(it)=='boolean' then
          local _ = self[true] .. it
        end
        local keys = type(it)=='table' and it or {}
        for k in iter(keys) do
          local _ = self[k]
        end
      else
        if type(self[true])=='string' then
          if type(it)=='table' then
            for k in iter(it) do _ = self[k] end
          elseif type(it)=='boolean' then
            local l = pcall(require, 'meta.loader')
            if l then
              local ldd = assert(l(self[true]), 'wrapper: loader is nil')
              self[true] = ldd .. true
              for k in iter(self[true]) do _ = self[k] end
            end
          end
        end
      end
    end
    return self
  end,
  __iter = function(self) return iter(self) end,
  __index = function(self, key)
    if type(key)=='number' then return rawget(self, key) end
    if type(key)=='nil' then return end
    assert(is.like(self, wrapper), '%s: self should be wrapper object, got: %s %s' % {pkg, type(self), getmetatable(self).__name})
    assert(type(key) == 'string' and #key>0, '%s: await key as string, got: %s' % {pkg, type(key)})

    local handler=self[false]
    if not is.callable(handler) then return assert(nil, '%s: handler uncallable' % pkg) end

    local src, rv = self[true]
    if is.loader(src) then
      rv=src[key]
    elseif type(src)=='string' then
--      rv=root(src, key)
      rv=pcall(require, src .. '.' .. key)
    end
    rv=rv and handler(rv)
    if type(rv)~='nil' then self[0]=self[0]+1 end
    return table.save(self, key, rv)
  end,
  __mod = table.filter,
  __mul = table.map,
  __name = 'wrapper',
  __pairs = function(self) --if self[0]==0 then local _ = self .. true end;
    return table.nextstring, self, nil end,
  __pow = function(self, to) if is.callable(to) then self[false]=to end; return self end,
  __tostring = function(self) return cache.type[self] end,
})