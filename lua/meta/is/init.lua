require 'compat53'
require 'meta.gmt'
require 'meta.string'

local is

local call      = require 'meta.call'
local chain     = require 'meta.module.chain'
local loadm     = require 'meta.module.load'
local req       = require 'meta.module.require'
local save      = require 'meta.table.save'

local index     = require 'meta.table.index'
local interval  = require 'meta.table.interval'
local select    = require 'meta.table.select'
local pat       = require 'meta.pat'

local like      = require 'meta.is.like'
local vpath     = require 'meta.fs.vpath'

local load      = loadm

local function linked(self, k, ldr)
  local mp, last = vpath(self, k)
  local dir, p = string(last[1]), string(last[2])
  if mp then
    v=ldr(mp)
    if (not v) and dir and p then v=ldr(dir); if type(v)=='table' then v=v[p] else v=nil end end
    if type(v)=='function' then return v end
    return type(v)=='table' and function(o) return is(v,o) and true or nil end or nil
  end
  return nil
end

local loads     = {'callable','like','null','tuple','toindex','pkgloaded','complex'}
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
local skiptype = {
  number        = true,
  table         = true,
}
local key       = {
  handler       = false,
  caller        = true,
}
is = setmetatable({'is'},{
  index,
  interval,
  select,
  function(self, k) if type(k)=='string' then
    local newkey, found
    if types[k] then
      newkey=types[k]
      found=function(x) return type(x)==newkey or nil end
    else
      local handler, ok = self[key.handler]
      if handler then ok=handler(self, k, load) else ok=load(self..k) end
      if not ok then return nil end
      if is(is, ok) then
        return rawget(self, k) or save(self, k, ok) end
      if (not handler) then
        if type(ok)=='string' then ok=linked(self, ok, loadm) end
        if type(ok)=='table' and not getmetatable(ok) then ok=self..ok end
      end
      found=ok
    end
    return rawget(self, k) or save(self, k, found) end end,

  __name        = 'is',
  __sep         = '/',
  __add         = function(self, k)
    if type(self)=='table' and type(k)=='nil' then return self end
    if type(self)=='table' and type(k)=='string' then
      if k=='..' then return self[k] end
      local rv = {}
      for i,v in ipairs(self) do rv[#rv+1]=v end
      rv[#rv+1]=k
      setmetatable(rv,getmetatable(self))
      rv['..']=self
      return save(self, k, rv)
    end return nil end,
  __concat      = function(self, it) if type(self)=='table' and type(it)=='table' then
    local rv=self
    for _,k in ipairs(it) do if type(k)=='string' then rv=rv+k end end
    for k,v in pairs(it) do if type(k)~='nil' and type(k)~='number' and k~='..' then rv[k]=v end end
    return rv
    elseif type(self)=='table' and type(it)=='string' then
      local sep = getmetatable(self).__sep
    return table.concat({tostring(self),it},sep) end end,

  __index       = require 'meta.mt.indexer',
  __tostring    = function(self) return table.concat(self,getmetatable(self).__sep or '') end,
  __call        = function(self, a, b)
    if type(a)=='string' and b then
      local mp, last = vpath('',a)
      local dir, p = string(last[1]), string(last[2])
      a=load(mp)
      if (not a) and dir and p then a=load(dir); if type(a)=='table' then a=a[p] else a=nil end end
    end
    local h=self[key.caller] or like; return call.pcall(h,a,b) end,
  __pow         = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
})

for k,v in pairs(types) do if not skiptype[k] then _=is[k] end end
for _,k in pairs(loads) do _=is[k] end

_=is+'fs'
_=is..{'table', [key.caller]=function(x) return type(x)=='table' or nil end}
_=is..{'number', [key.caller]=function(x) return type(x)=='number' or nil end}
_=is..{'match',[key.handler]=function(self, k, ldr) if type(self)=='table' and type(k)=='string' then
  return (pat and pat[k] or {}).match or nil end return nil end,}

load = function(...) return loadm(req, ...) end

return is