# lua meta methods library
set of meta methods, most useful for `lua-t` lirary
- support `require` module name with dots (`require "t/seo/google.com"`)
- recursive autoloader (default loader without `init.lua` created, nice for hier)
- module path normalizing (`t.net.ip` -> `t/net/ip`)
- instance/type meta methods manipulations

### meta
- `loader`: auto loader
- `memoize`: memoize front, supports function / closure / mt.__call
- `methods`: extract __* metamethods, useful for copying .mt (for ~recursive metatables)
- `computed`: like js computed object, effective for data structures fast defining

### luarocks
`luarocks install --server=https://luarocks.org/dev meta`

### depends
- `lua5.1`
- `compat53`
- `paths`

### test depends
- `busted`
