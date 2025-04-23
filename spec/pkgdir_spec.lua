describe("pkgdir", function()
  local meta, is, path, iter, pkgdir, pkgdirs, seen, selector
  setup(function()
    meta = require "meta"
    is = meta.is
    path = meta.path
    iter = meta.iter
    pkgdir = require "meta.module.pkgdir"
    pkgdirs = require "meta.module.pkgdirs"
    seen = require 'meta.seen'
    selector = meta.select
    _ = iter
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
    end)
    it("__div", function()
      assert.equal('lua/meta/init.lua', pkgdirs[2] / 'meta')
      assert.equal('lua/meta/mcache/init.lua', pkgdirs[2] / 'meta/mcache')
    end)
    it("__mod", function()
      assert.equal(table('lua/meta/module/pkgdir.lua'), table('lua/meta/module/pkgdir.lua') % pkgdirs[1][3])
      assert.equal(table(), table('lua/meta/module/pkgdir.lua') % pkgdirs[2][3])

      assert.equal(table('lua/meta/module/pkgdir.lua'), table('lua/meta/module/pkgdir.lua') % pkgdirs[1])
      assert.equal(table(), table('lua/meta/module/pkgdir.lua') % pkgdirs[2])

      assert.equal('lua/meta/module/pkgdir.lua', 'lua/meta/module/pkgdir.lua' % pkgdirs[1])
      assert.equal('lua/meta/module/pkgdir.lua', path('lua/meta/module/pkgdir.lua') % pkgdirs[1])

      assert.equal(table{null='lua/meta/fn/null.lua',noop='lua/meta/fn/noop.lua',['nil']='lua/meta/fn/nil.lua',
        self='lua/meta/fn/self.lua',swap='lua/meta/fn/swap.lua',n='lua/meta/fn/n.lua'},
        (table() .. (pkgdirs[1]%'meta/fn'))*function(v, ...) return tostring(v), ... end)

      assert.values({}, table() .. pkgdirs[2]%'meta/fn')

      assert.equal(table{null='lua/meta/fn/null.lua',noop='lua/meta/fn/noop.lua',['nil']='lua/meta/fn/nil.lua',
        self='lua/meta/fn/self.lua',swap='lua/meta/fn/swap.lua',n='lua/meta/fn/n.lua'},
        pkgdirs%'meta/fn'*function(v,...) return tostring(v), ... end)

      assert.truthy((pkgdirs%'meta/mcache').init)
      assert.equal(table{init = 'lua/meta/mcache/init.lua'}, pkgdirs%'meta/mcache'%function(v,k) if k=='init' then return v,k end end)
      assert.is_nil((pkgdirs%'meta/mcache'%function(v,k) if k~='init' then return v,k end end).init)

--      assert.equal('', pkgdirs)
_ = selector
    end)
--[[
    it("subdirs", function()
--      assert.equal('', pkgdirs*'meta/is'*selector.dirs*seen())
      assert.equal('', pkgdirs%'meta/is')
      assert.equal('', pkgdirs*tostring)
--      assert.equal('', pkgdirs%'testdata/init2')
      assert.equal('', pkgdirs*'meta'*seen()*selector.dirs)
    end)
--]]
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
