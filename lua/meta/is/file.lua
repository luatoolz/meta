require 'meta.table'
local pkg = ...
local file, path
return function(f)
  path=path or package.loaded['meta.path'] or assert(require 'meta.path')
  file=file or package.loaded['meta.file'] or assert(require 'meta.file')
  if type(f)=='nil' or f=='' or f=='.' then return end
  if (type(f)=='table' or type(f)=='userdata') and getmetatable(f) then
    return (rawequal(getmetatable(io.stdin),getmetatable(f))
      or rawequal(getmetatable(io.stdout),getmetatable(f))
      or rawequal(getmetatable(file),getmetatable(f))
      or (rawequal(getmetatable(path),getmetatable(f)) and f.isfile))
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