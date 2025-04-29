# lua meta library
Core meta methods to easy define typed lib (see `t` library for live example).

The heart of a module is auto-loader `meta.loader` with its `meta.module` properties. See `doc` dir for current docs (work in progress).

Library does define some API, but is more focused to define key conventions for derived libs, objects and code.

# luarocks
```sh
luarocks install --dev meta
```

# info
Main goals of this libray:
- autoloading
- pluggable interface
- common object interface to all and every interface
- common way to manipulate object containers
- all containers have set several conventions
  - `__iter`: v,k iteration of items
  - `table.map`: table() * tostring actions
  - `table.filter`: table() % is.string filtering
  - easy chaining like: this.pkgdirs%self.node%get.noinit*tostring
- set of user-types
- manage modules chaining namespaces

# current features
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
  - `meta.loader`: autoloading, autocaching, preloading, lookups, handlers, transforming, mass actions
  - `meta.module`: every module property is here as computed/computable field, like all loader functions as module
  - `meta.mcache`: parametrized/configurable cache tree to keep instances, mt, names, paths, dirs, files
  - `meta.iter`: iteration library
  - `meta.call`: call + coroutine + logging + reporting/exception control
  - `meta.is`: pluggable lazy matcher for everything, just few examples:
    - `is.callable`: function or table+mt.__call
    - `is.file`, `is.dir`: suitable for filter/map/mass actions: table() % is.file, table() % is.dir
    - `is.like`: types comparing
    - `is.match.basename`: `string.matcher` comparator
  - `meta.type`: get instance type name like `meta/is/loader`, `meta/is/callable`
    - dots allowed in type name, so `meta/assert.d` is valid name using `assert.d` as id
      - `.d` convention: `meta:init(handler)` for `init.d` to preload all submodules calling handler
  - `meta.table`: tables function sets valid for 'any-abstract-table'
  - `meta.seen`: addon for indexed modules to make uniq
  - and even `meta.string` with matcher convention set:
    - `string.matcher`: creates and saves matcher func for pattern
    - `string.gmatcher`: same for gmatch operation
    - `string.splitter`: splitting string to table
    - `string.stripper`: strip
    - `string.joiner`: join strings arrays
  - `table` universal object interface
    - `table.map` as `*` operation
    - `table.filter` as `%` operation
    - `table.div` as `/` operation
    - linking/sourcing/plugging as `^` operation
  - meta methods/optional conventions:
    - `__computed`/`__computable`: on-demand object property evaluation interface
    - `__iter`: stateful function iterator (note: skips `init.lua`)
    - `__mul`, `__mod`, `__div`, `__pow`: mass actions
    - `__next`: next() function for current object (alternative to `__pairs`)
    - `__preserve`: preserve hint for map/filter/mass operations
    - `__export`: default export function to plain lua tables, userdata suitable
    - `__array`: boolean: hint to containers like arrays, sets, lists, etc
    - `__pairs`: using and respecting
    - `__name`: sometimes is convinient to use for module names, mostly for debug
    - default object casting functions
      - `__tonumber`
      - `__toboolean`
  - multi module roots (assuming to have same structure and conventions):
    - `meta.is`: looks up plugins in all roots
    - type name caching for roots and their childs
    - search order is repeatable

## docs
- [meta.loader](doc/loader.md)
- [meta.iter](doc/iter.md)
- [meta.module.pkgdir](doc/pkgdir.md)
- [meta.call](doc/call.md)
- [meta.computed](doc/computable.md)
- [meta.is](doc/is.md)
- [meta.assert](doc/assert.md)

TODO:
- [meta.mcache](doc/mcache.md)
- [meta.module](doc/module.md)
- [meta.table](doc/table.md)

## depends
- `lua5.1`
- `paths`
- `compat53`
- `luassert`
- `lrexlib-pcre2`

## test depends
- `busted`

## status
Work in progress. Tested. Interfaces and api could be changed.
