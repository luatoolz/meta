require 'meta.gmt'
local pkg = ...
local root
require "meta.is"
return function(f)
  root=root or package.loaded['meta.file']
  if type(f)=='nil' or f=='' or f=='.' then return end
  if (type(f)=='table' or type(f)=='userdata') and getmetatable(f) then
    return rawequal(getmetatable(io.stdin),getmetatable(f)) or rawequal(getmetatable(root),getmetatable(f))
  end
  if type(f)~='string' then return nil, '%s: wrong type: %s' % {pkg, type(f)} end
  local rv = io.open(f, "r")
  if type(rv)=='nil' then return end
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (type(en)=='number' and en~=math.maxinteger and en~=2^63 and cl) and true or nil
  end