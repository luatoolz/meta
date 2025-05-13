require 'compat53'
require 'meta.gmt'

local chain     = require 'meta.module.chain'
local load      = require 'meta.module.load'
local save      = require 'meta.table.save'

local loads     = {'callable','like'}
local types = {
  null          = 'nil',
  ['nil']       = 'nil',
  string        = 'string',
  boolean       = 'boolean',
  number        = 'number',
  func          = 'function',
  ['function']  = 'function',
  CFunction     = 'CFunction',
  cfunction     = 'CFunction',
  thread        = 'thread',
  userdata      = 'userdata',
  table         = 'table',
}
local is
is = setmetatable({'is'},{
  __index = function(self, k) if type(k)=='string' then
    local key, found
    if types[k] then
      key=types[k]
      found=function(x) return type(x)==key or nil end
    else
      local handler = self[false] or function(...) return ... end
      found=handler(load(self..k))
    end
    found=found or self..k
    return save(self, k, found) end end,

  __name        = 'is',
  __sep         = '/',
  __add         = function(self, p) if type(self)=='table' and type(p)~='nil' then self[#self+1]=p end end,
  __concat      = function(self, it) if type(self)=='table' and type(it)=='table' then
    local rv = setmetatable({},getmetatable(self))
    for i,v in ipairs(self) do rv[#rv+1]=v end
    for i,v in ipairs(it) do rv[#rv+1]=v end
    return rv
    elseif type(self)=='table' and type(it)=='string' then
      local sep = getmetatable(self).__sep
    return table.concat({tostring(self),it},sep) end end,

  __tostring    = function(self) return table.concat(self,getmetatable(self).__sep or '') end,
  __call        = function(self, a, b) local h=self[true] or is.like; return h(a,b) end,
  __pow         = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
})
for k,v in pairs(types) do _=is[k] end
for _,k in pairs(loads) do _=is[k] end
_=is.like
_=is.toindex
_=is.pkgloaded
is.match=setmetatable({'matcher',[false]=function(pat) if type(pat)=='string' then
  return function(it) if type(it)=='string' then return it:match(pat) or nil end end
  end return function() return nil end end,},getmetatable(is))
is.fs=is..{'fs'}
is.has=is..{'has'}
is.table=setmetatable({'is','table',[true]=function(x) return type(x)=='table' or nil end},getmetatable(is))
return is