return function(f)
  if f==nil or f=='' or f=='.' then return nil end
  assert(type(f)=='string')
  local rv = io.open(f, "r")
  if rv==nil then return nil end
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (type(en)=='number' and en~=math.maxinteger and en~=2^63 and cl) and true or nil
  end