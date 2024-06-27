require "compat53"
local no = require "meta.no"
local loader = require "meta.loader"
local mt = require "meta.mt"
local cache = require "meta.cache"

--    for x in tables:keys() do if type(self.mm[x])=='table' then setmetatable(self.mm[x], nil) end end
--    setmetatable(self.mm, nil)
--    self.mm.__index=no.object

local tables = table{'__computed', '__computable', '__import', '__new', '__fields', '__static'}:tohash()

--[[
---------------------------------------------------------
  usage (1):

  return meta.object({...})
        :imports({...})
        :computed(...)
        :loader({...})
        :instance({})

  usage (2):
  local o = meta.object()
  o.__import = {...}
  o.__computed = {...}

  o.__computable.id=function(...) return ... end
  o.__computable.id = t.db.mongo.oid
--------------------------------------------------------]]

return mt({}, {
  imports     = function(self, t) self.__import=t; return self end,     -- var types spec
  mt          = function(self, t) self.mm:update(t); return self end,   -- static (mt) vars/func/methods    set static
  computed    = function(self, t) self.__computed=t; return self end,   -- computed vars (saved)
  computable  = function(self, t) self.__computable=t; return self end, -- computable vars (unsaved)
  loader      = function(self, ...) cache.loader(loader(...), self.tt); return self end,                    -- define auto loader
  instance    = function(self, t) return mt(self.tt:update(t), self.mm:update({__index=no.object})) end,    -- update instance table & return setmetatabled

  __index=function(self, key)
    assert(type(self)=='table')
    assert(type(key)~='nil')

    if tables[key] then
      self.mm[key]=table()
      return self.mm[key]
    end
    return mt(self)[key] or self.mm[key]
    end,
  __newindex = function(self, key, v)
    assert(type(self)=='table')
    if type(key)=='nil' or type(v)=='nil' then return end
    if type(v)=='table' then
      v=table(v)
      if type(self.mm[key])~='table' then self.mm[key]=table(v) else
        self.mm[key]=table(self.mm[key])
        self.mm[key]:update(v)
      end
    else
      self.mm[key]=table(v)
    end
  end,
  __call = function(self, newmeta)
    assert(type(self) == 'table', 'await table, got ' .. type(self))
    assert(type(getmetatable(self)) == 'table', 'await mt(table), got ' .. type(getmetatable(self)))
    return setmetatable({tt=table({}), mm=table(newmeta or {})}, getmetatable(self)) -- self.tt={}, self.mm={}
  end,
})
