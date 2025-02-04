local loader = require 'meta.loader'
local mt = require 'meta.mt.mt'
local rexlib = require 'rex_pcre2'

local config = rexlib.config()
local make = rexlib.maketables()
mt(make).__metatable=nil
_ = config

mt(rexlib.new('some'), {
__call=function(self, subj, ...)
  local rv = table.pack(self:tfind(subj, ...))
  rv[3] = rv[3] or {}
  if type(rv[3])=='table' and #rv[3]==0 and rv[1] and rv[2] then
    table.insert(rv[3], subj[{rv[1], rv[2]}])
  end
  return rv[3]
end}, {__metatable=false})

return loader(...) ^ function(x)
  return rexlib.new(table.unpack(type(x)=='string' and {x} or x))
end