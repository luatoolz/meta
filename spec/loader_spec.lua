describe('loader', function()
  local testdata, tl, path, dir, loader
  setup(function()
    require "compat53"
    testdata = 'testdata'
    tl = require "testdata/loader"
    path = require "meta.path"
    dir = require "meta.dir"
    loader = require "meta.loader"
  end)
  it("ok", function()
    assert.is_table(tl)
    assert.is_not_nil(tl.ok)
    assert.equal('ok', tl.ok.message.data)
  end)
  it("req", function()
    local req = require "testdata/req"
    assert.is_table(req)
    assert.is_nil(rawget(req, 'ok'))
    local req_ok = require "testdata/req/ok"
    assert.is_table(req_ok)
    local loaders = require "meta.loaders"
    assert.is_table(loaders["testdata/req/ok"])
    assert.is_table(req.ok)
    assert.equal('ok', req.ok.message.data)
  end)
  it("loader() == loader()", function() assert.equal(loader('testdata/lt'), loader('testdata/lt')) end)
  it("dot", function()
    assert.is_not_nil(tl)
    assert.is_not_nil(tl.dot)
    assert.equal('ok', tl.dot['ok.message'].data)
  end)
  it("path", function()
    assert.equal(testdata .. '/loader', path(testdata, 'loader'))
    assert.equal(testdata .. '/loader', path(testdata .. '/loader'))
    assert.equal(testdata .. '/loader/noinit', path(testdata .. '/loader', 'noinit'))
    assert.equal(testdata .. '/loader/noinit', path(testdata .. '.loader', 'noinit'))
  end)
  it("dir", function()
    assert.equal('meta', dir('meta.loader'))
    assert.equal('meta', dir('meta/loader'))
    assert.is_nil(dir('meta', 'loader'))

    assert.equal('testdata/ok', dir('testdata/ok/message'))
    assert.is_nil(dir('testdata/ok', 'message'))
  end)
  it("noinit", function()
    assert.is_not_nil(tl)
    assert.equal('table', type(tl))
    assert.is_not_nil(tl.noinit)
    assert.equal('table', type(tl.noinit))
    assert.equal('ok', tl.noinit['ok.message'].data)
    assert.equal('ok', tl.noinit.message.data)
  end)
  it("failed", function()
    --    assert.has_error(function() return tl.failed end)
    --    assert.has_error(function() local m, err=tl.failed; if not m then error(m) end; return m end)
  end)
end)
