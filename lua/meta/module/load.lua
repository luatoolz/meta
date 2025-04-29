local module = require 'meta.module'
local chain = require 'meta.module.chain'
local iter = require 'meta.iter'
local path = string.joiner('/')
return function(...)
  local p = path(...)
  local root = iter(chain)
  local cur, mod
  repeat
    cur=root()
    mod = cur and (module(cur, p) or {}).ok
  until mod or cur==nil
  return mod and mod.load or nil
end