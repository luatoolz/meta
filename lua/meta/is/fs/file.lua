require 'meta.gmt'
require 'meta.table'
local pkg = ...
local file, path, dir, fs
return function(f)
  path=path or require('meta.fs.path')
  file=file or require('meta.fs.file')
  dir=dir   or require('meta.fs.dir')
  fs=fs     or require('meta.fs')
  if type(f)=='nil' or f=='' or f=='.' then return nil end
  if type(f)=='userdata' and getmetatable(f) then
    return rawequal(getmetatable(io.stdin),getmetatable(f))
      or rawequal(getmetatable(io.stdout),getmetatable(f))
  end
  if type(f)=='table' and getmetatable(f) then
    return rawequal(getmetatable(file),getmetatable(f))
      or (rawequal(getmetatable(path),getmetatable(f)) and f.isfile)
      or (rawequal(getmetatable(dir),getmetatable(f)) and path(f).isfile)
  end
  if type(f)~='string' then return pkg:error('wrong type: %s' ^ type(f), f) end
  local rv = io.open(f, "r")
  if type(rv)=='nil' then return nil end
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (type(en)=='number' and en~=math.maxinteger and en~=2^63 and cl) and true or nil
  end