return function(self, v, k) if type(self)=='table' then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then
    self[k]=v
  else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end
      table.insert(self, k, v)
    else
--      if mt(self).__add and mt(self).__add~=table.append and mt(self).__add~=table.append_unique then return self+v end
      table.insert(self, v)
    end
  end
end end return self end