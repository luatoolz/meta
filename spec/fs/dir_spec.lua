describe("fs.dir", function()
  local is, fs, dir, selector, sorted, d
  local iter
  setup(function()
    require 'meta'
    iter = require 'meta.iter'
    is = require 'meta.is'
    fs = require 'meta.fs'
    dir = fs.dir
    sorted = table.sorted
    selector = require 'meta.select'
    d = dir('testdata')
  end)
  it("new", function()
    assert.equal('testdata/mkdir', tostring(dir(d, 'mkdir')))
    assert.equal(dir(d), dir('testdata'))
    assert.equal(dir(d), dir(dir('testdata')))
    assert.equal(dir(d, 'mkdir'), dir(d, 'mkdir'))
    assert.equal(dir(d, 'mkdir'), dir(dir(d, 'mkdir')))
  end)
  it("isdir/isfile/exists", function()
    assert.truthy(dir('testdata').isdir)
    assert.truthy(dir('testdata/dir').isdir)
    assert.truthy(dir('testdata').isdir)
  end)
  it("mkdir/rmdir write/append/rm size/content", function()
    assert.truthy(d.isdir)
    local mk = d..'mkdir'
    assert.is_true(mk.exists)
    assert.is_true(mk.isdir)

    local a = mk .. 'a'
    assert.truthy(a.mkdir)
    assert.equal('testdata/mkdir/a', tostring(a))

    assert.same({'a'}, {}..iter(mk.ls%'isdir')*-1)
    assert.same({'a'}, table()..(mk.ls%'isdir')*-1)
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted({}..mk.ls*-1))
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted({}..iter(mk)*-1))

    assert.truthy(a.rmdir)
    assert.same({}, {}..iter(mk)%'isdir')
  end)
  it("dirs/files/items", function()
    local ok = dir('testdata/ok')
    assert.same({'dot'}, {}..ok.ls%is.fs.dir*selector[-1])
    assert.same(sorted({'init.lua', 'message.lua'}), sorted(table()..ok.ls%is.fs.file*selector[-1]))
    assert.same(sorted({'dot', 'init.lua', 'message.lua'}), sorted(table.map(ok.ls)*selector[-1]))

    assert.same('dot', (ok/is.fs.dir)[-1])
    assert.same('dot', (ok/'isdir')[-1])
  end)
  it("dirs/files", function()
    local createdirs = require 'testdata/randhier'
    local mk = dir('/tmp')
    if not mk.exists then mk = dir('testdata', 'mkdir') end
    local p = mk..'tree'

    assert.is_number(iter.count(p.tree%'nondir'))
    assert.is_number(iter.count(p.tree%'isdir'))

    assert.truthy(-p)
    assert.is_nil(p.isdir)
    assert.truthy(createdirs(p))
    assert.is_true(iter.count(p.tree%'nondir')>0)
    assert.is_true(iter.count(p.tree%'isdir')>0)
    assert.truthy(p.rmtree)
    assert.is_nil(p.exists)

    assert.truthy(createdirs(p))
    assert.truthy(-p)
    assert.is_nil(p.exists)
  end)
  it("dirs/files/items", function()
    local dirp = dir('testdata/ok')
    assert.same(table.sorted({'dot', 'init.lua', 'message.lua'}), table.sorted(table({})..dirp.ls*-1))
    assert.same(table.sorted({'init.lua', 'message.lua'}), table.sorted({}..dirp.ls%'isfile'*-1))
    assert.same(table({'dot'}), table()..(dirp.ls%'isdir'*selector[-1]))
  end)
  it("__unm", function()
    local a = dir('testdata', 'mkdir', 'a')

    assert.is_true(a.mkdir)
    assert.is_true(a.isdir)
    assert.is_true(-a)
    assert.is_nil(a.exists)
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
    table.concat(table.sorted(table.map(iter(dir('testdata', 'loader').lsr), tostring)), "\n"))
  end)
  it("lsr dirs", function()
    local s = [[testdata/loader/callable
testdata/loader/callable/func
testdata/loader/callable/init_func
testdata/loader/callable/init_table
testdata/loader/callable/loader
testdata/loader/callable/noloader
testdata/loader/callable/table
testdata/loader/dot
testdata/loader/meta_path
testdata/loader/meta_path/ok
testdata/loader/noinit
testdata/loader/noinit/noinit2
testdata/loader/ok]]
    assert.equal(s, table.concat(table.sorted(table.map(iter(dir('testdata', 'loader').lsr%is.fs.dir), tostring)), "\n"))
    assert.equal(s, table.concat(table.sorted(table.map(iter(dir('testdata', 'loader').lsr%'isdir'), tostring)), "\n"))
  end)
  it("lsr files", function()
    assert.equal([[testdata/loader/callable/func/func.lua
testdata/loader/callable/init_func/init.lua
testdata/loader/callable/init_table/init.lua
testdata/loader/callable/loader/init.lua
testdata/loader/callable/noloader/.keep
testdata/loader/callable/table/table.lua
testdata/loader/dot/init.lua
testdata/loader/dot/ok.message.lua
testdata/loader/failed.lua
testdata/loader/init.lua
testdata/loader/meta_path/ok/init.lua
testdata/loader/noinit/message.lua
testdata/loader/noinit/noinit2/message.lua
testdata/loader/noinit/ok.message.lua
testdata/loader/ok/init.lua
testdata/loader/ok/message.lua]],
    table.concat(table.sorted(table.map(dir('testdata', 'loader').lsr%'isfile', tostring)), "\n"))
  end)
end)