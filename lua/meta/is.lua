require "compat53"
local cache = require "meta.cache"
local module = cache.module

local is

local indextypes = {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
local metas = {}

local function join(...)
  local t = {}
  for k, v in ipairs({...}) do if v then table.insert(t, v) end end
  return table.concat(t, '/')
end

local function ending(s) if type(s) == 'string' then return (s:match('[^/]+$') or '') end end
local function loadmodule(path)
  local mod = module[path]
  if mod.exists then return mod.load end
end

is = setmetatable({
  callable = function(o) return type(o) == 'function' or (type(o) == 'table' and type((getmetatable(o) or {}).__call) == 'function') end,
  cache = function(o) return type(o) == 'table' and (getmetatable(o) == getmetatable(cache.any)) end,
  loader = function(o)
    if not cache.normalize.loader then require "meta.loader" end
    return type(o) == 'table' and (getmetatable(o) == getmetatable(cache.new.loader))
  end,
  module = function(o)
    if not cache.normalize.module then require "meta.module" end
    return type(o) == 'table' and (getmetatable(o) == getmetatable(cache.new.module))
  end,
  iterable = function(x) return type(x) == 'table' or type((getmetatable(x or {}) or {}).__pairs) == 'function' end,
}, {
  __tostring = function(self) return rawget(self, 'path') or '' end,
  __call = function(self, ...)
    local o = select(1, ...)
    local p = rawget(self, 'path')
    if not p or p == '' then return self ^ o end
    assert(p, 'meta.is object path required, got ' .. type(p))

    local path = p
    local k = ending(path)
    local isroot = path == k
    local rv

    assert(cache.normalize.module, 'meta.module required')

    -- 1st level name -> try load meta/is/xxx
    if isroot then
      for i, parent in ipairs(metas) do
        rv = loadmodule(join(parent, 'is', k))
        if is.callable(rv) then return rv(...) end
      end
    end

    -- cache('typename', sub)
    -- cache('mt', sub)
    -- cache('instance', sub)
    if indextypes[type(o)] then
      local tt = cache.typename[o]
      for i, parent in ipairs(metas) do if tt == cache.sub(join(parent, path)) then return true end end
      if type(o) == 'table' and getmetatable(o) then
        tt = cache.typename(getmetatable(o))
        for i, parent in ipairs(metas) do if tt == cache.sub(join(parent, path)) then return true end end
      end
    end

    -- is.net.ip(t)
    for i, parent in ipairs(metas) do
      rv = loadmodule(join(parent, path))
      if rv and type(rv) == type(o) then return is.similar(rv, ...) end
    end

    -- is.table.callable(t)
    path = path:gsub('[^/]*$', '', 1):gsub('%/?$', '', 1)
    if path == '' then path = nil end

    for i, parent in ipairs(metas) do
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
    return false
  end,
  __index = function(self, k)
    local path = rawget(self, 'path')
    return setmetatable({path = path and join(path, k) or k}, getmetatable(self))
  end,
  __pow = function(self, k)
    if type(k) == 'string' and #k > 0 then
      -- keep 3 records for each searchable module name: ordered + mapped
      rawset(self, 'root', k)
      if not metas[k] then
        table.insert(metas, k)
        metas[k] = true
      end
    end
    return self
  end,
})

return is('meta')
