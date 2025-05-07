describe("path", function()
  local meta, is, path, iter, tuple
  setup(function()
    meta = require "meta"
    is = require 'meta.is'
    iter = require 'meta.iter'
    path = require 'meta.fs.path'
    tuple = iter.tuple
  end)
  it("meta", function()
    assert.callable(path)
    assert.equal('testdata/x', tostring(path('testdata/x')))
    assert.equal('/tmp', tostring(path('/tmp')))

    assert.equal(path, meta.fs.path)

    local id = require 'meta.mt.id'
    assert.callable(id)
    assert.equal(id(path('/tmp')), tostring(path('/tmp')))
  end)
  describe("new", function()
    it(".", function()
      assert.equal('', tostring(path('')))
      assert.equal(path(''), path(''))
      assert.equal(path(''), path('.'))
      assert.equal(path(''), path())
      assert.equal(path(''), path({}))
      assert.equal(path(''), path(tuple('')))
      assert.equal(path(''), path(tuple('.')))
      assert.equal(path(''), path(tuple()))
      assert.equal(path(''), path(tuple({})))
      assert.equal(path(''), path(tuple(path(''))))
    end)
    it("1", function()
      assert.equal('testdata', tostring(path('testdata')))
      assert.equal(path('testdata'), path('testdata'))
      assert.equal(path('testdata'), path('./testdata'))
      assert.equal(path('testdata'), path({'testdata'}))

      assert.equal(path('testdata'), path(tuple('testdata')))

      assert.equal(path('testdata'), path(path('testdata')))
      assert.equal(path('testdata'), path(tuple('testdata')))
      assert.equal(path('testdata'), path(tuple('./testdata')))
      assert.equal(path('testdata'), path(tuple({'testdata'})))
      assert.equal(path('testdata'), path(tuple(path('testdata'))))
    end)
    it("2", function()
      assert.equal('testdata/x', tostring(path('testdata/x')))
      assert.equal(path('testdata/x'), path('testdata/x'))
      assert.equal(path('testdata/x'), path('./testdata/x'))
      assert.equal(path('testdata/x'), path({'testdata/x'}))
      assert.equal(path('testdata/x'), path(tuple('testdata/x')))
      assert.equal(path('testdata/x'), path(tuple('./testdata/x')))
      assert.equal(path('testdata/x'), path(tuple({'testdata/x'})))
      assert.equal(path('testdata/x'), path({tuple('testdata/x')}))

      assert.equal(path('testdata/x'), path('testdata', 'x'))
      assert.equal(path('testdata/x'), path({'testdata'}, 'x'))
      assert.equal(path('testdata/x'), path('testdata', {'x'}))
      assert.equal(path('testdata/x'), path({'testdata', 'x'}))

      assert.equal(path('testdata/x'), path(path('testdata'), path('x')))
      assert.equal(path('testdata/x'), path(path('./testdata'), path('x')))
      assert.equal(path('testdata/x'), path(path({'testdata', 'x'})))
      assert.equal(path('testdata/x'), path({path('testdata'), path('x')}))

      assert.equal(path('testdata/x'), path('testdata', tuple('x')))
      assert.equal(path('testdata/x'), path(tuple('testdata'), 'x'))
      assert.equal(path('testdata/x'), path({'testdata'}, tuple('x')))
      assert.equal(path('testdata/x'), path(tuple('testdata'), {'x'}))
      assert.equal(path('testdata/x'), path(tuple({'testdata', 'x'})))
      assert.equal(path('testdata/x'), path(tuple({tuple('testdata', 'x')})))
    end)
    it("2 + .. = 1", function()
      assert.equal('testdata', tostring(path('testdata', 'x', '..')))
      assert.equal(path('testdata'), path('testdata', 'x', '..'))
      assert.equal(path('testdata'), path('./testdata', 'x', '..'))
      assert.equal(path('testdata'), path({'testdata', 'x', '..'}))
      assert.equal(path('testdata'), path({'testdata', 'x'}, '..'))
      assert.equal(path('testdata'), path({'testdata'}, 'x', '..'))
      assert.equal(path('testdata'), path({'testdata'}, {'x'}, {'..'}))
      assert.equal(path('testdata'), path({'testdata'}, 'x', {'..'}))
      assert.equal(path('testdata'), path({'testdata'}, {'x'}, '..'))
      assert.equal(path('testdata'), path('testdata', {'x'}, {'..'}))

      assert.equal(path('testdata'), path(tuple({'testdata'}, {'x'}, {'..'})))
      assert.equal(path('testdata'), path(tuple({'testdata'}, {tuple('x')}, tuple({'..'}))))

      assert.equal('testdata', tostring(path('testdata', 'x', '..')))
      assert.equal(path('testdata'), path(path('testdata'), 'x', '..'))
      assert.equal(path('testdata'), path(path('./testdata'), 'x', '..'))
      assert.equal(path('testdata'), path(path({'testdata', 'x', '..'})))
      assert.equal(path('testdata'), path(path({'testdata', 'x'}), '..'))
      assert.equal(path('testdata'), path(path({'testdata'}), 'x', '..'))
      assert.equal(path('testdata'), path(path({'testdata'}), {'x'}, {'..'}))
      assert.equal(path('testdata'), path(path({'testdata'}), 'x', {'..'}))
      assert.equal(path('testdata'), path(path({'testdata'}), {'x'}, '..'))
      assert.equal(path('testdata'), path(path('testdata'), {'x'}, {'..'}))
    end)
    it("3 + .. + .. = 1", function()
      assert.equal('testdata', tostring(path('testdata', 'x', '..', 'y', '..')))
      assert.equal(path('testdata'), path('testdata', 'x', '..', 'y', '..'))
      assert.equal(path('testdata'), path('./testdata', 'x', '..', 'y', '..'))
      assert.equal(path('testdata'), path({'testdata', 'x', '..', 'y', '..'}))

      assert.equal(path('testdata'), path(tuple('testdata', 'x', '..', 'y', '..')))
      assert.equal(path('testdata'), path(tuple({'testdata', 'x', '..', 'y', '..'})))
      assert.equal(path('testdata'), path({tuple('testdata', 'x', '..', 'y', '..')}))

      assert.equal(path('testdata'), path({'testdata', tuple('x', '..'), tuple('y', '..')}))
    end)
    it("3 + .. + .. = 1", function()
      assert.equal('testdata', tostring(path(tuple('testdata'), 'x', '..')))
      assert.equal(path('testdata'), path(path('testdata'), 'x', '..'))
      assert.equal(path('testdata'), path(path('./testdata'), 'x', '..'))
      assert.equal(path('testdata'), path(path({'testdata', 'x', '..'})))
      assert.equal(path('testdata'), path(path({'testdata', 'x'}), '..'))
      assert.equal(path('testdata'), path(path({'testdata'}), 'x', '..'))
      assert.equal(path('testdata'), path(path({'testdata'}), {'x'}, {'..'}))
      assert.equal(path('testdata'), path(path({'testdata'}), 'x', {'..'}))
      assert.equal(path('testdata'), path(path({'testdata'}), {'x'}, '..'))
      assert.equal(path('testdata'), path(path('testdata'), {'x'}, {'..'}))
    end)
    it("root", function()
      assert.equal('/testdata', tostring(path('//testdata')))
      assert.equal('/testdata', tostring(path('//testdata')))
      assert.equal('/testdata', tostring(path('/testdata')))
      assert.equal('/testdata', tostring(path('/', 'testdata')))
      assert.equal('/', tostring(path('/', '')))
      assert.equal('/', tostring(path('', '/')))
      assert.equal('/', tostring(path('/', '/')))
      assert.equal(path('/'), path('/'))
      assert.equal(path('/'), path('/', '', '/'))
      assert.equal(path('/testdata/x'), path('/', 'testdata', 'x'))
      assert.equal(path('/testdata/x'), path('/testdata', 'x'))
      assert.equal(path('/testdata/x'), path('/testdata/x'))
    end)
  end)
  it("normalize", function()
    assert.equal(path('testdata/x'), path('testdata/x/'))
    assert.equal(path('testdata/x'), path('testdata/x'))
    assert.equal(path('testdata/x'), path('testdata//x'))
    assert.equal(path('testdata/x'), path('testdata///x'))
    assert.equal(path('testdata/x'), path('testdata////x'))

    assert.equal(path('testdata/x'), path('testdata/x/'))
    assert.equal(path('testdata/x'), path('testdata//x//'))
    assert.equal(path('testdata/x'), path('testdata///x///'))
    assert.equal(path('testdata/x'), path('testdata////x///'))
    assert.equal(path('testdata/x'), path('testdata', 'x//'))

    assert.equal(path('testdata/x'), path('testdata/x/../y/z/c/../../../x'))
    assert.equal(path('testdata/x'), path('testdata/../testdata/../testdata/x'))
    assert.equal(path('testdata/x'), path('testdata///x'))
    assert.equal(path('testdata/x'), path('testdata////x'))
  end)
  describe("isdir/isfile/exists", function()
    it("regular", function()
      assert.exists(path('testdata'))
      assert.exists(path('testdata/test'))
      assert.exists(path('testdata/dir'))

      assert.dir(path('testdata/dir'))
      assert.not_file(path('testdata/dir'))
      assert.not_symlink(path('testdata/dir'))

      assert.file(path('testdata/test'))
      assert.not_dir(path('testdata/test'))
      assert.not_symlink(path('testdata/test'))

      assert.not_exists(path('testdata/noneexistent'))
      assert.not_dir(path('testdata/noneexistent'))
      assert.not_file(path('testdata/noneexistent'))
      assert.not_symlink(path('testdata/noneexistent'))
    end)
    it("symlink file", function()
      assert.is_true(is.fs.link(path('testdata/link/file')))
      assert.symlink(path('testdata/link/file'))

      assert.equal('testdata/link/file', tostring(path('testdata/link/file')))
      assert.equal('file', path('testdata/link/file')[-1])
--    assert.equal('testdata', path('testdata/test_symlink').basedir)
      assert.equal(4, path('testdata/link/file').size)

      assert.is_true(path('testdata/link/file').islink)
      assert.exists(path('testdata/link/file'))
      assert.file(path('testdata/link/file').target)
      assert.file(path('testdata/link/file'))
      assert.equal(path('testdata', 'test'), path('testdata/link/file').target)

      assert.is_nil(path('testdata/link/file').badlink)
    end)
    it("symlink dir", function()
      assert.is_true(is.fs.link(path('testdata/link/dir')))
      assert.symlink(path('testdata/link/dir'))
      assert.exists(path('testdata/link/dir'))
      assert.dir(path('testdata/link/dir').target)
      assert.dir(path('testdata/link/dir'))
      assert.equal(path('testdata', 'dir'), path('testdata/link/dir').target)
      assert.is_nil(path('testdata/link/dir').badlink)
      assert.is_nil(path('testdata/link/dir').size)
    end)
    it("symlink noneexistent", function()
      assert.symlink(path('testdata/link/noneexistent'))
      assert.is_true(path('testdata/link/noneexistent').islink)
      assert.exists(path('testdata/link/noneexistent'))
      assert.not_file(path('testdata/link/noneexistent'))
      assert.not_dir(path('testdata/link/noneexistent'))

      assert.is_true(is.fs.badlink(path('testdata/link/noneexistent')))
      assert.is_true(path('testdata/link/noneexistent').badlink)
      assert.is_nil(path('testdata/link/noneexistent').size)
    end)
  end)
  it("index", function()
    assert.equal('test_symlink', path('testdata/test_symlink')[-1])
    assert.same({'testdata','test_symlink'}, path('testdata/test_symlink')[{}])
  end)
  it("root/isabs/abs/ext", function()
    assert.is_nil(path('').isabs)
    assert.is_nil(path('testdata').isabs)
    assert.is_nil(path('lua/meta/fn').isabs)

    assert.equal(1, #path('/usr'))
    assert.equal('', path('/usr')[-2])
    assert.is_true(path('/usr').isabs)

    assert.equal('/usr/bin', tostring(path('/', 'usr', 'bin').abs))
  end)

--[[
  it("dirs/files/items", function()
    local createdirs = require 'testdata/randhier'
    local mk = path('/tmp')
    if not mk.exists then mk = path('testdata', 'mkdir') end
    local tree = mk..'tree'
    if not tree.exists then createdirs(tree) end
    assert.is_true(iter.count(tree.files)>0)
    assert.is_true(tree.rmfilesr)
    assert.equal(0, iter.count(tree.files))
    assert.is_true(tree.rmdirsr)
    assert.equal(0, iter.count(tree.dirs))
    assert.is_nil(tree.isdir)
  end)
--]]

--[[
  it("root/isabs/abs/ext", function()
    assert.is_nil(path('').root)
    assert.is_nil(path('').isabs)

    assert.equal('/', path('/usr').root)
    assert.is_true(path('/usr').isabs)

    assert.equal('txt', (path('testdata', 'mkdir') .. 'file.txt').ext)
    assert.equal('zip', (path('testdata', 'mkdir') .. 'file.xls.zip').ext)

    assert.equal('/usr/bin', tostring(path('/', 'usr', 'bin').abs))

    local paths = require 'paths'
    assert.equal(paths.concat('testdata', 'ok'), tostring(path('testdata/ok').abs))

    assert.equal('\\', path('\\Device').root)
    assert.is_true(path('\\Device').isabs)
  end)
  it("unc", function()
    local sep = "\\"
    assert.equal("\\\\", sep..sep)

    assert.equal("\\\\server\\share", path('\\\\server\\share').netunc)
    assert.equal("\\\\server\\share", path('\\\\server\\share\\').netunc)

    assert.equal('\\\\server\\with space', path('"\\\\server\\with space"').netunc)
    assert.equal('\\\\server\\with space', path('"\\\\server\\with space"\\').netunc)
    assert.equal('\\\\server\\spacepast', path('"\\\\server\\spacepast\\some\\a space x"\\').netunc)

    assert.equal('\\Device', path('\\Device').sysunc)
    assert.equal('\\Device', path('\\Device\\').sysunc)
    assert.equal('\\Device', path('\\Device\\HarddiskVolume2').sysunc)
    assert.equal('\\Device', path('\\Device\\HarddiskVolume2\\').sysunc)

    assert.equal("\\\\?\\Volume{4c1b02c4-d990-11dc-99ae-806e6f6e6963}", path('\\\\?\\Volume{4c1b02c4-d990-11dc-99ae-806e6f6e6963}').sysunc)
    assert.equal("\\\\?\\Volume{4c1b02c4-d990-11dc-99ae-806e6f6e6963}", path('\\\\?\\Volume{4c1b02c4-d990-11dc-99ae-806e6f6e6963}\\').sysunc)
  end)
  it("mkdir/rmdir write/append/rm size/content", function()
    local mk = path('testdata', 'mkdir')
    local a = mk .. 'a1'
    local b = a .. 'b'

    local f = (b .. 'file.txt').file
    assert.is_true(mk.isdir)
    assert.is_true(a.mkdir)
    assert.is_true(b.mkdir)
    assert.is_true(b.isdir)
    assert.is_true(a.isdir)

    assert.is_true(f.writecloser('1234567812345678'))
    assert.equal(16, f.size)
    assert.is_true(f.appendcloser('4444444422222222'))
    assert.equal(32, f.size)
    assert.equal('12345678123456784444444422222222', f.content)
    assert.is_true(a.rmall)
    assert.is_nil(a.isdir)
    assert.is_true(mk.isdir)
  end)
  it("anydir", function()
    assert.is_true(path('testdata', 'mkdir', 'a').mkdir)
    assert.is_nil(path('testdata', 'mkdir', 'a').anydir)
    assert.is_true(path('testdata', 'mkdir', 'a', 'test').mkdir)
    assert.equal('test', path('testdata', 'mkdir', 'a').anydir)
    assert.is_true(path('testdata', 'mkdir', 'a', 'test').rmdir)
    assert.is_true(path('testdata', 'mkdir', 'a').rmdir)
  end)
  it("mkdir/rmdir write/append/rm size/content", function()
    local mk = path('testdata', 'mkdir')
    local a = mk..'a2'
    local w = a..'b/c/d/e/w'

    assert.is_true(w.mkdirp)
    assert.is_true(w.isdir)
    assert.is_true(a.isdir)

    assert.is_true(a.rmall)
    assert.is_nil(w.isdir)
    assert.is_nil(a.isdir)
    assert.is_true(mk.isdir)
  end)
--]]
  it("dirs/files/items", function()
    local dirp = path('testdata/ok')
    assert.same(table.sorted({'dot', 'init.lua', 'message.lua'}), table.sorted(table()..dirp.lz))

--[[
    assert.same(table({'dot'}), table({}) .. (iter(dirp.dirs)*select.name)*tostring)
    assert.same(table.sorted(table('init.lua', 'message.lua')), table.sorted(table()..dirp.files*select.name))
    assert.same(table.sorted(table('dot', 'init.lua', 'message.lua')), table.sorted(table()..dirp.items))

    assert.same(table.sorted({'init.lua', 'message.lua'}), table.sorted(table()..dirp.ls%is.file*select.name))
    assert.same(table({'dot'}), table()..dirp.ls%is.dir*select.name)
--]]
  end)
--[[
  it("ls -r", function()
    assert.equal([ [testdata/loader/callable
testdata/loader/callable/func
testdata/loader/callable/func/func.lua
testdata/loader/callable/init_func
testdata/loader/callable/init_func/init.lua
testdata/loader/callable/init_table
testdata/loader/callable/init_table/init.lua
testdata/loader/callable/loader
testdata/loader/callable/loader/init.lua
testdata/loader/callable/noloader
testdata/loader/callable/noloader/.keep
testdata/loader/callable/table
testdata/loader/callable/table/table.lua
testdata/loader/dot
testdata/loader/dot/init.lua
testdata/loader/dot/ok.message.lua
testdata/loader/failed.lua
testdata/loader/init.lua
testdata/loader/meta_path
testdata/loader/meta_path/ok
testdata/loader/meta_path/ok/init.lua
testdata/loader/noinit
testdata/loader/noinit/message.lua
testdata/loader/noinit/noinit2
testdata/loader/noinit/noinit2/message.lua
testdata/loader/noinit/ok.message.lua
testdata/loader/ok
testdata/loader/ok/init.lua
testdata/loader/ok/message.lua] ],
    table.concat(table.sorted(table.map(path('testdata', 'loader').lsr, tostring)), "\n"))
  end)
--]]
end)