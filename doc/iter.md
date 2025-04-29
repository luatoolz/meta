# meta.iter
`__iter` convention implementation. Order: value, key. 

Main object: `iter`
```lua
return setmetatable(iter,{
__concat = function(r, it) if type(r)=='table' and is.like(iter,it) then
  return iter.collect(it, r, true) end end,
__call = function(self, ...)
  local it, to = ...
  if type(it)=='nil' or not n(...) then
    it = self.it
    if it then return it() else return nil,nil end end
  if is.like(iter,it) and not to then return it end
  return setmetatable({it=iter.it(it)}, getmetatable(iter))*to end,
__iter = function(self, to) return iter.iter(self, to) end,
__div  = function(self, to) return iter.mul(self, op.div(to))() end,
__mul  = function(self, to) return iter(iter.mul(self, op.mul(to), true)) end,
__mod  = function(self, to) return iter(iter.mul(self, op.mod(to), true)) end,
__name = 'iter',})
```

`__call` accepting tables, functions, `iter` objects which stands as `bulk` objects. In fact bulk object - is any object containing iteratable items.

## conventions
- `__iter`: stateful iterator generator, defines a method to iterate items of object
- `__div`: '/' mass operator (usually `table.div` function, which is a way to define `iter.find`-like operation)
- `__mul`: '*' mass operator (usually `table.map` function)
- `__mod`: '%' mass operator (usually `table.filter` function)

## functions
- `iter.mul`: function multiplication returning function iterator
- `iter.mod`: filter variant of `iter.mul`

- `iter.items`: generalized table- iterator
- `iter.collect`: collect iterator to table
- `iter.each`: run callable for each item of bulk object
- `iter.reduce`: reducer
- `iter.find`: finder

Additional functions. TODO Later.
```lua
iter.range
iter.ipairs
iter.pairs
iter.ivalues
iter.svalues
iter.values
iter.ikeys
iter.keys
iter.skeys
iter.tuple
iter.args
iter.it
iter.iter
iter.sum
iter.count
iter.equal
iter.rawequal
```
