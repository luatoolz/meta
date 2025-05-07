local module
local chain = require 'meta.module.chain'
local call  = require 'meta.call'
local iter  = require 'meta.iter'
local path  = string.joiner('/')
return function(...)
  local p = path(...)
  local root = iter.ipairs(chain)
  local cur, mod, e

  module=module or package.loaded['meta.module']
  if type(module)=='table' then
    repeat
      cur=root()
      mod = cur and (module(path(cur, p)) or {}).ok
    until mod~=nil or not cur
    return mod and mod.load or nil
  end

  repeat
    cur=root()
    if cur then
      local p1, p2
      p1 = path(cur, p)
      p2 = p1 and p1:gsub('%/+','.')
      mod = package.loaded[p1] or package.loaded[p2]
      if not mod then
        mod, e = call.quiet(require, p2)
        if mod then break end
      end
    end
  until mod~=nil or not cur
  return mod, e
end