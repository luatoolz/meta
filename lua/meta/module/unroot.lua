require 'meta.string'
local chain = require 'meta.module.chain'
return function(x)
  if type(x)~='string' then return nil end
  if x and chain[x] and chain[x]~=x then
    x=x:gsub('^([^/.%s]+[/.%s])','', 1)
    end return x end