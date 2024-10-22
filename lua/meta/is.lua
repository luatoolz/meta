require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"

local pkg = ...
local join    = string.dot:joiner()
local function save(self,k,v)
  if type(self)=='nil' or type(k)=='nil' or type(v)=='nil' then return nil end
  assert(type(self)=='table', 'table.save: await table, got %s' % type(self))
  rawset(self, k, v)
  return v end

local cache   = require "meta.cache"
local root    = require "meta.cache.root"
local is

local typecall = function(t)
  return setmetatable(t, {
    __index=function(self, it) return rawget(self, type(it)) end,
    __call=function(self, it) local f=self[it]; if type(f)=='function' then return f(it) and true or nil end; return f end,
})
end

local atom = typecall({["number"]=true,["boolean"]=true,["string"]=true,["nil"]=true,})
local functions = typecall({["function"]=true,["CFunction"]=true,})
local virtual = typecall({["function"]=true,["thread"]=true,["CFunction"]=true,})
local complex = typecall({["userdata"]=true,["table"]=true,})

local mt = setmetatable({
  __index=function(o) return is.complex(o) and getmetatable(o) and (type((getmetatable(o) or {}).__index)=='function' or type((getmetatable(o) or {}).__index)=='table') end,
},{
  __call=function(self, o) return is.complex(o) and type(getmetatable(o))=='table' end,
  __index=function(self, k) return string.null(k) and save(self, k, self/k) end,
  __div=function(self, k) return string.null(k) and function(o) return is.complex(o) and is.func((getmetatable(o) or {})[k]) end end,
--  __pairs=function(self) return next, self end,
})
-- number string table boolean
is = setmetatable({
  mt = mt,
  atom = atom,
  ['nil'] = atom,
  null = atom,
  string = atom,
  boolean = atom,
  number = atom,
  func = functions,
  functions = functions,
  ['function'] = functions,
  virtual = virtual,
  CFunction = virtual,
  thread = virtual,
  complex = complex,
  userdata = complex,
  empty = typecall({
    ['nil']=true,
--    boolean=function(x) return x==false or nil end,
    number=function(x) return x==0 or nil end,
    string=function(x) return ((x=='' or x=='0') or x:match("^%s+$")) and true or nil end,
    table=function(x) return type(next(x))=='nil' or nil end,
  }),

  callable = typecall({["function"]=true,["CFunction"]=true,["table"]=mt.__call,["userdata"]=mt.__call,}),
  toindex = typecall({['function']=true,['table']=true,['userdata']=true,['CFunction']=true}),
  indexable = mt.__index,
  iterable  = function(o)
    if type(o)=='table' and ((not getmetatable(o)) or rawequal(getmetatable(o),getmetatable(table()))) then return true end
    if is.complex(o) then local g = getmetatable(o)
    return g and (g.__pairs or g.__ipairs or g.__iter) and true or nil end end,
  loaded = function(o) return cache.loaded[o] and true end,
  truthy = function(...) return true end,
  falsy  = function(...) return nil end,
  noop   = function() end,
  match = setmetatable({}, {__index = function(self, it) return table.save(self, it, string.matcher(root('matcher', it)[1], true)) end,}),
},{
  __tostring = function(self) if self==is then return pkg end; return self.__path end,
  __call = function(self, ...)
    local len, path, non, rv, k = select('#', ...), self.__path, self.__non, self.__rv, self.__id

    if rv and is.callable(rv) then
      if type(rv)=='function' then return rv(...) end
      rv=rv(...)
      if non then return (not (rv and true or false)) and true or nil end
      return rv and true or nil end

    if rv then assert(false, 'meta.is.__rv: await callable, got %s' % type(rv)) end
    assert(type(path)=='string', 'meta.is.__path: await object path, got %s' % type(path))
    local o = ...

    rv=rawget(is, path)
    if rawequal(getmetatable(self), getmetatable(rv)) then rv=rv.__rv end

    if (not rv) then
      rv=require("meta.is." .. path)
    end
    if not rv then
      assert(cache.normalize.module, 'meta.is: meta.module required')
      rv=root('is', path)[1]
    end
    if is.callable(rv) then
      self.__rv=self/rv
      return self(...)
    end

    -- cache('typename', sub)
    -- cache('mt', sub)
    -- cache('instance', sub)
    if len==1 and is.toindex(o) and cache.normalize.module then
--      local tt=cache.type[getmetatable(o)]
      for _,it in ipairs(root(path)) do
        if is.toindex(it) then
--          rv=tt and tt==cache.type[getmetatable(it)] or is.like(o, it) --or is.similar(o, it))
          self.__rv=self/function(x) return is.like(it, x) end
          return self(...)
        end
      end
    end

    -- is.table.callable(t)
    local base = path:strip('%/?[^/]*$'):null()
    if base and cache.normalize.module then
      for _,it in ipairs(root(base)) do
        rv=it
        if base~=k then rv=is.indexable(rv) and (rawget(rv, k) or rv[k]) end
        if rv then
          if type(rv)=='function' then
            self.__rv=self/rv
          elseif is.complex(rv) then
            self.__rv=self/function(x) return is.like(rv, x) end
          else
            self.__rv=self/is.falsy
          end
          return self(...)
        end
      end
    end

    local dotspath = path:strip('^[^/]+%/?')
    return nil, 'meta.is: predicate not found: is.%s (%s)' % {dotspath, path}
  end,
  __div = function(self, it)
    if type(it)=='nil' then return nil end
    if type(it)=='table' and rawequal(getmetatable(self), getmetatable(it)) then return it end
    if type(it)=='function' then
      return self.__non and
      function(...) return (not (it(...) and true or false)) and true or nil end
      or function(...) return it(...) and true or nil end
    end
    if is.callable(it) then return setmetatable({__non=self.__non, __rv=it}, getmetatable(self)) end
    if type(it)=='table' and not getmetatable(it) then
      if self.__non then it.__non=true end
      return setmetatable(it, getmetatable(self)) end
    if type(it)=='string' then return self/{__path=join(self.__path, it),__non=self.__non,__id=it} end
    error('meta.is:__div: left type: %s' % type(it))
  end,
  __index = function(self, k)
    local var = {__non=true, __path=true, __rv=true, __id=true}
    if self==is then
      if k=='non' then return save(self, k, self/{__non=true}) end
    end
    if var[k] then return rawget(self, k) end

    local rv
		if not self.__path then
      rv=rawget(is, k)
      if rawequal(getmetatable(self), getmetatable(rv)) then rv=rv.__rv end
      if not rv then
        if cache.normalize.module then
          rv=root('is', k)[1]
        end
      end
      rv=is.callable(rv) and rv
    end
    return save(self, k, self/(rv or k))
  end,
  __name='is',
  __pairs=function(self) return next, self end,
  __pow = function(self, k) if cache.normalize.module and type(k)=='string' then local _ = root+k end; return self end,
})

return is