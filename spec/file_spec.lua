describe("file", function()
  local meta, is, map, path, dir, d
  setup(function()
    meta = require "meta"
    is = meta.is
    map = table.map
    path = meta.path
    dir = meta.dir
    d = dir('testdata')
    _ = map
    _ = path
  end)
  it("meta", function() assert.is_true(is.callable(dir)) end)
  it("new", function()
    local p = d.test
    assert.is_table(p)
    assert.is_true(p.exists)
    assert.truthy(p:open('rb'))
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.is_true(is.file(p.fd))
    assert.is_true(p:close())
    assert.is_nil(p.fd)
    assert.is_true(p.exists)
  end)
  it("open/close", function()
    local p = d.test
    assert.equal(4, p.size)
    assert.is_true(p:open('rb'))
    assert.is_true(is.file(p.fd))
    assert.is_true(p:close())
    assert.is_nil(p.fd)
  end)
  it("open + read + autoclose / close", function()
    local p = d.test
    assert.is_true(p.exists)
    assert.equal(4, p.size)

    assert.is_nil(p.fd)
    assert.equal('test', p.reader())
    assert.is_nil(p.io.fd)

    assert.is_true(p:open('rb'))
    assert.equal('test', p.content)
    assert.is_nil(p.fd)

    assert.is_true(p:open('rb'))
    assert.equal('test', p:read())
    assert.is_nil(p.fd)

    assert.is_true(p:open('rb'))
    assert.equal('test', p:read('*a'))
    assert.is_nil(p.fd)

    assert.is_true(p:open('rb'))
    assert.equal('test', p:read(777))
    assert.is_nil(p.fd)

    assert.is_true(p:open('rb'))
    assert.equal('te', p:read(2))
    assert.is_true(is.file(p.fd))
    assert.equal('st', p:read(2))
    assert.is_true(is.file(p.fd))
    assert.is_nil(p:read(2))
    assert.is_nil(p.fd)
  end)
  it("write/overwrite + auto close / delete", function()
    local p = d.test2
    assert.equal('test2', p.name)

    assert.is_nil(p.fd)
    assert.is_true(is.file(p))
    local _ = p.rm

    assert.is_nil(p.fd)
    assert.is_true(p.writecloser('111'))
    assert.is_nil(p.fd)
    assert.is_true(p.exists)
    assert.equal(3, p.size)

    assert.is_true(p:write('222'))
    assert.is_true(p:flush())
    assert.equal(3, p.size)
    assert.is_true(is.file(p.fd))
    assert.is_true(p:write('333'))
    assert.is_true(p:flush())
    assert.equal(6, p.size)
    assert.is_true(is.file(p.fd))
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.equal(6, p.size)

    assert.is_true(-p)
    assert.is_nil(p.exists)
  end)
  it("properties", function()
    assert.is_number(d.test.age)
  end)
end)