require "compat53"

return function(orig, tovalue)
	local dir = orig
  if dir==nil then return nil end
  assert(type(dir)=='string')
  if dir=='' then dir='.' end
  local rv = io.open(dir, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return tovalue and orig or (pos==nil and it==nil and en~=0 and cl)
end
