describe("is.module_name", function()
  local meta, is, test
  setup(function()
    meta = require "meta"
    is = meta.is
    test = {[true]=
[[lua
lua/meta
lua/meta/math.lua
lua/meta/mcache.lua
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
lua/meta/is/instance.lua
lua/meta/is/empty.lua
lua/meta/is/type.lua
lua/meta/is/table.lua
lua/meta/path.lua
lua/meta/loader.lua
lua/meta/proxy.lua
lua/meta/assert
lua/meta/assert/callable.lua
lua/meta/assert/init.lua
lua/meta/assert/module_name.lua
lua/meta/assert/values.lua
lua/meta/assert/instance.lua
lua/meta/assert/loader.lua
lua/meta/assert/type.lua
lua/meta/assert/z.lua
lua/meta/assert/ends.lua
lua/meta/type.lua
lua/meta/mt.lua
lua/meta/module.lua
lua/meta/require.lua
lua/meta/table.lua
spec/mcache_spec.lua
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
testdata/loader2
testdata/loader2/noinit
testdata/loader2/noinit/message.lua
testdata/loader2/noinit/ok.message.lua
testdata/loader2/noinit/noinit2
testdata/loader2/noinit/noinit2/message.lua
testdata/loader2/init.lua
testdata/loader2/failed.lua
testdata/loader2/dot
testdata/loader2/dot/init.lua
testdata/loader2/dot/ok.message.lua
testdata/loader2/ok
testdata/loader2/ok/message.lua
testdata/loader2/ok/init.lua
testdata/loader2/meta_path
testdata/loader2/meta_path/ok
testdata/loader2/meta_path/ok/init.lua
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
assd-qq
assd.com/qqq/www
assd.com.qqq.www
any.com/pack/googl.com/UNGIgigi_-0123456789]],
  [false]=
[[assd.com.qqq.www*
assd/com/qqq/../www
assd/com/qqq/../
assd/com/qqq/..
../assd/com/qqq/www
/../assd/com/qqq/www]],}

  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.module_name)
    assert.truthy(is.callable(is.module_name))
  end)
  it("positive", function()
    for it in test[true]:rstrip("\n"):gsplit("\n") do assert.is_true(is.module_name(it), it) end
  end)
  it("negative", function()
    for it in test[false]:rstrip("\n"):gsplit("\n") do assert.is_nil(is.module_name(it), it) end
  end)
  it("nil", function()
    assert.is_nil(is.module_name(nil))
    assert.is_nil(is.module_name())
  end)
end)