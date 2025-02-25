describe("dir", function()
  local meta, is, path, dir, iter, selector
  setup(function()
    meta = require "meta"
    is = meta.is
    path = meta.path
    dir = meta.dir
    iter = meta.iter
    selector = meta.select
  end)
  it("meta", function() assert.is_true(is.callable(dir)) end)
  it("new", function()
    assert.equal(dir(''), dir(''))
    assert.equal(dir('testdata'), dir('testdata'))
    assert.equal(dir('testdata'), dir(dir('testdata')))

    assert.equal(dir('testdata', 'mkdir'), dir('testdata', 'mkdir'))
    assert.equal(dir('testdata', 'mkdir'), dir(dir('testdata', 'mkdir')))
  end)
  it("isdir/isfile/exists", function()
    assert.truthy(dir('testdata'))
    assert.truthy(dir('testdata/dir'))
    assert.truthy(is.dir(dir('testdata')))
  end)
  it("mkdir/rmdir write/append/rm size/content", function()
    local mkp = path('testdata')
    local td = mkp.dir

    assert.truthy(is.dir(td))
    local mk = dir(mkp, 'mkdir')

    local a = mk / 'a'
    assert.truthy(a)
    assert.is_true(path('testdata', 'mkdir', 'a').isdir)

    assert.values({'a'}, mk % is.dir * selector[-1])
    assert.values({'a', 'test', '.keep'}, mk*selector[-1])

    a.file = '12345678123456784444444422222222'
    local sub = a.file
    assert.is_nil(sub.fd)
    assert.is_true(sub.exists)
    assert.values({'file'}, a % is.file * selector[-1])
    assert.values({'file'}, a *selector[-1]*string.matcher('f.*'))

    assert.equal('file', sub.name)
    assert.equal('12345678123456784444444422222222', sub.content)
    assert.is_nil(sub.fd)
    assert.is_true(-sub)

    assert.truthy(-a)
    assert.values({}, mk % is.dir)
  end)
  it("dirs/files/items", function()
    local ok = dir('testdata/ok')
    assert.same({'dot'}, ok%is.dir*selector[-1])
    assert.values({'init.lua', 'message.lua'}, ok%is.file*selector[-1])
    assert.values({'dot', 'init.lua', 'message.lua'}, iter(ok)*selector[-1])
  end)
  it("__unm", function()
    local a = path('testdata', 'mkdir', 'a')

    assert.is_nil(a.isdir)
    assert.is_true(is.dir(a.dir))
    assert.is_true(a.isdir)

    assert.is_true(is.dir(a.dir))
    assert.is_true(-a.dir)
    assert.is_nil(a.isdir)

    a.dir.file = 'content'
    assert.is_true(a.isdir)
    assert.is_true((a/'file').isfile)

    assert.is_true(-a.dir)
    assert.is_nil((a/'file').isfile)
    assert.is_nil(a.isdir)
  end)
end)