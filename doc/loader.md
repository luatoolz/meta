# meta.loader
Lua module autoloader. Allows recursive loading using regular Lua dir/file/module structure.

- path normalization: `meta.loader`, `meta/assert.d/bulk.lua`
- same cached object returned for alt named module load (`meta.loader` + `meta/loader` = same)
- recursive autoloader like `t.is.callable`, `t.net.ip` with natural nesting
- support `require` module name with dots: `require "t/seo/google.com"`
- object type caching with natural naming: `meta.loader`, `t.storage.mongo`, `is.match.xxx`
- pluggable modules sharing same hierarchy (see `meta.is` for examples)
- pluggable `*.d` convention (like `init.d` or `assert.d`)
- custom handler could be set for specific module or childs (see `meta.assert` for example)
- pure dirs/subdirs without `init.lua` accepted as containers by loader
- mass actions: filtering, mapping, searching (see `meta.is`, `meta.iter`)
- multi module roots from Lua pkgdirs
- loader chain (loading relative `env` module from `meta`, `t` or other different modules)
- relative chain object names (`meta.loader` -> `loader`)

## use meta.loader
```lua
local t = loader('t')                                 # main namespace
local env = t.env                                     # auto load env.lua module in `t` subdir
                                                      # t['env'], t('env')

-- iterating/listing/searching/manipulating
local modz = table.map(loader('testdata.files'),type) # {a='table', b='table', c='table', i='function'}
modz = loader('testdata.files')*type                  # same

-- use load handlers
local match = loader('t.matcher') ^ string.matcher    # new loader with handler
local match = t.matcher ^ function() ... end          # use if t/matcher/init.lua module is a loader

-- example: load matcher from .lua file in t/matcher  # return '([%w_%.-]+@[%w_%.-]+[%w])'
local email = match.email
local got = email(...)

local emails = table(...)*match.email                 # match emals from table
```

## object naming, caching and pathing
Module caching is done using `meta.mcache` module.
```lua
tostring(t.env)                                       # 'env' with root module name ('t') stripped

local mcache = require 'meta.mcache'
local instance = mcache.instance

local loader = require 'meta.loader'
local meta = loader('meta')                           # loader['meta'], loader.meta

local objname   = instance[meta]                      # 'meta'
local object    = t[objname]                          # meta
local typename  = mcache.mtype[object]                # 'loader'
```

Lua `table`, `function`, `userdata` and `CFunction` objects are cached. First instance cached. Only `table`/`userdata` object with metatables define type (metatables cached).
