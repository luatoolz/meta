# lua meta methods library
Core meta methods to easy define typed lib (see `t` library for live example).
The heart of a module is auto-loader `meta.loader` with its `meta.module` properties.
Library does define some API, but is more focused to define key conventions for derived libs, objects and code.

- recursive autoloader like `t.is.callable`, `t.net.ip` with natural nesting
- support `require` module name with dots: `require "t/seo/google.com"`
- type caching with natural naming: `meta.loader`, `t.storage.mongo`, `is.match.xxx`
- `meta.is` pluggable matcher/tester with multipath modules lookups
- set of conventions valid for all complex object types
  - handler assigning
  - filtering, mapping, searching
  - iterating
  - add/sub/concat/data assigning
  - properties/config defining
  - autocaching with configurations, editing, objects auto-creation and more
  - order of meta methods, functions resolving
  - computable lazy on-demand fields
  - data linking
  - default type casting definitions
- these conventions work for basic types:
  - `meta.loader`: autoloader, supports children auto-saving, preloading, lookups, handler transforming, mass operations
  - `meta.module`: every module property is here as computed/computable field, like all loader functions as module
  - `meta.cache`: parametrized/configurable cache tree to keep instances, mts, module names, paths, dirs, files, etc
  - `meta.is`: pluggable lazy matcher for everything, just few examples:
    - `is.callable`: function or table+mt.__call
    - `is.file`, `is.dir`: suitable for filter/map/mass actions: table() % is.file, table() % is.dir
    - `is.like`: types comparing
    - `is.match.basename`: `string.matcher` comparator
  - `meta.type`: get instance type name like `meta/is/loader`, `meta/is/callable`
    - dots allowed in type name, so `meta/assert.d` is valid name using `assert.d` as id
      - `.d` convention: `meta:init(handler)` for `init.d` to preload all submodules calling handler
  - `meta.table`: tables function sets valid for 'any-abstract-table'
  - `meta.wrapper`: loader wrapper without mandatory cache/naming supporting its own pluggable handlers
  - `meta.seen`: addon for indexed modules to make uniq
  - `meta.log`: logging + reporting/exception control
  - and even `meta.string` with matcher convention set:
    - `string.matcher`: creates and saves matcher func for pattern
    - `string.gmatcher`: same for gmatch operation
    - `string.splitter`: splitting string to table
    - `string.stripper`: strip
    - `string.joiner`: join strings arrays
  - `table` universal object interface
    - `table.map` as `*` operation
    - `table.filter` as `%` operation
    - linking/sourcing/plugging as `^` operation
    - special (config/child/setting) as `/` operation
  - meta methods/optional conventions:
    - `__iter`: stateful function iterator (note: skips `init.lua`)
    - `__item`: embedded object type hint
    - `__preserve`: preserve hint for map/filter/mass operations
    - `__export`: default export function to plain lua tables, userdata suitable
    - `__array`: boolean: hint to containers like arrays, sets, lists, etc
    - `__pairs`: using and respecting
    - `__name`: sometimes is convinient to use for module names, mostly for debugging/informational purposes
    - default object casting functions
      - `__tonumber`
      - `__toboolean`
  - multi module roots (assuming to have same structure and conventions):
    - `meta.is`: looks up plugins in all roots
    - type name caching for roots and their childs
    - search order is repeatable

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
