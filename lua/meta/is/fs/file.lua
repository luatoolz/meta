require 'meta.table'
local call = require 'meta.call'
local pkg = ...
local file, path, dir, fs
return function(f)
  path=path or package.loaded['meta.fs.path'] or assert(require 'meta.fs.path')
  file=file or package.loaded['meta.fs.file'] or assert(require 'meta.fs.file')
  dir=dir or package.loaded['meta.fs.dir'] or assert(require 'meta.fs.dir')
  fs=fs     or call(require,'meta.fs')
  if type(f)=='nil' or f=='' or f=='.' then return end
  if (type(f)=='table' or type(f)=='userdata') and getmetatable(f) then
    return (rawequal(getmetatable(io.stdin),getmetatable(f))
      or rawequal(getmetatable(io.stdout),getmetatable(f))
      or rawequal(getmetatable(file),getmetatable(f))
      or (rawequal(getmetatable(path),getmetatable(f)) and f.isfile)
      or (rawequal(getmetatable(dir),getmetatable(f)) and path(f).isfile))
--      (type(fs)=='table' and rawequal(getmetatable(fs),getmetatable(d)) and d.isdir)
      and true or nil
  end
  if type(f)~='string' then return pkg:error('wrong type: %s' ^ type(f), f) end
  local rv = io.open(f, "r")
  if type(rv)=='nil' then return nil end
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (type(en)=='number' and en~=math.maxinteger and en~=2^63 and cl) and true or nil
  end