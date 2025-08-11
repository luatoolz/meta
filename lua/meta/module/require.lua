require 'compat53'
local call = require 'meta.call'
local searchpath, path = package.searchpath, package.path
return function(name)
  if type(name)~='string' or name=='' then return nil, 'invalid argument' end
  local pkgloaded = package.loaded[name]
  if type(pkgloaded)~='nil' and type(pkgloaded)~='number' and (type(pkgloaded)~='userdata' or type(getmetatable(pkgloaded))~='nil') then
    return pkgloaded
  end
  local p = call.pcall(searchpath, name, path,  '.')
  local f = p and call.pcall(loadfile,p)
  return f and call.pcall(f, name)
end