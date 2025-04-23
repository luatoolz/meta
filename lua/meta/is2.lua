require "meta.table"
local itable = require "meta.mt.table"
--local pkg = ...
local iter = require "meta.iter"
local checker = require 'meta.checker'
local save = table.save

--[[
local pkg, _, iter, _, _, save =
  ...,
--  require "meta.checker",
  require "meta.iter",
--  require "meta.mt.root",
--  string.dot:joiner(),
  table.save
--]]

local chain = require('meta.module.chain')
--local meta = require('meta.lazy')
--local module = require('meta.module')
--local meta = require('meta.loader')('meta')

local atom, functions, virtual, complex =
  checker({["number"]=true,["boolean"]=true,["string"]=true,["nil"]=true,}, type),
  checker({["function"]=true,["CFunction"]=true,}, type),
  checker({["function"]=true,["thread"]=true,["CFunction"]=true,}, type),
  checker({["userdata"]=true,["table"]=true,}, type)

local mt
mt = setmetatable({
  __index=function(o) return mt~=o and complex(o) and getmetatable(o) and (type((getmetatable(o) or {}).__index)=='function' or type((getmetatable(o) or {}).__index)=='table') end,
},{
  __call=function(self, o) return complex(o) and type(getmetatable(o))=='table' end,
  __index=function(self, k) return string.null(k) and save(self, k, self/k) end,
  __div=function(self, k) return string.null(k) and function(o) return complex(o) and functions((getmetatable(o) or {})[k]) end end,
})

-- number string table boolean
is = {
  'is',
  mt = mt,
  atom = atom,
  ['nil'] = atom/'nil',
  string = atom/'string',
  boolean = atom/'boolean',
  number = atom/'number',
  func = functions/'function',
  functions = functions,
  ['function'] = functions/'function',
  virtual = virtual,
  CFunction = virtual/'CFunction',
  thread = virtual/'thread',
  complex = complex,
  userdata = complex/'userdata',
  empty = checker({
    ['nil']=true,
    number=function(x) return x==0 end,
    string=function(x) return ((x=='' or x=='0') or x:match("^%s+$")) end,
    table=function(x) return type(next(x))=='nil' end,
  }, type),
--  callable = checker({["function"]=true,["CFunction"]=true,["table"]=mt.__call,["userdata"]=mt.__call,}, type),
--  callable = require "meta.is.callable",
--  toindex = checker({['function']=true,['table']=true,['userdata']=true,['CFunction']=true}, type),
  indexable = mt.__index,
  iterable  = function(o)
    if type(o)=='table' and ((not getmetatable(o)) or rawequal(getmetatable(o),getmetatable(table()))) then return true end
    if is.complex(o) then local g = getmetatable(o)
    return g and (g.__pairs or g.__ipairs or g.__iter) and true or nil end end,
  loaded = function(o) return require('meta.mcache').loaded[o] and true end,
  truthy = function(...) return true end,
  falsy  = function(...) return nil end,
  noop   = function() end,
--  match  = module('meta.matcher')*string.matcher,
  match = setmetatable({}, {__index = function(self, it) return save(self, it, string.matcher(require('meta.matcher.'..it), true)) end,}),
}

return setmetatable(is,{
  __name='is',
  __sep = '.',

  __add = function(self, k) if type(k)=='string' then
    local o = self[{}]; table.insert(o, k)
    o['..']=self
    return save(self, k, setmetatable(o, getmetatable(self)))
  end return self end,
  __call = function(self, ...)
--    local path = tostring(self)
--    print('\n-----------------------------\n meta.is', 'path is', path)
    return save(self, true, require('meta.' .. tostring(self)))
--    local rv = save(self['..'], self[-1], f)
--    if type(rv)=='function' or type(rv)=='table' and (getmetatable(rv) or {}).__call then return rv(...) end
  end,
  __unm = function(self) local f=rawget(self, true); return save(self, false, function(...) return not f(...) end) end,

--[[
    if rv and is.callable(rv) then
      if type(rv)=='function' then return rv(...) end
      rv=rv(...)
      if non then return (not (rv and true or false)) and true or nil end
      return rv and true or nil end

    if rv then return pkg:error('__call: await callable, got', type(rv)) end
    if type(path)~='string' then return pkg:error('bad object path', type(path)) end
    local o = ...

    rv=rawget(is, path)
    if rv and rawequal(getmetatable(self), getmetatable(rv)) then rv=rv.__rv end
    rv=rv or root('is', path)
    if is.callable(rv) then
      self.__rv=self/rv
      return self(...)
    end

    -- is.array
    if len==1 and is.toindex(o) then
      rv=root(path)
      if rv then
        self.__rv=self/function(x) local saverv=rv; return is.like(saverv, x) end
        return self(...)
      end
    end

    -- is.table.callable(t)
    local base = path:strip('%/?[^/]*$'):null()
    if base then
      rv=root(base)
      if base~=k then rv=is.indexable(rv) and (rawget(rv, k) or rv[k]) end
      if rv then
        if type(rv)=='function' then
          self.__rv=self/rv
        elseif is.complex(rv) then
          self.__rv=self/function(x) local saverv=rv; return is.like(saverv, x) end
        else
          self.__rv=self/is.falsy
        end
        return self(...)
      end
    end
    local dotspath = path:strip('^[^/]+%/?')
    return pkg:error('predicate not found', dotspath, path)
--]]
--    return pkg:error('predicate not found', path)
--  end,
  __concat = function(self, k) if type(k)=='string' or type(k)=='table' or type(k)=='function' then
    local o = self
    if type(k)=='string' then k=k:gmatch('[^/]+') end
    if type(k)=='table' or type(k)=='function' then
      for p in iter(k) do o=o+p end end
    return o
  end end,
  __index = function(self, k) return itable(self, k) or (self..k) or nil end,
--  __index = function(self, k) return table.index(self, k) or table.interval(self, k) or (self..k) or nil end,
--  __pairs=function(self) return next, self end,
  __pow = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
  __sub = table.delete,
  __tostring = table.tostring,
--  __unm = function(self) local f=rawget(self, true); return save(self, false, function(...) return not f(...) end) end,
})