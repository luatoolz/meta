local call = require 'meta.call'
local sub = require 'meta.module.sub'
local sep = string.sep
local searchpath, path, cpath = package.searchpath, package.path, package.cpath
return function(mod, key) if type(mod)=='string' then
  local m = sub(mod, key)
  if type(m)=='string' then
    return call(searchpath, m, path,  sep)
        or call(searchpath, m, cpath, sep)
--      or (no.parent(mod) and table.find({no.call(searchpath, no.sub(no.parent(mod), no.basename(mod), key), path, sep)}, is.file) or nil)
  end
end; return nil end