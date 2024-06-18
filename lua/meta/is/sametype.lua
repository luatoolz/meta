local skip = {
  __name=true,
  __item=true,
}
return function(self, x)
  if type(self)~=type(x) then return false end
  if type(self)=='table' and type(x)=='table' then
    local mt = getmetatable(self)
    local mtx = getmetatable(x)
    if mt ~= mtx then return false end
    mt = mt or {}
    mtx = mtx or {}
    for k,v in pairs(mt) do
      if type(k)=='string' and k:sub(1,2)=='__' then
        if not skip[k] and v~=mtx[k] then
          return false
        end
      end
    end
  end
  return true
end
