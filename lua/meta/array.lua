require "meta.no"
local is, mt, export, args, iter = require "meta.is", require "meta.mt", require "meta.export", table.args, table.iter

local array={}
return setmetatable(array,{
  of=table.of,
  flatten=function(self, o) return array(table.flatten((is.array(self) and o) and o or self)) end,
  __add=function(self, it)
    assert(is.similar(array, self))
    if is.bulk(it) then return self .. it end
    it=mt(self).__item and mt(self).__item(it) or it
    if it then table.insert(self, it) end
    return self
  end,
  __array=true,
  __preserve=true,
  __call=function(self, ...)
    assert(is.similar(array, self))
    assert(is.callable(mt(self).__item) or mt(self).__item==nil)
    if select('#', ...)==0 then return setmetatable({}, getmetatable(self)) end
    local it=select(1, ...)
    if type(it)=='userdata' then it=export(it) end
    if type(it)=='table' and (not getmetatable(it)) and type(next(it))=='nil' then return setmetatable(it, getmetatable(self)) end
    if type(it)=='table' and #it>0 then
      local mts = {
        [getmetatable(table())]=true,
        [getmetatable(array)]=true,
      }
      local gmt=getmetatable(it)
      if ((not gmt) or mts[gmt]) and is.null(mt(self).__item) then return setmetatable(it, getmetatable(self)) end
    end
    return self() .. args(...)
  end,
  __concat=function(self, it)
    assert(is.similar(array, self))
    if is.bulk(it) then for x in iter(it) do _=self+x end end
    return self
  end,
  __eq=function(a, b)
    if not is.array(a) then a,b = b,a end
    assert(is.similar(array, a))
--    assert(is.similar(a, b))
    if #a~=#b then return false end
    if #a==0 then return (type(next(a))=='nil' and type(next(b))=='nil') and true or false end
    for i=1,#a do if a[i]~=b[i] then return false end end
    return true
  end,
  __index=function(self, k)
    assert(is.similar(array, self))
    if type(k)=='string' then return mt(self)[k] end
    return rawget(self, k)
  end,
  __iter=table.ivalues,
  __mod=table.filter,
  __mul=table.map,
  __name='array',
  __pairs=ipairs,
  __sub=function(self, it)
    assert(is.similar(array, self))
    if is.bulk(it) then for x in iter(it) do _=self-x end end
    if it and type(it)=='number' then
      if it<1 or it>#self then it=nil end
      table.remove(self, it) end
    return self
  end,
  __tonumber=function(self) return #self end,
  __tostring=function(self) assert(is.similar(array, self)); return table.concat(self*tostring, "\n") end,
  __unm=function(self) assert(is.similar(array, self)); return #self>0 and table.remove(self) or nil end,
})