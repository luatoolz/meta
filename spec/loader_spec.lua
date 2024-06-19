describe('loader', function()
  local cache, no, loader, module, tl
  setup(function()
    require "compat53"
    require "meta.assert"
    cache = require "meta.cache"
    no = require "meta.no"
    loader = require "meta.loader"
    module = require "meta.module"
    tl = require "testdata.loader"
  end)
  it("ok", function()
    assert.is_table(cache)
    assert.is_table(tl)
    assert.is_not_nil(tl.ok)
    assert.equal('ok', tl.ok.message.data)
    local q = tl.ok
    assert.equal('ok', q.message.data)
  end)
  it("eq meta", function()
    local meta = require("meta")
    assert.same(getmetatable(require("meta")), getmetatable(cache.new.loader))
    assert.equal(getmetatable(cache.new.loader), getmetatable(require("meta")))
    assert.equal(getmetatable(meta), getmetatable(cache.new.loader))
    assert.equal(getmetatable(require("meta")), getmetatable(loader("meta")))
  end)
  it("eq loader", function()
    assert.equal(loader('testdata/loader/noinit'), loader('testdata/loader/noinit'))
    assert.equal(loader('testdata/req/ok'), loader('testdata/req/ok'))
  end)
  it("module.loader", function()
    local noinit = loader('testdata/loader/noinit')
    local m = module(noinit)
    assert.is_table(noinit)
    assert.is_table(m)
    assert.equal('ok', noinit.message.data)
    assert.equal('ok', noinit['ok.message'].data)
  end)
  it("req", function()
    local req = require "testdata/req"
    assert.is_table(req)
    assert.is_nil(rawget(req, 'ok'))
    local req_ok = require "testdata/req/ok"
    assert.is_table(req_ok)
    local loaders = loader
    assert.is_table(loaders["testdata/req/ok"])
    assert.is_table(req)
    assert.is_table(req['ok'])
    assert.equal('ok', req.ok.message.data)
  end)
  it("loader() == loader()", function() assert.equal(loader('testdata/lt'), loader('testdata/lt')) end)
  it("dot", function()
    assert.is_table(tl)
    assert.is_not_nil(tl.dot)
    assert.equal('ok', tl.dot['ok.message'].data)
  end)
  it("dir", function()
    assert.ends('meta', no.dir('meta'))

    assert.is_nil(no.dir('meta', 'loader'))

    assert.ends('testdata/ok', no.dir('testdata/ok'))
    assert.is_nil(no.dir('testdata/ok', 'message'))
    assert.ends('testdata/loader', no.dir('testdata', 'loader'))
    assert.ends('testdata/loader', no.dir('testdata/loader'))
    assert.ends('testdata/loader/noinit', no.dir('testdata/loader', 'noinit'))
  end)
  it("noinit", function()
    tl = require "testdata.loader"
    assert.is_not_nil(tl)
    assert.is_table(tl)
    assert.is_not_nil(tl.noinit)
    assert.equal('table', type(tl.noinit))
    assert.is_table(module(tl))
    assert.equal('ok', tl.noinit.message.data)
    assert.equal('ok', tl.noinit['ok.message'].data)
    assert.equal('ok', tl.noinit.message.data)
  end)
  it("regular load + recursive preload", function()
    assert.falsy(module("testdata.webapi").topreload)
    assert.falsy(module("testdata.webapi").torecursive)

    local webapi = loader("testdata.webapi", true, true)
    local webapi2 = module("testdata.webapi").recursive.preload

    assert.equal(true, module("testdata.webapi").topreload)
    assert.equal(true, module(webapi).topreload)
    assert.equal(true, module(webapi2).topreload)

    assert.equal(true, module("testdata.webapi").torecursive)
    assert.equal(true, module(webapi).torecursive)
    assert.equal(true, module(webapi2).torecursive)

    assert.equal(webapi, webapi2)
    assert.equal(webapi, require "testdata.webapi")
  end)
  it("recursive preload", function()
    local webapi = loader("testdata.webapi2", true, true)
    local webapi2 = module("testdata.webapi2").recursive.preload

    assert.equal(true, module("testdata.webapi2").topreload)
    assert.equal(true, module(webapi).topreload)
    assert.equal(true, module(webapi2).topreload)

    assert.equal(true, module("testdata.webapi2").torecursive)
    assert.equal(true, module(webapi).torecursive)
    assert.equal(true, module(webapi2).torecursive)

    assert.equal(webapi, webapi2)
    assert.equal(webapi, require "testdata.webapi2")
  end)
end)
