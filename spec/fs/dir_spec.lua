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
--    assert.truthy(a.isdir)
    assert.equal('testdata/mkdir/a', tostring(a))

--    assert.same({'a'}, {}..iter(mk.ls%'isdir')*selector[-1])
--    assert.same({'a'}, table()..(mk.ls%'isdir')*selector[-1])
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted({}..mk.ls*selector[-1]))

--[[
    assert.is_nil(a.file)
    a.file = '12345678123456784444444422222222'
    local sub = a.file
    assert.is_nil(sub.fd)
    assert.is_true(sub.exists)
    assert.same(sorted({'file'}), sorted(a % is.fs.file * selector[-1]))
    assert.same(sorted({'file'}), sorted(a *selector[-1]*string.matcher('f.*')))

    assert.equal('file', sub[-1])
    assert.equal('12345678123456784444444422222222', sub.reader())
    assert.is_nil(sub.fd)
    assert.is_true(-sub)
    assert.falsy(sub)
--]]
    assert.truthy(-a)
--    assert.same({}, {}..iter(mk.ls)%'isdir')
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

    assert.truthy((not p.exists) or -p)
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
--[[
  it("path / __div", function()
    local a = dir('testdata', 'mkdir', 'b')
    local atest = (a..'new')

    assert.is_true(atest.rmdir)
    assert.is_true(a.mkdir)
    assert.is_nil(a/'isdir')
    assert.is_true(atest.mkdir)
    assert.is_true(atest.rmdir)
    assert.is_true(a.rmdir)
  end)
--]]
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
    assert.equal([[testdata/loader/callable
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
testdata/loader/ok]],
--    table.concat(table.sorted(table.map(iter(path('testdata', 'loader').lsr%is.fs.dir), tostring)), "\n"))
    table.concat(table.sorted(table.map(iter(dir('testdata', 'loader').lsr%'isdir'), tostring)), "\n"))
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