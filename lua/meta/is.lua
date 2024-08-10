require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"

local cache=require "meta.cache"
local metas=cache.ordered.roots + 'meta'
local toindex=cache.toindex .. {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
local module=cache.module
local is

local join = string.sep:joiner()
local function ending(s) if type(s) == 'string' then return (s:match('[^/]+$') or '') end end

local function loadmodule(path)
  if not cache.normalize.module then require "meta.module" end
  local mod = module[path]
  if mod and mod.exists then return mod.load end
end

is = setmetatable({
  mt = {
    __iter      =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__iter )=='function' end,
    __pairs     =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__pairs )=='function' end,
    __ipairs    =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__ipairs )=='function' end,
    __call      =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__call )=='function' end,
    __index     =function(o) return type(o)=='table' and (type((getmetatable(o) or {}).__index)=='function' or type((getmetatable(o) or {}).__index)=='table') end,
    __tostring  =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__tostring )=='function' end,
    __tonumber  =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__tonumber )=='function' end,
    __toboolean =function(o) return type(o)=='table' and type((getmetatable(o) or {}).__toboolean )=='function' end,
  },
  callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end,
  cache = function(o) return type(o)=='table' and (getmetatable(o)==getmetatable(cache.any)) end,
  loader = function(o)
    if not cache.normalize.loader then require "meta.loader" end
    return type(o)=='table' and (getmetatable(o)==getmetatable(cache.new.loader))
  end,
  loaded = function(o)
    if not cache.normalize.loader then require "meta.loader" end
    return (type(o)=='string' and is.loader(package.loaded[o])) or false
  end,
  module = function(o)
    if not cache.normalize.module then require "meta.module" end
    return type(o) == 'table' and (getmetatable(o) == getmetatable(cache.new.module))
  end,
  module_name = function(o) return type(o)=='string' and o:match('^[%w_%.%-%/]+$') and not o:match('%.%.') end,
}, {
  __tostring = function(self) return rawget(self, 'path') or '' end,
  __call = function(self, ...)
    local o = select(1, ...)
    local p = rawget(self, 'path')
    if not p or p == '' then return self ^ o end
    assert(p, 'meta.is object path required, got ' .. type(p))

    local path = p
    local k = ending(path)
--    local isroot = path == k
    assert(cache.normalize.module, 'meta.module required')

    -- 1st level name -> try load meta/is/xxx
      for _,parent in pairs(metas) do
        if is.loaded(parent) then
          local rv = loadmodule(join(parent, 'is', path))
          if is.callable(rv) then return rv(...) end
        end
      end

    -- cache('typename', sub)
    -- cache('mt', sub)
    -- cache('instance', sub)
    if toindex[type(o)] then
      local tt = cache.type[o]
      if metas then
        for _,parent in pairs(metas) do
          if is.loaded(parent) then
            if tt == cache.sub(join(parent, path)) then return true end
          end
        end
        if type(o) == 'table' and getmetatable(o) then
          tt = cache.type(getmetatable(o))
          for _,parent in pairs(metas) do
            if is.loaded(parent) then
              if tt == cache.sub(join(parent, path)) then return true end
            end
          end
        end
      end
    end

    -- is.net.ip(t)
    for _,parent in pairs(metas) do
      if is.loaded(parent) then
        local rv = loadmodule(join(parent, path))
        if rv and type(rv)==type(o) then return is.similar(rv, ...) end
      end
    end

    -- is.table.callable(t)
    path = path:gsub('[^/]*$', '', 1):gsub('%/?$', '', 1)
    if path == '' then path = nil end

    for _,parent in pairs(metas) do
      if is.loaded(parent) then
      p = join(parent, path)
      if p then
        sub = module[p]
        if sub and sub.exists then
          sub = sub.load
          if type(sub) == 'table' and (rawget(sub, k) or sub[k]) then
            sub = rawget(sub, k) or sub[k]
            if type(sub) == 'function' then return sub(...) end
            if type(sub) == 'table' then
              return type(o) == type(sub) and (o == sub or (type(o) == 'table' and getmetatable(o) and getmetatable(o) == getmetatable(sub)))
            end
          end
        end
      end
      end
    end
    return false
  end,
  __index = function(self, k)
    local path = rawget(self, 'path')
		if not path then
			assert(metas)
      for _,parent in pairs(metas) do
        if is.loaded(parent) then
          local rv = loadmodule(join(parent, 'is', k))
          if is.callable(rv) then return rv end
        end
      end
		end
    return setmetatable({path = path and join(path, k) or k}, getmetatable(self))
  end,
  __pow = function(self, k) _ = metas + k; return self end,
})

return is
