require 'compat53'
require 'meta.gmt'
require 'meta.string'

local is

local chain     = require 'meta.module.chain'
local load      = require 'meta.module.load'
local save      = require 'meta.table.save'

local index     = require 'meta.table.index'
local interval  = require 'meta.table.interval'
local select    = require 'meta.table.select'

local like      = require 'meta.is.like'

-- TODO: rewrite this shit
--local function noop(...) return ... end
local function linked(self, k)
  local dir=tostring(self)
  if k:startswith('..') then
    k=k:gsub('%.%.%/?','',1)
    if #self==1 then
      p=k
    else
      dir=dir:gsub('%/[^/]+$','')
      p=dir..'/'..k
    end
  else
    p=dir..'/'..k
  end
  v=load(p)
  if type(v)=='function' then return v end
  return type(v)=='table' and function(o) return is(v,o) and true or nil end or nil
end

local loads     = {'callable','like','null'}
local types = {
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
is = setmetatable({'is'},{
  index,
  interval,
  select,
  function(self, k) if type(k)=='string' then
    local key, found
    if types[k] then
      key=types[k]
      found=function(x) return type(x)==key or nil end
    else
      local handler = self[false]
      local ok = load(self..k)
      if not handler then
        if is.string(ok) then return save(self, k, linked(self, ok)) end
      end
      if ok and handler then found=handler(ok) else found=ok end
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
    rv[true]=it[true]
    rv[false]=it[false]
    return rv
    elseif type(self)=='table' and type(it)=='string' then
      local sep = getmetatable(self).__sep
    return table.concat({tostring(self),it},sep) end end,

  __index       = require 'meta.mt.indexer',
  __tostring    = function(self) return table.concat(self,getmetatable(self).__sep or '') end,
  __call        = function(self, a, b) local h=self[true] or like; return h(a,b) end,
  __pow         = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
})
for _,k in pairs(loads) do _=is[k] end
for k,v in pairs(types) do _=is[k] end
_=is.tuple
_=is.like
_=is.toindex
_=is.pkgloaded
is.match=setmetatable({'matcher',[false]=function(pat) if type(pat)=='string' then
  return function(it) if type(it)=='string' then return it:match(pat) end end
  end return function() return nil end end,},getmetatable(is))
is.fs=is..{'fs'}
is.has=is..{'has'}
is.table=setmetatable({'is','table',[true]=function(x) return type(x)=='table' or nil end},getmetatable(is))
is.number=setmetatable({'is','number',[true]=function(x) return type(x)=='number' or nil end},getmetatable(is))
is.net=is..{'net'}
return is