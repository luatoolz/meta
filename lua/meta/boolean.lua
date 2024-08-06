require "compat53"
require 'meta.string'

local _toboolean = setmetatable({
  [0]=false,
  ["0"]=false,
  ["false"]=false,
  [""]=false,
  [false]=false,
  ['nil']=false,
}, {
  __call=function(self, it) return self[it] end,
  __index=function(self, it)
    if type(it)=='table' then
      local tb=(getmetatable(it) or {}).__toboolean
      if type(tb)=='function' then return tb(it) end
      return type(next(it))~='nil'
    end
    return (type(it)~='nil'
      and rawget(self, tostring(it):lower())~=false
      and (type(it)~='string' or not it:match("^%s+$"))
      and it)
    and true or false
  end,
})

toboolean=_toboolean
return toboolean
