# meta.module.pkgdir
Create `table()` container. Actually, any iter/map/filter-able container should work. `table()`, `mcache`, etc.
This module actively use iter/mul/mod/div conventions of `meta` module.
```lua
local pkgdir = require 'meta.module.pkgdir'
local pkgdirs = (table()..package.path:gmatch('[^;]*'))*pkgdir

print(tostring(pkgdirs[1]))                           # 'lua/?.lua'
```

Parsed Lua package.path entry object. `table()` of pkgdir containing paths looks like:
```lua
lua/?.lua
lua/?/init.lua
/usr/local/share/lua/5.1/?.lua
/usr/local/share/lua/5.1/?/init.lua
```

## usage
- get default module file path
```lua
pkgdirs / 'meta'                                      # 'lua/meta/init.lua'
pkgdirs / 'meta/mcache'                               # 'lua/meta/mcache/init.lua'
```

- get module file path for submodule
```lua
print(pkgdirs[1]['meta/module/pkgdir'])               # 'lua/meta/module/pkgdir.lua'
```

- get module dirs from all pkgdirs
```lua
local seen = require 'meta.seen'                      # use seen() to rm dupes
pkgdirs*'meta.seen'                                   # {'lua/meta', 'lua/meta', ...}
pkgdirs*'meta.seen'*seen()                            # {'lua/meta', ...}

pkgdirs*'meta'*tostring*seen()                        # tostring to stringify meta.path object
-- content:
lua/meta
/usr/local/share/lua/5.1/meta
```

- list named submodules from all dirs
```lua
local ni = function(v,k) if k~='init' then return v,k end end

this.pkgdirs % 'meta/module' % ni                     # {chain='...', instance='...', ...}
                                                      # for both 'x/init.lua' and 'xxx.lua'
```

Returned values are typed objects `meta.path` or other appropriate.
