describe("file", function()
  local iter, fs, d, file, dir
  setup(function()
    iter = require 'meta.iter'
    fs   = require 'meta.fs'
    file = fs.file
    dir  = fs.dir
    d    = 'testdata'
  end)
  it("new", function()
    local p = file(d, 'test')
    assert.is_table(p)

    assert.equal('testdata/test', tostring(p))
    assert.equal('testdata/test', tostring(file(p)))
    assert.equal('test', tostring(file('test')))

    assert.equal(file, fs.file)
  end)
  it("open/close", function()
    local p = file(d, 'test')

    assert.is_true(p.exists)
    assert.is_true(p.isfile)
    assert.equal(4, p.size)

    assert.is_nil(p.fd)
    assert.truthy(p:open('rb'))
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.truthy(p.fd)
    assert.is_true(p:close())
    assert.is_nil(p.fd)
    assert.is_true(p.exists)
  end)
  it("open + read + autoclose / close", function()
    local p = file(d, 'test')

    assert.is_true(p.exists)
    assert.is_number(p.size)

    assert.is_nil(p.fd)
    assert.equal('test', p.reader())
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.equal('test', p:read())
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.equal('test', p:read('*a'))
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.equal('test', p:read(777))
    assert.is_nil(p.fd)

    assert.truthy(p:open('rb'))
    assert.equal('te', p:read(2))
    assert.truthy(p.fd)
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
    assert.is_true(p.exists)
    assert.equal(3, p.size)

    assert.truthy(p:open('w+b'))
    assert.is_true(p:write('222'))
    assert.is_true(p:flush())
    assert.equal(3, p.size)
    assert.truthy(p.fd)
    assert.is_true(p:write('333'))
    assert.is_true(p:flush())
    assert.equal(6, p.size)
    assert.truthy(p.fd)
    assert.is_true(p:close())
    assert.is_nil(p.fd)

    assert.equal(6, p.size)

    assert.is_true(-p)
    assert.is_nil(p.exists)
  end)
  it("__unm", function()
    local mk = dir(d, 'mkdir')
    local p, l = file(mk..'atest'), file(mk..'alink')

    assert.is_true(p.writer('abc'))
    assert.is_nil(p.fd)
    assert.is_true(p.exists)
    assert.is_true(l.exists)
    assert.equal(3, p.size)
    assert.equal(3, l.size)
    assert.is_true(-p)
    assert.is_nil(p.exists)
    assert.is_true(l.exists)

    assert.is_true(l.writer('222'))
    assert.is_nil(p.fd)
    assert.is_true(p.exists)
    assert.is_true(l.exists)
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
    assert.is_nil(p.exists)
    assert.is_true(l.exists)
  end)
end)