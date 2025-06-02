describe("module.pkgdir", function()
  local is, pkgdir, pkgdirs, seen, module
  setup(function()
    require "meta"
    module  = require 'meta.module'
    is      = require 'meta.is'
    pkgdir  = require "meta.module.pkgdir"
    pkgdirs = require "meta.module.pkgdirs"
    seen    = require 'meta.seen'
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(pkgdir))
    assert.truthy(is.callable(pkgdirs))
  end)
  describe("pkgdir", function()
    it("tostring", function()
      assert.equal('lua/?.lua',                   tostring(pkgdirs[1]))
      assert.equal('lua/?/init.lua',              tostring(pkgdirs[2]))
    end)
    it("content", function()
      assert.equal('lua/?.lua',                   tostring(pkgdirs[1]))
      assert.equal('lua',                         tostring(pkgdirs[1][1]))  -- dir
      assert.equal('.lua',                        pkgdirs[1][2])  -- mask     []
      assert.equal('lua%/(.+)%.lua$',             pkgdirs[1][4])  -- matcher  [3] = function
      assert.equal('(.+)%.lua$',                  pkgdirs[1][7])  -- unmask   [5] = function

      assert.equal('lua',                         tostring(pkgdirs[2][1]))  -- dir
      assert.equal('lua/?/init.lua',              tostring(pkgdirs[2]))
      assert.equal('/init.lua',                   pkgdirs[2][2])  -- mask     []
      assert.equal('lua%/(.+)%/init%.lua$',       pkgdirs[2][4])  -- matcher  [3] = function
      assert.equal('(.+)%/init%.lua$',            pkgdirs[2][7])  -- unmask   [5] = function
    end)
    it("__index", function()
      -- returns valid module file source for pkgdir
      assert.is_nil(pkgdirs[1].meta)
      assert.is_nil(pkgdirs[1][module('meta')])
      assert.equal('lua/meta/is/init.lua',        pkgdirs[2]['meta/is'])
      assert.equal('lua/meta/is/init.lua',        pkgdirs[2][module('meta/is')])
      assert.equal('lua/meta/loader.lua',         pkgdirs[1]['meta/loader'])
      assert.equal('lua/meta/loader.lua',         pkgdirs[1][module('meta/loader')])

      assert.is_nil(pkgdirs[2]['meta/loader'])
      assert.equal('lua/meta/init.lua',           pkgdirs[2].meta)

      assert.equal('lua/meta/module/pkgdir.lua',  pkgdirs[1]['meta/module/pkgdir'])
    end)
    it("__call", function()
      -- called by __mod: self('lua/meta/loader.lua', 'lua/meta') --> ('lua/meta/loader.lua', 'loader')
      assert.equal('lua/meta/loader.lua',         select(1, pkgdirs[1]('lua/meta/loader.lua', 'lua/meta')))
      assert.equal('loader',                      select(2, pkgdirs[1]('lua/meta/loader.lua', 'lua/meta')))
      assert.equal('lua/meta/loader.lua',         select(1, pkgdirs[1]('lua/meta/loader.lua')))
      assert.equal('loader',                      select(2, pkgdirs[1]('lua/meta/loader.lua')))

      -- called by __mod: self('lua/meta/mcache', 'lua/meta')     --> ('lua/meta/mcache/init.lua', 'mcache')
      assert.equal('lua/meta/mcache/init.lua',    select(1, pkgdirs[2]('lua/meta/mcache', 'lua/meta')))
      assert.equal('mcache',                      select(2, pkgdirs[2]('lua/meta/mcache', 'lua/meta')))
      assert.equal('lua/meta/mcache/init.lua',    select(1, pkgdirs[2]('lua/meta/mcache')))
      assert.equal('mcache',                      select(2, pkgdirs[2]('lua/meta/mcache')))

      -- pkgdirs[1] contains 'lua/?.lua', so it didn't find valid path
      assert.is_nil(pkgdirs[1]('lua/meta'))
      assert.is_nil(pkgdirs[1](module('lua/meta')))

      -- pkgdirs[2] contains 'lua/?/init.lua', so it did job ok
      assert.equal('lua/meta/init.lua',           select(1, pkgdirs[2]('lua/meta', 'lua')))
      assert.equal('meta',                        select(2, pkgdirs[2]('lua/meta', 'lua')))
      assert.equal('lua/meta/init.lua',           select(1, pkgdirs[2]('lua/meta')))
      assert.equal('meta',                        select(2, pkgdirs[2]('lua/meta')))
    end)
    it("__div", function()
      -- first valid module file path
      assert.equal('lua/meta/init.lua',           pkgdirs[2] / 'meta')
      assert.equal('lua/meta/init.lua',           pkgdirs[2] / module('meta'))

      assert.equal('lua/meta/mcache/init.lua',    pkgdirs[2] / 'meta/mcache')
      assert.equal('lua/meta/mcache/init.lua',    pkgdirs[2] / module('meta/mcache'))
    end)
    it("__mul", function()
      -- returns module dir withing current pkgdir
      assert.equal('lua/meta',                    tostring(pkgdirs[1]*'meta'))
      assert.equal('lua/meta',                    tostring(pkgdirs[2]*'meta'))

      assert.equal('lua/meta',                    tostring(pkgdirs[1]*module('meta')))
      assert.equal('lua/meta',                    tostring(pkgdirs[2]*module('meta')))
    end)
    it("__mod", function()
      -- returns submodule list: pkgdirs[1]%'meta/is'
      assert.equal('lua/meta/is/mtname.lua',      (table()..pkgdirs[1]%'meta/is').mtname)

--      assert.same({mtname='lua/meta/rex/mtname.lua'}, table()..pkgdirs[1]%'meta/rex')
--      assert.same({mtname='lua/meta/rex/mtname.lua'}, table()..pkgdirs[1]%module('meta/rex'))

      assert.is_nil((table()..pkgdirs[1]%'meta')['assert.d'])
      assert.equal('lua/meta/assert.d/init.lua',  (table()..pkgdirs[2]%'meta')['assert.d'])

      assert.equal('lua/meta/is/paired.lua',      (pkgdirs%'meta/is').paired)
    end)
  end)
  describe("pkgdirs", function()
    it("value", function()
      assert.same({'lua/?.lua', 'lua/?/init.lua', '?.lua', '?/init.lua'}, (pkgdirs * tostring)[{1, 4}])
    end)
    it("__mul", function()
      -- dir list for module for all pkgdirs
      assert.equal('lua/meta',                    tostring((pkgdirs*'meta')[1]))
      assert.equal('lua/meta',                    tostring((pkgdirs*'meta')[2]))

      assert.same({'lua/meta'},                   pkgdirs[{1, 4}]*'meta'*tostring*seen())

      assert.equal('lua/meta/is',                 tostring((pkgdirs*'meta/is')[1]))
      assert.equal('lua/meta/is',                 tostring((pkgdirs*'meta/is')[2]))
    end)
    it("__div", function()
      -- first valid module path
      assert.equal('lua/meta/init.lua',           pkgdirs[{1, 4}] / 'meta')
      assert.equal('lua/meta/loader.lua',         pkgdirs[{1, 4}] / 'meta/loader')

      assert.equal('lua/meta/loader.lua',         pkgdirs/'meta/loader')
      assert.equal('lua/meta/module/pkgdir.lua',  pkgdirs/'meta/module/pkgdir')
      assert.equal('lua/meta/init.lua',           pkgdirs/'meta')
      assert.equal('lua/meta/mcache/init.lua',    pkgdirs/'meta/mcache')
    end)
    it("__mod", function()
      -- submodule list for all pkgdirs
      assert.equal('lua/meta/assert.d/init.lua',  (pkgdirs % 'meta')['assert.d'])
      assert.equal('lua/meta/is/init.lua',        (pkgdirs % 'meta').is)
      assert.equal('lua/meta/loader.lua',         (pkgdirs % 'meta').loader)
--      assert.same({mtname='lua/meta/rex/mtname.lua'}, pkgdirs%'meta/rex')
    end)
  end)
  it("nil", function()
    assert.is_nil(pkgdir())
    assert.is_nil(pkgdir(nil))
    assert.is_nil(pkgdir(nil, nil))
    assert.is_nil(pkgdir(nil, nil, nil))
  end)
end)