require 'meta.table'
local itable = require 'meta.mt.table'
local iter = require 'meta.iter'
local checker = require 'meta.checker'
local chain = require 'meta.module.chain'
local load = require 'meta.module.load'
local save = table.save

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

  indexable = mt.__index,
  iterable  = function(o)
    if type(o)=='table' and ((not getmetatable(o)) or rawequal(getmetatable(o),getmetatable(table()))) then return true end
    if is.complex(o) then local g = getmetatable(o)
    return g and (g.__pairs or g.__ipairs or g.__iter) and true or nil end end,
}

setmetatable(is,{
  __name='is',
  __sep = '/',
  __call = function(self, a, b) local h=self[true] or is.like; return h(a,b) end,
  __concat = function(self, k) if type(k)=='string' or type(k)=='table' or type(k)=='function' then
    local rv = self[{}]
    if type(k)=='string' then k=k:gmatch('[^/]+') end
    if type(k)=='table' or type(k)=='function' then
      for p in iter(k) do if p=='..' then table.remove(rv) else table.insert(rv, p) end end
    end
    return setmetatable(rv, getmetatable(self))
  end end,
  __index = function(self, k)
    if type(k)=='boolean' then return rawget(self, k) end
    local handler = self[false] or load
    return itable(self, k) or save(self, k, handler(self, k)) or nil
  end,
  __pow = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
  __tostring = table.tostring,
})
is.has=is..'has'
is.match=is..'matcher'
is.match[false]=function(self, k) return string.matcher(load('matcher', k), true) end
return is