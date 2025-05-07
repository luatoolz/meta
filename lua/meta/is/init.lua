local chain     = require 'meta.module.chain'
local load      = require 'meta.module.load'
local mt = {
  add           = require 'meta.mt.add',
  concat        = require 'meta.mt.concat',
  indexer       = require 'meta.mt.indexer',
  tostring      = require 'meta.mt.tostring',
}
local tab = {
  save          = require 'meta.table.save',
  index         = require 'meta.table.index',
  interval      = require 'meta.table.interval',
  select        = require 'meta.table.select',
}
local types = {
  null          = 'nil',
  ['nil']       = 'nil',
  string        = 'string',
  boolean       = 'boolean',
  number        = 'number',
  func          = 'function',
  ['function']  = 'function',
  CFunction     = 'CFunction',
  thread        = 'thread',
  userdata      = 'userdata',
  table         = 'table',
}
local is
is = setmetatable({'is'},{
  tab.index,
  tab.interval,
  tab.select,
  function(self, k) if type(k)=='string' then
    local found
    if types[k] then k=types[k]; found=function(x) return type(x)==k or nil end end
    if not found then
      local handler = self[false] or load
      found=handler(self, k)
    end
    return tab.save(self, k, found) end end,

  __name        = 'is',
  __sep         = '.',
  __add         = mt.add,
  __concat      = mt.concat,
  __index       = mt.indexer,
  __tostring    = mt.tostring,

  __call        = function(self, a, b) local h=self[true] or is.like; return h(a,b) end,
  __pow         = function(self, k) if type(k)=='string' then _=chain^k end; return self end,
})
is.match=is..'matcher'
is.match[false]=function(self, k) return string.matcher(load('matcher', k), true) end
return is