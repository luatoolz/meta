describe("dir", function()
  local meta, is, map, path, dir
  setup(function()
    meta = require "meta"
    is = meta.is
    map = table.map
    path = meta.path
    dir = meta.dir
  end)
  it("meta", function() assert.is_true(is.callable(dir)) end)
  it("new", function()
    assert.equal(dir(''), dir(''))
    assert.equal(dir('testdata'), dir('testdata'))
  end)
  it("isdir/isfile/exists", function()
    assert.truthy(dir('testdata'))
    assert.truthy(dir('testdata/dir'))
  end)
--[[
  it("mkdir -p / rmdir", function()
    local mk = dir('testdata', 'mkdir')
    assert.is_true(mk.isdir)
    local a = mk/'a'
    assert.is_nil(a.isdir)

    local b = a/'b'
    local c = b/'c'
    assert.is_true(c.mkdir)
    assert.is_true(a.isdir)
    assert.is_true(b.isdir)
    assert.is_true(c.isdir)

    assert.is_true(c.rmdir)
    assert.is_true(b.rmdir)
    assert.is_true(a.rmdir)

    assert.is_nil(a.isdir)
    assert.is_true(mk.isdir)
  end)
--]]
  it("mkdir/rmdir write/append/rm size/content", function()
    local mk = dir('testdata', 'mkdir')
    assert.truthy(mk)

    local a = mk / 'a'
    assert.truthy(a)

    assert.same({'a'}, map(path(mk).dirs))
    assert.same({'a'}, table() .. mk*'dirs')
    assert.same({'a'}, mk % is.dir)

    assert.same({'a'}, mk%function(x) return is.dir(tostring(path(mk,x))) end)
    assert.values({'a', 'test'}, mk % '^%w+$')
    assert.same({}, mk%'%d+')

    a.file = '12345678123456784444444422222222'
    local sub = a.file
    assert.is_nil(sub.fd)
    assert.is_true(sub.exists)
    assert.same({'file'}, a % is.file)
    assert.same({'file'}, a*'files')
    assert.same({'file'}, a%function(x) return is.file(tostring(path(a,x))) end)
    assert.same({'file'}, a%'f.*')

    assert.equal('file', sub.name)
    assert.equal('12345678123456784444444422222222', sub.content)
    assert.is_nil(sub.fd)
    assert.is_true(-sub)

    assert.same({'a'}, map(path(mk).dirs))
    assert.truthy(-a)
    assert.same({}, map(path(mk).dirs))
  end)
  it("dirs/files/items", function()
    local ok = dir('testdata/ok')
    assert.values({'dot'}, ok%is.dir)
    assert.values({'init.lua', 'message.lua'}, ok%is.file)
    assert.values({'dot', 'init.lua', 'message.lua'}, ok*nil)
  end)
end)