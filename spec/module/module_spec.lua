describe('module', function()
  local tuple, call, mcache, iter
  local meta, module, loader
  setup(function()
    meta    = require 'meta'
    tuple   = require 'meta.tuple'
    iter    = require 'meta.iter'
    call    = require "meta.call"
    mcache  = require 'meta.mcache'

    module  = require 'meta.module'
    loader  = require 'meta.loader'

    _ = module('testdata') ^ true
    _ = iter
  end)
  teardown(function()
    module  = require 'meta.module'
    _ = module('testdata') ^ false
  end)
  it("self", function()
    assert.not_equal(module, module('meta.module'))
    assert.is_nil(module(nil))
    assert.is_nil(module(''))
    assert.truthy(module.pkgdirs/'testdata')

    assert.equal(module, require('meta.module'))
    assert.equal(module, module('meta.module').loaded)
    assert.equal(module, module('meta/module').loaded)

    assert.equal(module, require('meta/module'))
    assert.equal(module, meta.module)
  end)
  it("meta", function()
    assert.is_table(module)
    local m = module('meta')
    assert.is_table(m)
    assert.equal('meta', m.name)
  end)
  it("searcher values always same", function()
    local searcher, load = module.search, module.loadproc
    assert.is_function(searcher)

    assert.equal('meta.iter', module('meta.iter').node)
    assert.equal('meta.iter', module('meta/iter').node)

    assert.equal(module('meta.iter').name, module('meta/iter').name)
    assert.equal(searcher('meta/iter'), searcher('meta.iter'))
    assert.ends('lua/meta/iter.lua', searcher('meta/iter'))
    assert.ends('lua/meta/iter.lua', searcher('meta.iter'))

    assert.equal(module('meta.iter'), module('meta/iter'))
    assert.is_true(rawequal(module('meta.iter'), module('meta/iter')))

    assert.equal(load('meta.iter'), module('meta.iter').loadfunc)
    assert.equal(load('meta/iter'), module('meta/iter').loadfunc)

    _ = load('meta.iter')
    _ = load('meta/iter')

    require 'meta.iter'

    assert.truthy(package.loaded['meta.iter'])

    assert.truthy(package.loaded['meta.iter'])
    assert.equal(load('meta.iter'), module('meta.iter').loadfunc)
    assert.falsy(package.loaded['meta/iter'])
    assert.is_true(rawequal(module('meta.iter'), module('meta/iter')))

    assert.equal(load('meta.iter'), module('meta.iter').loadfunc)
    assert.equal(load('meta/iter'), module('meta/iter').loadfunc)
    assert.equal(load('meta/iter'), module('meta.iter').loadfunc)
    assert.equal(load('meta.iter'), module('meta/iter').loadfunc)

    require 'meta/iter'

    assert.truthy(package.loaded['meta.iter'])
    assert.truthy(package.loaded['meta/iter'])
    assert.equal(package.loaded['meta.iter'], package.loaded['meta/iter'])

    assert.equal(load('meta/iter'), module('meta/iter').loadfunc)
    assert.equal(load('meta.call'), module('meta.call').loadfunc)
    assert.equal(load('meta.table'), module('meta.table').loadfunc)

    assert.equal(load('meta.iter'), module('meta.iter').loadfunc)
    assert.equal(load('meta/call'), module('meta.call').loadfunc)
    assert.equal(load('meta/table'), module('meta.table').loadfunc)

    assert.equal(load('meta/iter'), module('meta/iter').loadfunc)
    assert.equal(load('meta/call'), module('meta/call').loadfunc)
    assert.equal(load('meta/table'), module('meta/table').loadfunc)

    assert.equal(load('luassert'), module('luassert').loadfunc)
    assert.is_nil(load('noneexistent'))
  end)
  describe("new", function()
    it("__concat", function()
      assert.equal(module, module+nil)
      assert.equal(module('meta'), module('meta')..nil)
      assert.equal(module('meta'), module('meta')..'')

      assert.equal(module('meta'), module..'meta')
      assert.equal(module('meta'), module..module('meta'))

      assert.equal(module('meta.mcache'), module('meta')..'mcache')
      assert.equal(module('meta/mcache'), module('meta')..'mcache')
      assert.equal(module('meta/mcache'), module('meta')..{'mcache'})
      assert.equal(module('meta/mcache'), module('meta')..tuple('mcache'))

      assert.equal(module('testdata.loader2'), module('testdata')..'loader2')
      assert.equal(module('testdata.loader2'), module..'testdata.loader2')
      assert.equal(module('testdata.loader2'), module..'testdata/loader2')

      assert.equal(module('testdata/assert.d'), module('testdata')..'assert.d')
      assert.equal(module('testdata/assert.d'), module..'testdata/assert.d')

      assert.equal(module('testdata/loader2'), module..(loader('testdata.loader2')))
      assert.equal(module('testdata/loader2'), module..(loader('testdata/loader2')))

      assert.equal(module('testdata/loader2'), module..(mcache.module/loader('testdata.loader2')))
      assert.equal(module('testdata/loader2'), module..(mcache.module/loader('testdata/loader2')))

      assert.equal(module('testdata/loader2'), module..require('testdata.loader2'))
      assert.equal(module('testdata/loader2'), module..require('testdata/loader2'))
    end)
  end)
  it("#module", function()
    assert.equal(1, #module('meta'))
    assert.equal(2, #module('meta.module'))
    assert.equal(2, #module('meta/module'))
  end)
  it("meta.loader", function()
    local m = module('meta.loader')
    assert.is_table(m)
    assert.equal('loader', m.id)
    assert.equal('loader', m.class)
    assert.is_nil(m.isdir)
  end)
  it("module.noneexistent", function()
    assert.is_table(module('noneexistent'))
    assert.is_nil(module('noneexistent').ok)
  end)
  it("has", function()
    assert.truthy(module('meta').modz.loader)
    assert.truthy(module('testdata.init1').modz.file)
    assert.truthy(module('testdata.init1').modz.filedir)
    assert.falsy(module('testdata.init1').modz.fake)
    assert.falsy(module('testdata.init1').modz[''])
    assert.falsy(module('testdata.init1').modz[nil])
  end)
  it(".name", function()
    assert.equal('meta', module('meta').name)
    assert.equal('meta/loader', module('meta.loader').name)
    assert.equal('testdata/init1/file', module('testdata.init1.file').name)
    assert.equal('testdata/init1/dir', module('testdata.init1.dir').name)
    assert.equal('testdata/init1/dirinit', module('testdata.init1.dirinit').name)
    assert.equal('testdata/init1/filedir', module('testdata.init1.filedir').name)
    assert.equal('testdata/init1/all', module('testdata.init1.all').name)

    assert.equal('testdata/init2', module('testdata/init2').name)
    assert.equal('testdata/init2/file', module('testdata/init2.file').name)
    assert.equal('testdata/init2/dir', module('testdata/init2.dir').name)
    assert.equal('testdata/init2/dirinit', module('testdata/init2.dirinit').name)
    assert.equal('testdata/init2/filedir', module('testdata/init2.filedir').name)
    assert.equal('testdata/init2/all', module('testdata/init2.all').name)

    assert.equal('meta/assert', module('meta.assert').name)
  end)
  it(".file", function()
    assert.ends('meta/init.lua', tostring(module('meta').file))
    assert.ends('meta/loader.lua', tostring(module('meta.loader').file))
    assert.ends('testdata/init1/file.lua', tostring(module('testdata/init1/file').file))
    assert.equal(nil, module('testdata/init1/dir').file)
    assert.ends('testdata/init1/dirinit/init.lua', tostring(module('testdata/init1/dirinit').file))
    assert.ends('testdata/init1/filedir.lua', tostring(module('testdata/init1/filedir').file))
    assert.ends('testdata/init1/all.lua', tostring(module('testdata/init1/all').file))

    assert.ends('init2/init.lua', tostring(module('testdata.init2').file))
    assert.ends('init2/file.lua', tostring(module('testdata.init2.file').file))
    assert.is_nil(module('init2.dir').file)
    assert.ends('init2/dirinit/init.lua', tostring(module('testdata.init2.dirinit').file))
    assert.ends('init2/filedir.lua', tostring(module('testdata.init2.filedir').file))
    assert.ends('init2/all.lua', tostring(module('testdata.init2.all').file))
  end)
  it(".dir", function()
    assert.ends('meta', module('meta').dir)
    assert.is_nil(module('meta.loader').dir)
    assert.is_nil(module('testdata/init1/file').dir)
    assert.ends('testdata/init1/dir', module('testdata/init1/dir').dir)
    assert.ends('testdata/init1/dirinit', module('testdata/init1/dirinit').dir)
    assert.ends('testdata/init1/filedir', module('testdata/init1/filedir').dir)
    assert.ends('testdata/init1/all', module('testdata/init1/all').dir)

    assert.ends('testdata/init2', module('testdata.init2').dir)
    assert.ends('testdata/init2/dir', module('testdata.init2.dir').dir)
    assert.ends('testdata/init2/dirinit', (module('testdata.init2.dirinit') or {}).dir)
    assert.ends('testdata/init2/filedir', module('testdata.init2.filedir').dir)
    assert.ends('testdata/init2/all', module('testdata.init2.all').dir)
  end)
  it(".node", function()
    assert.equal('meta.is', module('meta.is').node)
    assert.equal('meta.is', module('meta/is').node)

    assert.equal('meta.is.toindex', module('meta.is.toindex').node)
    assert.equal('meta.is.pkgloaded', module('meta.is.pkgloaded').node)

    assert.equal('meta', module('meta').node)

    assert.equal('meta.module', module('meta.module').node)
    assert.equal('meta.loader', module('meta.loader').node)
  end)
  it(".root", function()
    assert.equal('meta', module('meta').root)
    assert.equal('meta', module('meta.loader').root)
    assert.equal('luassert', module('luassert').root)
    assert.equal('meta', module('meta.assert').root)
  end)
  describe('chain', function()
    it(".chained", function()
      _ = module ^ 'testdata'
      assert.is_true(module('meta').chained)
      assert.is_true(module('meta.loader').chained)
      assert.is_true(module('meta.assert').chained)
      assert.is_true(module('meta/assert').chained)

      _ = module('testdata') ^ false
      assert.is_nil(module('luassert').chained)
      assert.is_nil(module('testdata').chained)
      assert.is_nil(module('testdata.assert').chained)
      assert.is_nil(module('testdata/assert').chained)
      _ = module ^ 'testdata'
    end)
    it(".chainer", function()
      _ = module ^ 'testdata'
      assert.equal(table({'testdata','meta'}), table()..module.chain)
      assert.equal(module('testdata/init1/dirinit'), mcache.module/'testdata/init1/dirinit')
      assert.equal(module('testdata/init1/dirinit'), module('testdata').chainer/tuple.caller('init1/dirinit'))
      assert.equal(module('testdata/init1/dirinit'), module('testdata').chainer/tuple.concatter('init1/dirinit'))
      assert.equal(module('testdata/init1/dirinit'), (module('testdata').chainer*tuple.concatter('init1/dirinit')*'ok')[1])
      assert.equal(module('testdata/init1/dirinit'), (module('testdata').chainer*tuple.caller('init1/dirinit')*'ok')[1])

      assert.equal(module('meta/is/has/value').chloaded, module('testdata/is/has/value').chloaded)
      assert.equal(module('meta/is/has/value').load, (module('testdata').chainer*'loader')/tuple.getter('is/has/value'))
      assert.equal(module('meta/is/has/value').load, (module('testdata').chainer*'loader')/'is/has/value')

      assert.same(module('meta').chainer, table.reversed(module('testdata').chainer))
    end)
    it(".chmodz", function()
      _ = module ^ 'testdata'
      assert.is_nil(module('meta').modz.loader2)
      assert.equal('testdata/loader2/init.lua', module('meta').chmodz.loader2)
      assert.equal(module('meta').chmodz.loader2, module('testdata').modz.loader2)
    end)
    it(".chsubdirz", function()
      _ = module ^ 'testdata'
      assert.equal('loader2', module('meta').chsubdirz.loader2)
      assert.equal(module('meta').chsubdirz.loader2, module('testdata').chsubdirz.loader2)
    end)
    it(".chfile", function()
      _ = module('testdata') ^ false
      assert.equal(module('meta').file, module('meta').chfile)
      _ = module ^ 'testdata'
      assert.equal(module('meta').file, module('meta').chfile)
      assert.equal(module('testdata/loader2').file, module('meta/loader2').chfile)
      assert.equal(module('testdata/loader2').chfile, module('meta/loader2').chfile)
    end)
    it(".chdir", function()
      _ = module ^ 'testdata'
      assert.equal(module('testdata/loader2').dir, module('meta/loader2').chdir)
      assert.equal(module('testdata/loader2').chdir, module('meta/loader2').chdir)
    end)
    it(".chitems", function()
      _ = module ^ 'testdata'
      assert.truthy(module('meta').chsubdirz.loader2)
    end)
  end)
  it(".isroot", function()
    assert.is_true(module('meta').isroot)
    assert.is_nil(module('meta.loader').isroot)
    assert.is_nil(module('testdata/init1/file').isroot)
    assert.is_nil(module('testdata/init1/dir').isroot)
    assert.is_nil(module('testdata/init1/dirinit').isroot)
    assert.is_nil(module('testdata/init1/filedir').isroot)
    assert.is_nil(module('testdata/init1/all').isroot)

    assert.is_nil(module('init2').isroot)
    assert.is_nil(module('init2.file').isroot)
    assert.is_nil(module('init2.dir').isroot)
    assert.is_nil(module('init2.dirinit').isroot)
    assert.is_nil(module('init2.filedir').isroot)
    assert.is_nil(module('init2.all').isroot)
  end)
  it(".parent", function()
    assert.equal(module('meta'), module('meta.loader').parent)
    assert.equal(module('meta'), module('meta.loader').parent)
  end)
  it(".sub()", function()
    assert.same(module('meta/loader').name, (module('meta') .. 'loader').name)
    assert.equal(module('meta/loader').name, (module('meta') .. 'loader').name)
    assert.equal(module('meta/loader'), (module('meta') .. 'loader'))
    assert.equal(module('testdata/loader2/noneexistent'), (module('testdata/loader2') .. 'noneexistent'))

    assert.equal('meta/assert.d', tostring(module('meta/assert.d')))
    assert.equal(module('meta/assert.d'), module('meta')..'assert.d')
    assert.equal('meta/assert.d', tostring(module('meta')..'assert.d'))

    assert.equal('meta/assert.d', tostring(module('meta')(true, 'assert.d')))
    assert.equal('meta/assert.d', tostring(module('meta')('assert.d')))
  end)
  it(".d", function()
    assert.equal(module('meta/assert.d'), module('meta/assert').d)
    assert.equal(module('meta/assert.d').id, module('meta/assert').id)
    assert.equal(module('meta/assert.d').handler, module('meta/assert').handler)
  end)
  it("inherit options", function()
    local opts = {inherit=true, handler=type, callempty=true}
    local a = module('testdata/inhup') ^ opts
    local b = a..'b'

    assert.same(opts, a.opt)
    assert.equal(a.opt.inherit, b.opt.inherit)
    assert.equal(a.opt.callempty, b.opt.callempty)
    assert.same(opts, b.opt)
    assert.equal(a.opt.handler, b.opt.handler)
  end)
  it(".load ok and test mcache", function()
    local m = module('testdata/loader2/ok/message')
    assert.truthy(m.exists)
    assert.is_table(m.load)
    assert.is_nil(m.error)
    assert.equal('ok', m.get.data)
    assert.truthy(m.loaded)
  end)
  it(".load failed", function()
    local m = module('testdata/loader2/failed')
    assert.truthy(m.exists)
    call.protect = false;
    assert.has_error(function() return require(tostring(m)) end);
    call.protect = true
  end)
  it("loader", function()
    local mod = module('testdata/init1')
    assert.is_table(mod)
    assert.is_table(mod.loader)

    mod = module('testdata/init3')
    assert.is_table(mod)
    assert.is_table(mod.loader)

    local mod2 = mcache.module/mod.loader
    assert.truthy(mod2)
    assert.equal('testdata/init3',mod2.name)
    assert.same({ok='ok'}, mod.loader.a)
    assert.same({a={ok='ok'}, b={ok='ok'}, c={ok='ok'}, d={ok='ok'}}, mod.loader)
  end)
  it(".pkg", function()
    assert.equal(module('testdata/init1'), module:pkg('testdata/init1/file'))
    assert.is_nil(module:pkg('testdata/init1/dir'))

    assert.equal(module('testdata/init1/dirinit'), module:pkg('testdata/init1/dirinit'))
    assert.equal(module('testdata/init1/filedir'), module:pkg('testdata/init1/filedir'))
    assert.equal(module('testdata/init1/all'), module:pkg('testdata/init1/all'))

    assert.equal(module('testdata/init2'), module:pkg('testdata.init2'))
    assert.equal(module('testdata/init2'), module:pkg('testdata.init2.file'))
    assert.is_nil(module:pkg('testdata.init2.dir'))

    assert.equal(module('testdata/init2/dirinit'), module:pkg('testdata.init2.dirinit'))
    assert.equal(module('testdata/init2/filedir'), module:pkg('testdata.init2.filedir'))
    assert.equal(module('testdata/init2/all'), module:pkg('testdata.init2.all'))
  end)
  it("iter submodules", function()
    assert.equal(table({message='testdata/failed/message'}), module('testdata/failed')*tostring)
  end)
  it(".modz", function()
    assert.equal('lua/meta/is/init.lua', module('meta').modz.is)
    assert.equal('lua/meta/loader.lua', module('meta').modz.loader)
    assert.equal('lua/meta/assert.d/init.lua', module('meta').modz['assert.d'])

    assert.keys({'file', 'all', 'dirinit', 'filedir'}, module('testdata/init1').modz)
    assert.keys({'message', 'ok.message'}, module('testdata/loader2/noinit')*nil)
  end)
  it(".items", function()
    assert.same({dir='dir', file='file', all='all', dirinit='dirinit', filedir='filedir'}, module('testdata/init1').items)
    assert.keys({'noinit2', 'message', 'ok.message'}, module('testdata/loader2/noinit').items)
  end)
  it("__mul", function()
    assert.is_table((module*nil).meta)
    assert.is_table((module('meta')*nil).is)
  end)
  it("__div", function()
    assert.truthy(module('meta')/'iter')
  end)
  describe("cache", function()
    it("__div", function()
      assert.truthy(mcache)
      assert.truthy(mcache.module)

      local found = mcache.module/'meta.mcache'
      assert.truthy(found)
      assert.equal('module', getmetatable(found).__name)
      assert.equal(found, module('meta/mcache'))
      assert.equal(found, mcache.module/found)
      assert.equal(found, module('meta')..'mcache')
      assert.equal(found, (module('meta')%'mcache').mcache)

      local tl = require 'testdata.loader2'
      local m = mcache.module/'testdata.loader2'
      assert.truthy(m)
      assert.equal(m, mcache.module/tl)

      assert.equal(m, mcache.module/loader('testdata.loader2'))
      assert.equal(m, mcache.module/loader('testdata/loader2'))
    end)
  end)
end)