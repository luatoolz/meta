# meta.assert.d
Pluggable loader for `meta.is`/`luaassert` definitions. Loader handler auto create `luassert` rule from exported lua tables.
```lua
-- assert.d/callable.lua
return {1, "expected to be callable: %s", "expected to be not callable: %s"}
```

```lua
-- assert.d/bulk.lua
return {"expected to be bulk: %s", "expected to be not bulk: %s"}
```

Handler code is located in `meta/assert.d/init.lua`.

# assert arguments
- assert name is set from lua module name (`bulk.lua` -> `bulk`) (auto)
- callable (optional) or auto-import from `meta.is` using its name (`meta.is.bulk`)
- number of arguments (optional)
- positive msg
- negative msg

# usage
Use with busted like any other assert statement.
```lua
assert.bulk(table())
assert.not_bulk(77)
```
