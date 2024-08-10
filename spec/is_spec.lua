describe("is", function()
  local meta, is, cache, filez
  setup(function()
    meta = require "meta"
    cache = meta.cache
    is = meta.is

filez = [[
lua
lua/meta
lua/meta/math.lua
lua/meta/cache.lua
lua/meta/seen.lua
lua/meta/string.lua
lua/meta/init.lua
lua/meta/boolean.lua
lua/meta/clone.lua
lua/meta/is.lua
lua/meta/lua_version.lua
lua/meta/is
lua/meta/is/callable.lua
lua/meta/is/similar.lua
lua/meta/is/typed.lua
lua/meta/is/values.lua
lua/meta/is/factory.lua
lua/meta/is/empty.lua
lua/meta/is/type.lua
lua/meta/is/table.lua
lua/meta/no.lua
lua/meta/path.lua
lua/meta/loader.lua
lua/meta/proxy.lua
lua/meta/assert
lua/meta/assert/callable.lua
lua/meta/assert/init.lua
lua/meta/assert/module_name.lua
lua/meta/assert/values.lua
lua/meta/assert/factory.lua
lua/meta/assert/loader.lua
lua/meta/assert/type.lua
lua/meta/assert/z.lua
lua/meta/assert/ends.lua
lua/meta/type.lua
lua/meta/mt.lua
lua/meta/module.lua
lua/meta/require.lua
lua/meta/table.lua
spec/cache_spec.lua
spec/module_spec.lua
spec/methods_spec.lua
spec/submodules_spec.lua
spec/string_spec.lua
spec/is_spec.lua
spec/no_spec.lua
spec/seen_spec.lua
spec/computed_spec.lua
spec/loader_spec.lua
spec/mt_spec.lua
spec/require_spec.lua
spec/path_spec.lua
spec/memoize_spec.lua
spec/table_spec.lua
spec/type_spec.lua
spec/boolean_spec.lua
spec/math_spec.lua
spec/clone_spec.lua
spec/scan_spec.lua
spec/subfiles_spec.lua
spec/subdirs_spec.lua
testdata
testdata/req
testdata/req/message.lua
testdata/req/init.lua
testdata/req/dot
testdata/req/dot/init.lua
testdata/req/dot/ok.message.lua
testdata/req/ok
testdata/req/ok/message.lua
testdata/req/ok/init.lua
testdata/test
testdata/init1
testdata/init1/all
testdata/init1/all/init.lua
testdata/init1/init.lua
testdata/init1/dirinit
testdata/init1/dirinit/init.lua
testdata/init1/file.lua
testdata/init1/dir
testdata/init1/dir/.keep
testdata/init1/filedir
testdata/init1/filedir/.keep
testdata/init1/all.lua
testdata/init1/filedir.lua
testdata/empty
testdata/init2
testdata/init2/all
testdata/init2/all/init.lua
testdata/init2/init.lua
testdata/init2/dirinit
testdata/init2/dirinit/init.lua
testdata/init2/file.lua
testdata/init2/dir
testdata/init2/dir/.keep
testdata/init2/filedir
testdata/init2/filedir/.keep
testdata/init2/all.lua
testdata/init2/filedir.lua
testdata/webapi2
testdata/webapi2/x
testdata/webapi2/x/k.lua
testdata/webapi2/x/a.lua
testdata/webapi2/init.lua
testdata/webapi2/b.lua
testdata/webapi2/y
testdata/webapi2/y/g.lua
testdata/webapi2/y/a.lua
testdata/webapi2/a.lua
testdata/webapi2/z
testdata/webapi2/z/a.lua
testdata/lt
testdata/lt/message.lua
testdata/lt/init.lua
testdata/lt/dot
testdata/lt/dot/init.lua
testdata/lt/dot/ok.message.lua
testdata/loader
testdata/loader/noinit
testdata/loader/noinit/message.lua
testdata/loader/noinit/ok.message.lua
testdata/loader/noinit/noinit2
testdata/loader/noinit/noinit2/message.lua
testdata/loader/init.lua
testdata/loader/failed.lua
testdata/loader/dot
testdata/loader/dot/init.lua
testdata/loader/dot/ok.message.lua
testdata/loader/ok
testdata/loader/ok/message.lua
testdata/loader/ok/init.lua
testdata/loader/meta_path
testdata/loader/meta_path/ok
testdata/loader/meta_path/ok/init.lua
testdata/dirs
testdata/dirs/a
testdata/dirs/a/a
testdata/dirs/a/a/a
testdata/dirs/a/c
testdata/dirs/a/c/c
testdata/dirs/a/b
testdata/dirs/a/b/b
testdata/dirs/c
testdata/dirs/c/a
testdata/dirs/c/a/a
testdata/dirs/c/c
testdata/dirs/c/c/c
testdata/dirs/c/b
testdata/dirs/c/b/b
testdata/dirs/b
testdata/dirs/b/a
testdata/dirs/b/a/a
testdata/dirs/b/c
testdata/dirs/b/c/c
testdata/dirs/b/b
testdata/dirs/b/b/b
testdata/init4
testdata/init4/all
testdata/init4/all/init.lua
testdata/init4/init.lua
testdata/init4/a
testdata/init4/a/y.lua
testdata/init4/a/x.lua
testdata/init4/dirinit
testdata/init4/dirinit/init.lua
testdata/init4/file.lua
testdata/init4/dir
testdata/init4/dir/.keep
testdata/init4/filedir
testdata/init4/filedir/.keep
testdata/init4/all.lua
testdata/init4/filedir.lua
testdata/init4/b
testdata/init4/b/y.lua
testdata/init4/b/x.lua
testdata/webapi
testdata/webapi/x
testdata/webapi/x/k.lua
testdata/webapi/x/a.lua
testdata/webapi/init.lua
testdata/webapi/b.lua
testdata/webapi/y
testdata/webapi/y/g.lua
testdata/webapi/y/a.lua
testdata/webapi/a.lua
testdata/webapi/z
testdata/webapi/z/a.lua
testdata/ok
testdata/ok/message.lua
testdata/ok/init.lua
testdata/ok/dot
testdata/ok/dot/init.lua
testdata/ok/dot/ok.message.lua
testdata/init3
testdata/init3/c.lua
testdata/init3/init.lua
testdata/init3/d.lua
testdata/init3/b.lua
testdata/init3/a.lua
testdata/preload
testdata/preload/noinit
testdata/preload/noinit/message.lua
testdata/preload/noinit/ok.message.lua
testdata/preload/init.lua
testdata/preload/dot
testdata/preload/dot/init.lua
testdata/preload/dot/ok.message.lua
testdata/preload/ok
testdata/preload/ok/message.lua
testdata/preload/ok/init.lua
testdata/noloader
testdata/noloader/init.lua
testdata/files
testdata/files/a
testdata/files/a/a.lua
testdata/files/i
testdata/files/i/c.lua
testdata/files/i/a
testdata/files/i/a/init.lua
testdata/files/i/a/a.lua
testdata/files/i/c
testdata/files/i/c/c.lua
testdata/files/i/c/init.lua
testdata/files/i/c/b.lua
testdata/files/i/c/a.lua
testdata/files/i/d.lua
testdata/files/i/b
testdata/files/i/b/init.lua
testdata/files/i/b/b.lua
testdata/files/i/b/a.lua
testdata/files/c
testdata/files/c/c.lua
testdata/files/c/b.lua
testdata/files/c/a.lua
testdata/files/b
testdata/files/b/b.lua
testdata/files/b/a.lua
testdata/failed
testdata/failed/message.lua
testdata/failed/init.lua
any.com/pack/googl.com/UNGIgigi_-0123456789
]]

  end)
  it("std", function()
    assert.is_true(is.loader(meta))
    assert.equal(is, is('meta'))
  end)
  describe("path values", function()
    it("callable", function()
      assert.is_callable(is.loader)
--      assert.is_callable(is.indexable)
    end)
--    it("tostring", function()
--      assert.equal('net/ip', tostring(is.net.ip))
--    end)
  end)
  it("call", function()
    assert.is_true(is.callable(string.format))
    assert.is_true(is.cache(cache.loaded))
    assert.equal('table', type(meta))
  end)
  it("tonumber", function()
    assert.equal(0, tonumber(0))
    assert.equal(0, tonumber('0'))
    assert.equal(nil, tonumber(''))
    assert.equal(nil, tonumber('ui'))
    assert.equal(nil, tonumber(nil))
  end)
--  it("nil", function()
--    assert.is_true(is['nil']())
--    assert.is_true(is['nil'](nil))
--    assert.is_true(is.Nil(nil))
--    assert.is_true(is.null(nil))
--    assert.is_true(is.null())
--  end)
--  it("number", function() assert.is_true(is.number(7)) end)
--  it("string", function() assert.is_true(is.string("a")) end)
--  it("file", function() assert.is_file(io.stdin) end)
--  it("table", function() assert.is_true(is.table({88, 99})) end)
  it("table", function() assert.is_true(is.table({88, 99})) end)
--  it("boolean", function() assert.is_true(is.boolean(true)) end)
--  it("func", function()
--    assert.is_true(is.func(table.remove))
--    assert.is_true(is['function'](table.remove))
--  end)
  it("callable", function()
    assert.is_true(is.callable(table.remove))
    assert.is_true(is.callable(table))
    assert.is_true(is.callable(meta.loader))

    assert.is_truthy(is.table.callable(table))
    assert.is_truthy(is.table.callable(meta.loader))
  end)
--  it("iterable", function()
--    assert.is_true(is.iterable(table()))
--    assert.is_true(is.iterable(meta.loader))
--  end)
  it("indexable", function()
    assert.is_true(is.mt.__index(table))
    assert.is_true(is.mt.__index(meta))
  end)
  it("loader", function()
    assert.is_callable(is.loader)
    assert.not_loader({})
    assert.not_loader(true)
    assert.not_loader(string.upper)
    assert.loader(meta)
    assert.loader(meta.loader)
  end)
--[[
  it("require", function()
    assert.is_table(is)
    assert.not_nil(is.integer)
    assert.callable(is.integer)
    assert.truthy(is.integer(77))
  end)
--]]
  it("is.__unm", function()
    assert.is_function(is.similar)
--    assert.is_function(-(is.similar))
  end)
  it("typed", function()
    assert.equal('meta/loader', meta.type(meta.loader))

    assert.type('meta/loader', meta.loader)
    assert.factory(meta.loader)

    assert.factory(meta.loader)
--    assert.not_instance(meta.loader)
    assert.equal('meta/loader', meta.type(meta.mt(meta.loader)))

    assert.equal(meta, require('meta'))
    assert.equal(require('meta'), require('meta'))
    assert.type('meta', meta)
--    assert.not_instance(meta)
    assert.factory(meta)

    assert.equal('meta', cache.type[meta])
    assert.equal('meta', cache.type['meta'])

    assert.equal('meta', meta.type(meta))
    assert.equal('meta/loader', meta.type(meta.mt(meta)))

    assert.type('meta/module', meta.module)
--    assert.not_instance(meta.module)
    assert.factory(meta.module)
    assert.equal('meta/module', meta.type(meta.module))

    local mm = meta.module('meta')
    assert.type('meta/module', mm)
--    assert.instance(mm)
    assert.not_factory(mm)
    assert.type('meta/module', mm)
  end)
  it("is.module_name", function()
    assert.module_name('assd-qq')
    assert.module_name('assd.com/qqq/www')
    assert.module_name('assd.com.qqq.www')
    assert.not_module_name('assd.com.qqq.www*')

    for it in filez:rstrip("\n"):gsplit("\n") do assert.module_name(it) end
    for _,it in pairs(filez:rstrip("\n"):split("\n")) do assert.module_name(it) end
  end)
  it("is.has_value", function()
    assert.not_has_value('a', {})
    assert.not_has_value('a', {'b'})
    assert.has_value('a', {'a'})
    assert.has_value('a', {'b', 'a'})
    assert.has_value('a', {'a', 'b'})
  end)
  it("is.has_key", function()
    assert.not_has_key('a', {})
    assert.not_has_key('a', {b=true})
    assert.has_key('a', {a=true})
    assert.has_key('a', {b=true, a=true})
    assert.has_key('a', {a=true, b=true})
  end)
  it("is.values", function()
    assert.not_values({'a'}, {})
    assert.not_values({'a'}, {'b'})
    assert.values({}, {})
    assert.values({'a'}, {'a'})
    assert.values({'a', 'b'}, {'b', 'a'})
    assert.values({'a', 'b'}, {'a', 'b'})
  end)
  it("is.keys", function()
    assert.not_keys({'a'}, {})
    assert.not_keys({'a'}, {b=true})
    assert.keys({}, {})
    assert.keys({'a'}, {a=true})
    assert.keys({'a', 'b'}, {b=true, a=true})
    assert.keys({'a', 'b'}, {a=true, b=true})
  end)
end)
