# meta.is
Pluggable type/multi tester.
```lua
local meta = loader('meta')                               # main loader namespace
local is = meta.is

_ = is.loader(meta)                                       # true
_ = is.loader(meta.loader)                                # true
_ = is.loader(string.lower)                               # falsy (nil)

-- use tester to filter table values
local _ = table('a', 5, true, 8, 'yes') % is.string       # {'a', 'yes'}
local _ = table('a', 5, true, 8, 'yes') % is.number       # {5, 8}
local _ = table('a', 5, true, 8, 'yes') * string.upper    # {'A', 'YES'}


-- some testers

is.alike
is.boolean
is.bulk
is.callable
is.complex
is.coroutine
is.CFunction
is.dir
is.empty
is.file
is.func
is.has
is.has_key
is.has_value
is.instance
is.integer
is.iterable
is.iter
is.keys
is.like
is.loader
is.lua_version
is.mappable
is.mcache
is.module
is.module_name
is.mtname
is.nonempty
is.number
is.path
is.pkgloaded
is.plain
is.root
is.similar
is.stringer
is.string
is.table
is.table_plain
is.tablex
is.toindex
is.thread
is.type
is.values
is.userdata

is.table.indexed
is.table.empty

is.match.basename
is.match.id
is.match.mtname

local has = is.has
has.key
has.keys
has.mt
has.tonumber
has.tostring
has.value
has.values
```

# add new tester
Just put your `tester.lua` to `is` subdir of any chained module/loader. `is.tester` should work immediately.
```lua
-- is/tester.lua
return function(x) return type(x)=='string' and #x or nil end
```
```lua
local is = require 'meta.is'
print(is.tester('bad option'))      # 10
print(is.tester(555))               # nil
```

# cross plug-in
Most interesting way of using testers is to add new specific testers at standard place for each new module in chain. See `t` submodules for live examples. Some names:
- `t.env`
- `t.format.html`
- `t.country`
- `t.driver.mongo`

Each module defines its own `is.*` testers keeping them in `t/is` subdir of its hier. All testers are available for usage as a result. Subpathiing and namespacing is also possible.