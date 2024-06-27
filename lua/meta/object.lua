require "compat53"
local inspect = require "inspect"
local no = require "meta.no"
local loader = require "meta.loader"
local mt = require "meta.mt"
local cache = require "meta.cache"
local is = require "meta.is"

local tables = table{'__computed', '__computable', '__imports'}:tohash()

--[[
---------------------------------------------------------
  usage (1): call methods

  return meta.object({...})
        :imports({...})
        :computed(...)
        :loader({...})
        :instance({})

  usage (2): assign to mt vars
  local o = meta.object()
  o.__imports = {...}
  o.__computed = {...}

  o.__computable.id=function(...) return ... end
  o.__computable.id = t.db.mongo.oid

  MANDATORY: --> call o:instance()
--------------------------------------------------------]]

return mt({}, {
  mt          = function(self, t) self.mm:update(t);  return self end,  -- static (mt) vars/func/methods
  imports     = function(self, t) self.__imports=t;   return self end,  -- imports spec (typed object vars)
  computed    = function(self, t) self.__computed=t;  return self end,  -- computed vars (saved)
  computable  = function(self, t) self.__computable=t;return self end,  -- computable vars (unsaved)
  loader      = function(self, mpath, topreload, torecursive)           -- define auto loader
    local it=mpath
    if it then it=loader(it, topreload, torecursive) end
    if it then cache.loader[self.tt]=it end
    return self
  end,
  instance    = function(self, t)   -- update instance table & return setmetatabled
    return mt(self.tt:mtremove(t), self.mm:mtremove({
      __index=no.object,
      __newindex=function(self, key, value)
        local f = (mt(self).__imports or {})[key]
        if is.callable(f) then
          no.save(self, key, no.call(f, value)) else
          no.save(self, key, value)
        end
      end,
    })) end,
  __index=function(self, key)
    assert(type(self)=='table')
    assert(type(key)~='nil')
    if type(next(self))=='nil' then return nil end
 
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
      self.mm[key]=v
    end
  end,
  __call = function(self, newmeta)
    assert(type(self) == 'table', 'await table, got ' .. type(self))
    assert(type(getmetatable(self)) == 'table', 'await mt(table), got ' .. type(getmetatable(self)))
    return setmetatable({tt=table({}), mm=table(newmeta or {})}, getmetatable(self))
  end,
})
