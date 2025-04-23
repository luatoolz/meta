return function(self,k,v)
  if type(self)=='table' and type(k)~='nil' and type(v)~='nil' then
  rawset(self, k, v)
  return v end end