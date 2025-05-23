local meta = require 'meta'
local is, id, iter, save = meta.is, meta['mt.id'], meta.iter, table.save
local tuple = require 'meta.tuple'
local array = require 'meta.array'

return setmetatable({},{
  __array=true,     -- for json/bson conventions
  __preserve=true,  -- type save flag
  __add=function(self, it) if is.bulk(it) then return self..it else self[it]=it end; return self end,
  __call=function(self, ...) return setmetatable({},getmetatable(self))..iter(tuple.args(...)) end,
  __concat=function(self, it) if it then
    if is.table(self) and not getmetatable(self) then
      for v in iter(it) do table.insert(self, v) end; return self end
    if is.bulk(it) then for v in iter(it) do local _=self+v end else self[it]=it end
    return self end end,
  __eq=function(a,b) return table.equal(table(a*is.truthy),table(b*is.truthy)) end,
  __index=function(self, it) return rawget(self, id(it)) end,
  __le=function(a, b)
    for it in iter(a) do if not b[it] then return false end end; return true end,
  __lt=function(a, b) return a <= b and not (b <= a) end,
--  __mode='v',
  __div=table.div,
  __mul=table.map,
  __mod=table.filter,
  __name='set',
  __sep="\n",
  __newindex=function(self, it, v) if type(v)=='nil' then return save(self, id(it), nil) end
    local item = select(2,next(self))
    if type(v)~='nil' and ((not item) or is.like(item, v)) then save(self, id(v), v) end end,
  __pairs = function(self) return next, self end,
  __sub=function(self, it) if is.bulk(it) then
    for v in iter(it) do self[v]=nil end else self[it]=nil end return self end,
  __export=function(self, fix) return table.sorted(array(self)) end, -- TODO: fix export
  __tostring=function(self) return table.concat(table.sorted(array(self)*tostring), "\n") end,
})