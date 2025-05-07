describe("dir2", function()
  local meta, is, path, dir, iter, selector, sorted, fs, d
  setup(function()
    meta = require "meta"
    is = require 'meta.is'
    fs = require 'meta.fs'
    path = require 'meta.fs.path'
    dir = require 'meta.fs.dir'
    iter = require 'meta.iter'
    sorted = table.sorted
    selector = require 'meta.select'
    d = dir('testdata')
  end)
  it("meta", function() assert.is_true(is.callable(dir)) end)
  it("new", function()
    assert.equal('testdata/mkdir', tostring(dir(d, 'mkdir')))
    assert.equal(dir(d), dir('testdata'))
    assert.equal(dir(d), dir(dir('testdata')))
    assert.equal(dir(d, 'mkdir'), dir(d, 'mkdir'))
    assert.equal(dir(d, 'mkdir'), dir(dir(d, 'mkdir')))
  end)
  it("isdir/isfile/exists", function()
    assert.truthy(dir('testdata'))
    assert.truthy(dir('testdata/dir'))
    assert.dir(dir('testdata'))
    assert.dir('testdata')
  end)
  it("mkdir/rmdir write/append/rm size/content", function()
    assert.truthy(is.fs.dir(d))
    local mk = d..'mkdir'
    assert.exists(mk)
    assert.dir(mk)

    local a = mk .. 'a'
    assert.truthy(a)
    assert.truthy(is.like(a,mk))
    assert.equal('testdata/mkdir/a', tostring(a))

    assert.dir(a)

    assert.same({'a'}, mk % is.fs.dir *selector[-1])
    assert.same(sorted({'a', 'test', 'alink', '.keep'}), sorted(mk*selector[-1]))

--[[
    a.file = '12345678123456784444444422222222'
    local sub = a.file
    assert.is_nil(sub.fd)
    assert.is_true(sub.exists)
    assert.same(sorted({'file'}), sorted(a % is.fs.file * selector[-1]))
    assert.same(sorted({'file'}), sorted(a *selector[-1]*string.matcher('f.*')))

    assert.equal('file', sub.name)
    assert.equal('12345678123456784444444422222222', sub.content)
    assert.is_nil(sub.fd)
    assert.is_true(-sub)
--]]
    assert.truthy(-a)
    assert.same({}, mk % is.fs.dir)
  end)
  it("dirs/files/items", function()
    local ok = dir('testdata/ok')
    assert.same({'dot'}, ok%is.fs.dir*selector[-1])
    assert.same(sorted({'init.lua', 'message.lua'}), sorted(ok%is.fs.file*selector[-1]))
    assert.same(sorted({'dot', 'init.lua', 'message.lua'}), sorted(ok*selector[-1]))
  end)
--[[
  it("__unm", function()
    local a = dir('testdata', 'mkdir', 'a')

--    assert.is_nil(a.isdir)
    assert.is_true(is.fs.dir(a))
--    assert.is_true(a.isdir)
    assert.is_true(is.fs.dir(a))
    assert.is_true(-a)
    assert.is_nil(a.isdir)

    a.dir.file = 'content'
    assert.is_true(a.isdir)
    assert.is_true((a..'file').isfile)

    assert.is_true(-a.dir)
    assert.is_nil((a..'file').isfile)
    assert.is_nil(a.isdir)
  end)
--]]
end)