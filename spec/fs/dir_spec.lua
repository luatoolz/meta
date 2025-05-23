describe("fs.dir", function()
  local fs, dir, selector, sorted, d
  local iter
  setup(function()
    require 'meta'
    iter = require 'meta.iter'
    fs = require 'meta.fs'
    dir = fs.dir
    sorted = table.sorted
    selector = require 'meta.selector'
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

    assert.same({'a'}, table()..dir('testdata/mkdir').ls%'isdir'*-1)
    assert.same({'a'}, table()..(mk.ls%'isdir')*-1)
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted({}..mk.ls*-1))
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted({}..iter(mk)*-1))

--    assert.truthy(a.rmdir)
--    assert.same({}, {}..iter(mk)%'isdir')
  end)
  it("dirs/files/items", function()
    local ok = dir('testdata/ok')
    assert.same({'dot'}, {}..ok.ls%'isdir'*-1)
    assert.same(sorted({'init.lua', 'message.lua'}), sorted(table()..ok.ls%'isfile'*-1))
    assert.same(sorted({'dot', 'init.lua', 'message.lua'}), sorted(table.map(ok.ls)*-1))

    assert.same('dot', (ok/'isdir')[-1])
  end)
--[[
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
--]]
  it("dirs/files/items", function()
    local dirp = dir('testdata/ok')
    assert.same(table.sorted({'dot', 'init.lua', 'message.lua'}), table.sorted(table()..dirp.ls)*-1)
    assert.same(table.sorted({'init.lua', 'message.lua'}), table.sorted({}..dirp.ls%'isfile'*-1))
    assert.same(table({'dot'}), table()..(dirp.ls%'isdir'*selector[-1]))
  end)
--[[
  it("__unm", function()
    local a = dir('testdata', 'mkdir', 'a')

    assert.is_true(a.mkdir)
    assert.is_true(a.isdir)
    assert.is_true(-a)
    assert.is_nil(a.exists)
  end)
--]]
  it("ls -r", function()
    assert.equal([[testdata/loader2/callable
testdata/loader2/callable/func
testdata/loader2/callable/func/func.lua
testdata/loader2/callable/init_func
testdata/loader2/callable/init_func/init.lua
testdata/loader2/callable/init_table
testdata/loader2/callable/init_table/init.lua
testdata/loader2/callable/loader
testdata/loader2/callable/loader/init.lua
testdata/loader2/callable/noloader
testdata/loader2/callable/noloader/.keep
testdata/loader2/callable/table
testdata/loader2/callable/table/table.lua
testdata/loader2/dot
testdata/loader2/dot/init.lua
testdata/loader2/dot/ok.message.lua
testdata/loader2/failed.lua
testdata/loader2/init.lua
testdata/loader2/meta_path
testdata/loader2/meta_path/ok
testdata/loader2/meta_path/ok/init.lua
testdata/loader2/noinit
testdata/loader2/noinit/message.lua
testdata/loader2/noinit/noinit2
testdata/loader2/noinit/noinit2/message.lua
testdata/loader2/noinit/ok.message.lua
testdata/loader2/ok
testdata/loader2/ok/init.lua
testdata/loader2/ok/message.lua]],
    table.concat(table.sorted(table.map(iter(dir('testdata', 'loader2').lsr), tostring)), "\n"))
  end)
  it("lsr dirs", function()
    local s = [[testdata/loader2/callable
testdata/loader2/callable/func
testdata/loader2/callable/init_func
testdata/loader2/callable/init_table
testdata/loader2/callable/loader
testdata/loader2/callable/noloader
testdata/loader2/callable/table
testdata/loader2/dot
testdata/loader2/meta_path
testdata/loader2/meta_path/ok
testdata/loader2/noinit
testdata/loader2/noinit/noinit2
testdata/loader2/ok]]
    assert.equal(s, table.concat(table.sorted(table.map(iter(dir('testdata', 'loader2').lsr%'isdir'), tostring)), "\n"))
  end)
  it("lsr files", function()
    assert.equal([[testdata/loader2/callable/func/func.lua
testdata/loader2/callable/init_func/init.lua
testdata/loader2/callable/init_table/init.lua
testdata/loader2/callable/loader/init.lua
testdata/loader2/callable/noloader/.keep
testdata/loader2/callable/table/table.lua
testdata/loader2/dot/init.lua
testdata/loader2/dot/ok.message.lua
testdata/loader2/failed.lua
testdata/loader2/init.lua
testdata/loader2/meta_path/ok/init.lua
testdata/loader2/noinit/message.lua
testdata/loader2/noinit/noinit2/message.lua
testdata/loader2/noinit/ok.message.lua
testdata/loader2/ok/init.lua
testdata/loader2/ok/message.lua]],
    table.concat(table.sorted(table.map(dir('testdata', 'loader2').lsr%'isfile', tostring)), "\n"))
  end)
end)