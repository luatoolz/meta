describe("module.pkgdir", function()
  local meta, is, path, pkgdir, pkgdirs, seen
  setup(function()
    meta = require "meta"
    is = meta.is
    path = meta.path
    pkgdir = require "meta.module.pkgdir"
    pkgdirs = (table() .. package.path:gmatch('[^;]*')) * pkgdir
    seen = require 'meta.seen'
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(pkgdir))
    assert.truthy(is.callable(pkgdirs))
  end)
  describe("pkgdir", function()
    it("tostring", function()
      assert.equal('lua/?.lua', tostring(pkgdirs[1]))
      assert.equal('lua/?/init.lua', tostring(pkgdirs[2]))
    end)
    it("__index", function()
      assert.is_nil(pkgdirs[1].meta)
      assert.equal(path('lua/meta/loader.lua'), pkgdirs[1]['meta/loader'])
      assert.equal(path('lua/meta/module/pkgdir.lua'), pkgdirs[1]['meta/module/pkgdir'])

      assert.is_nil(pkgdirs[2]['meta/loader'])
      assert.equal(path('lua/meta/init.lua'), pkgdirs[2].meta)

      assert.equal('lua/meta/module/pkgdir.lua', tostring(pkgdirs[1]['meta/module/pkgdir']))
    end)
    it("__call", function()
--      assert.equal(path('lua/meta/init.lua'), pkgdirs[1]('meta/fn'))
    end)
    it("__div", function()
      assert.equal('lua/meta/init.lua', pkgdirs[2] / 'meta')
      assert.equal('lua/meta/mcache/init.lua', pkgdirs[2] / 'meta/mcache')

      assert.equal('lua/meta/init.lua', pkgdirs / 'meta')
      assert.equal('lua/meta/mcache/init.lua', pkgdirs / 'meta/mcache')
    end)
    it("__mul", function()
      assert.equal('lua/meta', tostring(pkgdirs[1]*'meta'))
      assert.equal('lua/meta', (pkgdirs*'meta'*seen()*tostring)[1])
    end)
    it("__mod", function()
--      assert.equal(table{null='lua/meta/fn/null.lua',noop='lua/meta/fn/noop.lua',['nil']='lua/meta/fn/nil.lua',
--        self='lua/meta/fn/self.lua',swap='lua/meta/fn/swap.lua',n='lua/meta/fn/n.lua',good='lua/meta/fn/good.lua',
--        args='lua/meta/fn/args.lua', mt='lua/meta/fn/mt.lua'},
      assert.equal('lua/meta/fn/swap.lua',
        ((table() .. (pkgdirs[1]%'meta/fn'))*function(v, ...) return tostring(v), ... end).swap)

      assert.equal(table({init='lua/meta/mcache/init.lua', root='lua/meta/mcache/root.lua'}), table()..pkgdirs[1]%'meta/mcache')
    end)
  end)
  it("pkgdirs", function()
    assert.equal(table {'lua/?.lua', 'lua/?/init.lua', '?.lua', '?/init.lua'}, (pkgdirs * tostring)[{1, 4}])
    assert.equal(table {path('lua/meta')}, pkgdirs[{1, 4}]*'meta' * seen())
    assert.equal('lua/meta/init.lua', pkgdirs[{1, 4}] / 'meta')
    assert.equal('lua/meta/loader.lua', pkgdirs / 'meta/loader')
    assert.equal('lua/meta/loader.lua', pkgdirs[{1, 4}] / 'meta/loader')
    assert.equal('lua/meta/module/pkgdir.lua', pkgdirs / 'meta/module/pkgdir')
  end)
  it("nil", function()
    assert.is_nil(pkgdir())
    assert.is_nil(pkgdir(nil))
    assert.is_nil(pkgdir(nil, nil))
    assert.is_nil(pkgdir(nil, nil, nil))
  end)
end)