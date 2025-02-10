describe("path", function()
  local meta, is, path, iter, tuple
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    path = meta.path
    tuple = iter.tuple
  end)
  it("meta", function() assert.is_true(is.callable(path)) end)
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

      assert.equal(path('testdata'), path({tuple('testdata')}))

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
  it("isdir/isfile/exists", function()
    assert.is_true(path('testdata').exists)
    assert.is_true(path('testdata/test').exists)
    assert.is_true(path('testdata/dir').exists)

    assert.is_true(path('testdata').isdir)
    assert.is_nil(path('testdata').isfile)

    assert.is_true(path('testdata/test').isfile)
    assert.is_table(path('testdata/test').file)
    assert.is_table(path('testdata/dir').dir)

    assert.is_nil(path('testdata/noneexistent').isfile)
    assert.is_nil(path('testdata/noneexistent').isdir)

    assert.is_true(path('testdata/test_symlink').islink)

    assert.equal('testdata/test_symlink', path('testdata/test_symlink').path)
    assert.equal('test_symlink', path('testdata/test_symlink').name)
    assert.equal('testdata', path('testdata/test_symlink').basedir)

    assert.is_true(path('testdata/test_symlink').islink)
    assert.is_true(path('testdata/test_symlink').target.isfile)

    assert.equal(path('testdata', 'test'), path('testdata/test_symlink').target)

    assert.is_true(path('testdata/dir_symlink').islink)
    assert.is_true(path('testdata/dir_symlink').target.isdir)

    assert.is_true(path('testdata/noneexistent_symlink').islink)
    assert.falsy(path('testdata/noneexistent_symlink').target.exists)
  end)
  it("index", function()
    assert.equal('test_symlink', path('testdata/test_symlink')[-1])
    assert.same({'testdata','test_symlink'}, path('testdata/test_symlink')[{}])
  end)
  it("root/isabs/abs/ext", function()
    assert.is_nil(path('').root)
    assert.is_nil(path('').isabs)

    assert.equal('/', path('/usr').root)
    assert.is_true(path('/usr').isabs)

    assert.equal('txt', (path('testdata', 'mkdir') / 'file.txt').ext)
    assert.equal('zip', (path('testdata', 'mkdir') / 'file.xls.zip').ext)

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
    local a = mk / 'a'
    local b = a / 'b'
--    local f = b / 'file.txt'
    assert.is_true(mk.isdir)
    assert.is_nil(b.isdir)
    assert.is_nil(a.isdir)

    assert.is_true(a.mkdir)
    assert.is_true(b.mkdir)
    assert.is_true(b.isdir)
    assert.is_true(a.isdir)

--[[
    assert.is_nil(f.isfile)
    assert.equal(16, f:write('1234567812345678', 0))
    assert.is_true(f.isfile)
    assert.equal(16, f.size)
    assert.equal(16, f:append('4444444422222222'))
    assert.equal(32, f.size)
    assert.equal('12345678123456784444444422222222', f.content)
--]]
    assert.is_true(b.rmdir)
--    assert.is_true(f.rm)
--    assert.is_nil(f.isfile)
    assert.is_nil(b.rmdir)
    assert.is_true(a.rmdir)
    assert.is_true(mk.isdir)
  end)
  it("dirs/files/items", function()
    local dir = path('testdata/ok')
    assert.values(table('dot'), table() .. dir.dirs)
    assert.values(table('init.lua', 'message.lua'), table() .. dir.files)
    assert.values(table('dot', 'init.lua', 'message.lua'), table() .. dir.items)
    assert.values(table('init.lua', 'message.lua'), dir.ls%is.file)
  end)
  it("ls -r", function()
    assert.equal([[testdata/loader/callable
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
testdata/loader/ok/message.lua]],
    table.concat(table.sorted(table.map(path('testdata', 'loader').lsr, tostring)), "\n"))
  end)
end)