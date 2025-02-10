local ok = {string=true, table=true}
return function(self, x)
  if type(x)=='number' and math.floor(x)==x and ok[type(self)] and #self>0 then
    return x<0 and (x+1+#self) or x
  end
  return nil
end