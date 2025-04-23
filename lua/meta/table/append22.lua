return function(self, v, k)
--[[
  if type(self)~='table' or type(v)=='nil' then return self end
  if type(self)=='table' and type(v)~='nil' then
    if type(k)=='number' then
      table.insert(self, k, v)
    elseif type(k)=='nil' then
print('AAA')
print('object length = ' .. type(self) .. ' ' .. #self .. '[' .. v .. ']')
      table.insert(self, v)
print('BBB')
--      self[#self+1]=v
    else
      self[k]=v
    end
  else
    error('self is ' .. type(self))
  end
  return self
end
--]]

  if type(self)=='table' and type(v)~='nil' then
    if type(k)~='nil' and type(k)~='number' then
--      table.insert(self, v)
      self[k]=v
    else
        print('k=' .. type(k) .. tostring(k))
        if type(k)=='number' and k<=#self+1 then
          if k<1 then k=1 end
          table.insert(self, k, v)
        else
          print('9 v ' .. type(v) .. '=' .. v)
          print(1)
          table.insert(self, v)
          print(2)
        end
      end
--    end
  end
  return self
end