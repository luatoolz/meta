require "meta.table"
local pkg, checker, root, join, save, is =
  ...,
  require "meta.checker",
  require "meta.mt.root",
  string.dot:joiner(),
  table.save

local atom, functions, virtual, complex =
  checker({["number"]=true,["boolean"]=true,["string"]=true,["nil"]=true,}, type),
  checker({["function"]=true,["CFunction"]=true,}, type),
  checker({["function"]=true,["thread"]=true,["CFunction"]=true,}, type),
  checker({["userdata"]=true,["table"]=true,}, type)

local mt = setmetatable({
  __index=function(o) return complex(o) and getmetatable(o) and (type((getmetatable(o) or {}).__index)=='function' or type((getmetatable(o) or {}).__index)=='table') end,
},{
  __call=function(self, o) return complex(o) and type(getmetatable(o))=='table' end,
  __index=function(self, k) return string.null(k) and save(self, k, self/k) end,
  __div=function(self, k) return string.null(k) and function(o) return complex(o) and functions((getmetatable(o) or {})[k]) end end,
})
-- number string table boolean
is = {
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

  callable = checker({["function"]=true,["CFunction"]=true,["table"]=mt.__call,["userdata"]=mt.__call,}, type),
--  callable = require "meta.is.callable",
  toindex = checker({['function']=true,['table']=true,['userdata']=true,['CFunction']=true}, type),
  indexable = mt.__index,
  iterable  = function(o)
    if type(o)=='table' and ((not getmetatable(o)) or rawequal(getmetatable(o),getmetatable(table()))) then return true end
    if is.complex(o) then local g = getmetatable(o)
    return g and (g.__pairs or g.__ipairs or g.__iter) and true or nil end end,
  loaded = function(o) return require('meta.cache').loaded[o] and true end,
  truthy = function(...) return true end,
  falsy  = function(...) return nil end,
  noop   = function() end,
  match = setmetatable({}, {__index = function(self, it) return table.save(self, it, string.matcher(root('matcher', it), true)) end,}),
}

return setmetatable(is,{
  __tostring = function(self) if self==is then return pkg end; return self.__path end,
  __call = function(self, ...)
    local len, path, non, rv, k = select('#', ...), self.__path, self.__non, self.__rv, self.__id

    if rv and is.callable(rv) then
      if type(rv)=='function' then return rv(...) end
      rv=rv(...)
      if non then return (not (rv and true or false)) and true or nil end
      return rv and true or nil end

    if rv then assert(false, 'meta.is.__rv: await callable, got %s' % type(rv)) end
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
    return pkg:error('bad argument type', type(it))
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
      rv=rv or root('is', k)
      rv=is.callable(rv) and rv
    end
    return save(self, k, self/(rv or k))
  end,
  __name='is',
  __pairs=function(self) return next, self end,
  __pow = function(self, k) if type(k)=='string' then return (root()+k) and self end; return self end,
})