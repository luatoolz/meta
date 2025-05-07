describe("file", function()
  local meta, iter, d, file
  setup(function()
    meta = require "meta"
    iter = meta.iter
    file = require 'meta.fs.file'
    d = 'testdata'
  end)
  it("meta", function() assert.callable(file) end)
  it("new", function()
    local p = file(d, 'test')
    assert.is_table(p)

    assert.equal('testdata/test', tostring(p))
    assert.equal('testdata/test', tostring(file(p)))
    assert.equal('test', tostring(file('test')))

    assert.equal(file, meta.fs.file)
  end)
  it("open/close", function()
    local p = file(d, 'test')

    assert.exists(p)
    assert.file(p)
    assert.equal(4, p.size)

    assert.is_nil(p.fd)
    assert.file(p:open('rb'))
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.file(p:open('rb'))
    assert.file(p.fd)
    assert.is_true(p:close())
    assert.is_nil(p.fd)
    assert.exists(p)
  end)
  it("open + read + autoclose / close", function()
    local p = file(d, 'test')

    assert.exists(p)
    assert.equal(4, p.size)

    assert.is_nil(p.fd)
    assert.equal('test', p.reader())
    assert.is_nil(p.fd)

    assert.file(p:open('rb'))
    assert.equal('test', p:read())
    assert.is_nil(p.fd)

    assert.file(p:open('rb'))
    assert.equal('test', p:read('*a'))
    assert.is_nil(p.fd)

    assert.file(p:open('rb'))
    assert.equal('test', p:read(777))
    assert.is_nil(p.fd)

    assert.file(p:open('rb'))
    assert.equal('te', p:read(2))
    assert.file(p.fd)
    assert.equal('st', p:read(2))
    assert.is_nil(p.fd)

    assert.equal('test', table.concat(iter.collect(iter(p), {}), ''))
    assert.is_nil(p.fd)
  end)
  it("write/overwrite + auto close / delete", function()
    local p = file(d, 'test2')
    assert.equal('test2', p[-1])

    assert.is_nil(p.fd)
    assert.is_true(-p)

    assert.is_nil(p.fd)
    assert.is_true(p.writer('111'))
    assert.is_nil(p.fd)
    assert.exists(p)
    assert.equal(3, p.size)

    assert.file(p:open('w+b'))
    assert.is_true(p:write('222'))
    assert.is_true(p:flush())
    assert.equal(3, p.size)
    assert.file(p.fd)
    assert.is_true(p:write('333'))
    assert.is_true(p:flush())
    assert.equal(6, p.size)
    assert.file(p.fd)
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.equal(6, p.size)

    assert.is_true(-p)
    assert.not_exists(p)
  end)
  it("__unm", function()
    local mk = file(d, 'mkdir')
    local p, l = mk..'atest', mk..'alink'

    assert.is_true(p.writer('111'))
    assert.is_nil(p.fd)
    assert.exists(p)
    assert.exists(l)
    assert.equal(3, p.size)
    assert.equal(3, l.size)
    assert.is_true(-p)
    assert.not_exists(p)
    assert.exists(l)

    assert.is_true(l.writer('222'))
    assert.is_nil(p.fd)
    assert.exists(p)
    assert.exists(l)
    assert.equal(3, p.size)
    assert.equal(3, l.size)

    local app = p.appender
    assert.is_true(app('3', true))
    assert.is_true(app('4', true))
    assert.is_true(app('5'))
    assert.equal(6, p.size)
    assert.equal(6, l.size)
    assert.equal('222345', p.reader())

    local lapp = l.appender
    assert.is_true(lapp('6', true))
    assert.is_true(lapp('7', true))
    assert.is_true(lapp('8'))
    assert.equal(9, p.size)
    assert.equal(9, l.size)
    assert.equal('222345678', p.reader())

    assert.is_true(-p)
    assert.not_exists(p)
    assert.exists(l)
  end)
end)