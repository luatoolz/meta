require "meta.string"
local mcache  = require 'meta.mcache'
local chain   = require 'meta.module.chain'
local is      = require 'meta.is'
local sub     = require 'meta.module.sub'

local instance= require 'meta.module.instance'
local type    = require 'meta.module.type'
local this    = mcache.loaded
local resolve = false

-- k is type name
-- v is object
return this ^ {
init = function() return package.loaded end,
call = function(self, k, v)
  if is.tuple(k) and #k==1 and is.string(k[1]) then
    k=k[1]
  end
  if is.string(k) and (k~=sub(k) or is.match.rootmod(k)) and not self[sub(k)] then
    this[k]=v or true
  end
  if is.string(k) then
    return self[sub(k)] or sub(k)
  end
end,
put = function(self, k, v)
  if is.tuple(k) and #self==0 and #k==1 and is.string(k[1]) then
    k=k[1]
  end
  if is.string(k) and k~='' and (not self[sub(k)]) and k~=sub(k) then
    if v==true or v then self[sub(k)]=k end
    if is.toindex(v) and chain(sub(k)) then
      instance[k]=v
      type[k]=v
    end
  end
end,
get = function(self, k)
  if is.string(k) then
    if resolve then
      local kk = self[sub(k)]
      if kk and type(package.loaded[kk])~='nil' then return kk end
      if k~=kk and k~=sub(k) then kk=k end
      if kk and type(package.loaded[kk])~='nil' then return kk end
      kk=sub(k)
      if kk and type(package.loaded[kk])~='nil' then return kk end
    else
      return self[sub(k)] or sub(k)
    end
  end
end,}