# meta.module.pkgdir
Parsed Lua package.path entry object. `table()` of pkgdir containing paths looks like:
```lua
lua/?.lua
lua/?/init.lua
/usr/local/share/lua/5.1/?.lua
/usr/local/share/lua/5.1/?/init.lua
```

# __call
```lua
pkgdir('lua/?.lua') -> {a1,a3}
```

# __index
```lua
```


## list dirs for module (path objects), *tostring for strings
- `pkgdirs*'meta'*tostring`
```lua
lua/meta
lua/meta
/usr/local/share/lua/5.1/meta
/usr/local/share/lua/5.1/meta
```

## list module search dirs, add *seen() to dedupe
- `pkgdirs*'meta'*tostring*seen()`
```lua
lua/meta
/usr/local/share/lua/5.1/meta
```

## get module .lua file path
- lua init.lua path, by root name: `pkgdirs/'meta'`
```lua
lua/meta/init.lua
```
- lua both dir and file submodule .lua path: `pkgdirs/'meta/module/pkgdir'`, `pkgdirs/'meta/mcache'`
```lua
lua/meta/module/pkgdir.lua
lua/meta/mcache/init.lua
```


- convert .lua path to module name

    assert.equal('', table()..pkgdirs[5]%'meta/is')
