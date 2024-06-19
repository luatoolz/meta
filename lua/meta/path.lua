require "compat53"

local cache = require "meta.cache"
local no = require "meta.no"
local module = cache.module
local mt = require "meta.mt"

local path = {}
local object = {}

-- TODO add other meta methods
return setmetatable({}, {
  __tostring = function(self)       local o=object[self]; assert(o); return tostring(o) end,
  __newindex = function(self, k, v) local o=object[self]; assert(o); if type(o)=='table' then if mt(o).__newindex then mt(o).__newindex(o, k, v) else o[k]=v end end end,
  __eq = function(self, to)         local o=object[self]; assert(o); if type(o)=='table' then return mt(o).__eq and mt(o).__eq(o, to) or o==to end; return o==to end,
  __index = function(self, k)
    if k==0 then return object[self] end
    local spath = path[self]
    assert(spath)
    if not spath then return nil end
    local mod = module[spath]
    assert(mod)
    if mod.loader then
      local o = mod.loader[k]
      if o then
        local rv = setmetatable({}, getmetatable(self))
        path[rv]=no.join(spath, k)
        object[rv]=o
-- save objectpath permanently
        rawset(self, k, rv)
        return rv
      end
    end
    local o = object[self]
    if type(o)=='table' then
-- but do not save actual object data
--      rawset(self, k, o[k])
      return o[k]
    end
    return nil
  end,
  __call = function(self, ...)
    local o=object[self]
    if not o then
      local rv = setmetatable({}, getmetatable(self))
      path[rv]=no.join(...)
      return rv
    end
    if type(o)=='function' or (type(o)=='table' and mt(o).__call) then return o(...) end
  end,
})
