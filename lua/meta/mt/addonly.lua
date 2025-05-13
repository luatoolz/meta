return function(self, p) if type(self)=='table' and type(p)~='nil' then self[#self+1]=p end end
--[[
  if type(p)=='table' then p=iter.ivalues(p) end
  if type(p)=='table' or type(p)=='function' then for k in iter(p) do _=self+k end end
  if type(p)=='string' then
    if not p:match('^[^/]+$') then return self+p:gmatch('[^/]+') end
    if p=='..' and #self>0 then table.remove(self) end
    if not p:match('^%.*$') then table.insert(self,p) end
end end return self end--]]
