require "compat53"

return function(dir)
  assert(type(dir)=='string')
  if dir==nil then return nil end
  local rv = io.open(dir, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return pos==nil and it==nil and en~=0 and cl
end
