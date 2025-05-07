require 'meta.gmt'
local function append(self, v, k) if type(self)=='table' then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then
    if not self[k] then self[k]=v end
  else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end
      table.insert(self, k, v)
    else
      local add=(getmetatable(self) or {}).__add
      local tab=table or {}
      if add and add~=append and add~=tab.append and add~=tab.append2 and add~=tab.append_unique then return self+v end
      table.insert(self, v)
    end
  end
end end return self end
return append