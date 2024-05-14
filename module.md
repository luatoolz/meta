
```lua
meta.module (
  - path    [ ?.lua ?/init.lua ]  - path of lua file
  - name    [ meta/loader ]       - normalized name
  - origin  [ meta.loader ]       - name as originally provided
  - dir     [ lua/meta ]          - relative module directory
  - loader  [ { lua_table } ]     - loader lua table
)
meta.loader(
  - 
)
```

{
  .name         meta                          meta/loader             meta/loader         - normalized
  .origin       meta                          meta/loader             meta.loader         - origin

  .path.file    [ meta.lua, meta/init.lua ]   meta/loader/init.lua    meta/loader.lua     - relative to [ base module, searcher ]
  .path.dir     [ nil, meta ]                 meta/loader             meta/loader         - relative to [ base module, searcher ]
  .pkgpath      

  .basename     meta                          loader                  loader              - subkey, but main for .root
  .basedir      nil                           meta                    meta                - base module, but nil for .root
  .isroot       true                          false                   false               - .root

  .loader       {__indexed}                   ---                     ---                 - lua object with __index metamethod, defined only for dirs
  .lua_code     package.loaded                ---                     ---                 - object returned by module, cached by lua subsystem, could be nil
  .lua_type     type(.lua_code)               ---                     ---                 - type of it, could be nil

  .ok           true                          true                    false               - .lua load status
  .error        nil                           nil                     string              - load error text


  .indexable    if .lua_type == table.__index [ function, table ]                         - could be dynamic
  .iteratable   if .lua_type == table,        or __pairs, or __iter defined               - usually also indexable, should collect
  .callable     if .lua_type == [ function, table.__call ]                                - function often seen in t.is, table.__call is often self:new(...) or builder/static/singleton
  .isloader     if .lua_type( .lua_code) == .loader                                       - .loader object defined in init.lua and returned as .lua_code

==

- if .isroot=true
  .path.file        is possible both    [  ?.lua  ?/init.lua ]
  .path.dir         is possible         [  true  false ]
  .name             single word, no delimeters
  .basename         could contain '.'   [ google.com bing.com ]
  .basedir          if .isroot -> single word, no delimeters   but if .notroot -> could contain dots


- entry points:
  meta.loader() == meta()
  searcher for  [ require, prequire ] ++ caching (mainly external require(...) calls)
  require "basedir." + require ".subkey", + prequire

  create object types: meta.computed, meta.clone, meta.loader, meta.memoize
  much better to create one common object type:
    - can use all metas - memoize, computed, loader
    - can inherit .mt

==
  type features:
    - defaults, caches, params + type arguments, names -- as proxy object

  field - atomic type --> field of object  + methods --> field usage + import/export
  lists == many of same type, 
  complex == contains/structures field objects, have 

  conv/recode -- 

}

object types
{
  .mt           instance mt
  + arrays, lists (ordered maps), sets, maps        +params: item types, plural types, item==plural cache
  + complex objects, containings other objects

  backed by: db, caches, kv
    object = record
    set == cache [ redis, nginx, file ]
    array/lists == records

  conv/recode to/from
    formats: json, yml, xml, html

  object links/connections
    key fields, select/filter rules
    indexes
    limits

  set operation
    attr / flag / mark
    set execution
    filtering / reducing
    transforming

  saving / logging

  kind
  nature
  sort
  variety
  class
  group
  set
  species
  family
  order

  batch, part, match, run, round
  gang, line, installment
  side,hnd, hind, camp, way too much
  aspect
  base, basis, reason, bottom, ground, footing, authority
  establish, evidence, root, substructure, seat, account, score, cap
  cargo, carrier, 
  trunk, boot, pipe, load, bulk, burden
  size, volume, scale, mass, body, holding, content, drop
  participant, member, taker, holder, contributor, sharer, initiate

  condition, quality, manner, design
  form, pattern, rank
  model, line, generation, cast, entity, bunch
  sign, symbol, emblem, digit
  print, publishб sort, wide, way, sample, piece, standard
  paradigm, representetive, norm


  definition, advance, headaway, formalize, promise, package
  specification, operation, composition, consist, sequence
  object
  facility
  subject
  objective
  entity
  operand
  federation
  setup
  mastering
  acjquire
  pickup
  calc, compute
  prescribe
  derivation
  predict
  ratio, relation, correlation, correspondence, interrelation
  connection, attaching, joining, affiliation, inclusion, apposition, incorporation
  engagement, obligation, commitment, insertion
  occupation, case, matter, point, offense, action, point, responsibility, deal, venue
}
