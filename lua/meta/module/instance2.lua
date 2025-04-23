require "meta.string"
local mcache = require 'meta.mcache'
local sub = require 'meta.module.sub'
local chain = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local queue = require 'meta.module.iqueue'
local rev = require 'meta.module.rev'
local mtype = require 'meta.module.type'
local this = mcache.instance

-- k is type name
-- v is object
return this/{
init=function() return package.loaded end,
get=function(self, k)
  while #queue>0 do
    local i = table.remove(queue)
    this[i]=true
  end
  if type(k)=='table' then return self[k] end
  local v
  if type(k)=='string' then
    k = rev[k]
    v = package.loaded[k]
    if v then this[k]=v; return rev[k] end
  end
end,
put=function(self, k, v)
  local orig = k
--print(' PUT', k, type(v))
  rev[k]=v
  k=sub(k)
  if v==true then v=package.loaded[rev[k]] or package.loaded[k] end
--print(' PUT AAA', orig, k, chain[orig], chain[k], 'YY', rev[orig], rev[k], type(v), type(package.loaded[orig]), self[orig], self[k])
--PUT AAA  testdata/factory/loader testdata/factory/loader true  true  testdata.factory.loader testdata.factory.loader nil nil nil

  if k and v then
    if chain[k] then
      if toindex[v] then
--print(' PUT BBB')
    mtype[k]=v
    if (not self[v]) or self[v]~=k then
print(' PUT', orig, k, chain[orig])
      self[v]=k
    end end end
  end
end}