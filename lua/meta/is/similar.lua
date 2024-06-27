return function(a, b) return type(a)=='table' and type(a)==type(b) and getmetatable(a) and getmetatable(a)==getmetatable(b) or false end

--[[
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
--]]
