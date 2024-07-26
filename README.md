# lua meta methods library
set of meta methods to easy typed libs definition (see `t` library)
- support `require` module name with dots: `_ = require "t/seo/google.com"`
- recursive autoloader (default loader without `init.lua` created, nice for hier)
- match and iterate loaded submodules: ex. `t.seo["google.com"]`, `for k,v in pairs(t.seo)`, to iter all available need preload
- module path normalizing (`t.net.ip` -> `t/net/ip`) (`require` call accepts any format)
- `searcher` injected as #1 module searcher (to `package.searchers`)
- instance/type meta methods manipulations

## meta
- `loader`: recursive auto loader containing loaded/preloaded modules, lazy by default 
- `module`: module meta methods combined
- `computed`/`computable`: like js computed object, effective for fast defining of small but complex data structures
- `mt`/`mtindex`: get/set metatables helpers
- `cache`: proxy cache to keep mt cache consistent
- `chain`: complex object
- `clone`: mt cloning
- `methods`: recursive mt copying
- `memoize`: regular memoize
- `no`: helper library with most of implementation specific functions including loader
- `boolean`, `math`, `string`, `table`: regular memoize
- `path`: combined object/loader object path builder 

## more info
- all loaders have same type (mt) and use cache to keep its module name + other params
- the reason is to keep only actual (loaded) submodules in loader object itself (and all available if case of preload)
- users may rely on `pairs(loader(...))` working in all lua versions
- iterating loader skips `init.lua` due to `net/init.lua` loads as `require "net"`, which differ nesting level from `require "net/ip"` loading `net/ip.lua`
- use chaining to add module functions to loader as metamethods (`__call` / `__tostring` / etc), to make some useful static object

## luarocks
```sh
luarocks install --dev meta
```

## depends
- `lua5.1`
- `paths`
- `compat53`
- `luassert`

## test depends
- `busted`
