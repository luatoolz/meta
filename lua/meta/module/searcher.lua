local call = require 'meta.call'
local sub = require 'meta.module.sub'
local sep = string.sep
local searchpath, path, cpath = package.searchpath, package.path, package.cpath
return function(mod, key)
  if type(mod)=='table' then mod=tostring(mod) end
  if type(mod)=='string' then
  local m = sub(mod, key)
  if type(m)=='string' then
    return call(searchpath, m, path,  sep)
        or call(searchpath, m, cpath, sep)
  end end return nil end