# meta.computed, meta.computable
On-demand computable object properties. `meta.module`, `meta.path` and other modules are implemented using this approach.

Any computable is a lua function which executes on `__index` event.
- `computed`: evaluation result is saved to object (permanent)
- `computable`: eval result is not saved to object

Something like this:
```lua
local this = setmetatable({},{
  __call = function(self, x)
    return setmetatable(x, getmetatable(self))
  },
  __computed = {
    name      = function(self) return table.concat(self, ',') end,
  },
  __computable = {
    root      = function(self) return self[1] end,
  },
  __index = computed,
  __newindex = setcomputed,
  __div = table.div,
  __mul = table.map,
  __mod = table.filter,
})

local item = this({'a','b','c'})

print(item.root)    -- 'a'
print(item.name)    -- 'a/b/c'

```
