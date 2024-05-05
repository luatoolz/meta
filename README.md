# lua meta methods library
set of meta methods, most useful for `lua-t` lirary
- support `require` module name with dots: `_ = require "t/seo/google.com"`
- relative `require`:
```lua
-- for current module use ... (this works only inside a module)
local require = require "meta.require"(...)
local x = require ".submodule"
```
- recursive autoloader (default loader without `init.lua` created, nice for hier)
- match and iterate loaded submodules: ex. `t.seo["google.com"]`, `for k,v in pairs(t.seo)`, to iter all available need preload
- module path normalizing (`t.net.ip` -> `t/net/ip`), require() works using any format
- `searcher` injected as #1 module searcher (to `package.searchers`)
- instance/type meta methods manipulations

## meta
- `loader`: recursive auto loader, but lazy by default
- `memoize`: memoize front, supports function / closure / `mt.__call`
- `methods` + `clone`: extract __* metamethods, useful for copying .mt (for ~recursive metatables) and code reuse
- `computed`: like js computed object, effective for data structures fast defining

## more info
- all loaders have same type (mt) and use cache to keep its module name + other params
- the reason is to keep only actual (loaded) submodules in loader object itself (and all available if case of preload)
- users may rely on `pairs(loader(...))` working in all lua versions
- iterating loader skips `init.lua` due to `net/init.lua` loads as `require "net"`, which differ nesting level from `require "net/ip"` loading `net/ip.lua`
- each `meta.*` function implemented as standalone .lua callable considering same idea for loader iterations + allowing to use standalone calls, if needed
- it is possible to add module functions to loader as metamethods (`__call` / `__tostring` / etc), to make some static object

## luarocks
```sh
luarocks install --server=https://luarocks.org/dev meta
```

## depends
- `lua5.1`
- `paths`
- `compat53`

## test depends
- `busted`
