local t=require "meta"
local is, mt = t.is, t.mt

function iindexed(self) if type(self)~='table' then return end; local it=ipairs((self)); return type((it(self,0)))=='number' end

return function(x) return (type(x)=='table' and (
  is.array(x) or
  is.set(x) or
  is.ofarray(x) or
  is.ofset(x) or
  iindexed(x) or
  x.__array or
  mt(x).__array or
  mt(x).__arraytype or
  mt(x).__jsontype=='array' or
  mt(x).__name=='json.array'
)) and true or nil end