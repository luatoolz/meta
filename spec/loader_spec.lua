describe('loader', function()
  local meta, mcache, loader, module, tl
  setup(function()
    meta = require('meta')
    mcache  = require 'meta.mcache'
    loader  = require 'meta.loader'
    module  = require 'meta.module'
    _       = module ^ 'testdata'
    tl      = require('testdata/loader2')
  end)
  teardown(function()
    _ = module('testdata') ^ false
  end)
  it("ok", function()
    assert.is_table(mcache)
    assert.is_table(tl)
    assert.is_not_nil(tl.ok)
    assert.equal('ok', tl.ok.message.data)
    local q = tl.ok
    assert.equal('ok', q.message.data)
  end)
  it("eq meta", function()
    assert.equal(getmetatable(meta), getmetatable(meta.loader))
    assert.equal(getmetatable(meta), getmetatable(require("meta")))
    assert.equal(getmetatable(meta), getmetatable(mcache.new.loader))
    assert.equal(getmetatable(mcache.new.loader), getmetatable(require("meta")))
    assert.equal(getmetatable(meta), getmetatable(mcache.new.loader))
    assert.equal(getmetatable(require("meta")), getmetatable(loader("meta")))
  end)
  it("eq loader", function()
    assert.equal(loader('testdata/loader2/noinit'), loader('testdata/loader2/noinit'))
    assert.equal(loader('testdata/req/ok'), loader('testdata/req/ok'))
    assert.equal(loader('testdata/req/ok'), loader(loader('testdata/req/ok')))
  end)
  it("module.loader", function()
    local noinit = tl.noinit
    assert.is_table(noinit)
    assert.loader(noinit)

    local chain = require 'meta.module.chain'
    assert.same(table()..{'testdata','meta'}, table()..chain)

    assert.equal('ok', noinit.message.data)
    assert.is_table(noinit['ok.message'])
    assert.equal('ok', noinit['ok.message'].data)
  end)
  it("req", function()
    local req = require "testdata/req"
    assert.is_table(req)
    assert.is_nil(rawget(req, 'ok'))
    local req_ok = require "testdata/req/ok"
    assert.is_table(req_ok)
    assert.is_table(loader["testdata/req/ok"])
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
  it("noinit", function()
    tl = require "testdata.loader2"
    assert.is_not_nil(tl)
    assert.is_table(tl)
    assert.is_not_nil(tl.noinit)
    assert.equal('table', type(tl.noinit))
    assert.equal('ok', tl.noinit['ok.message'].data)
    assert.equal('ok', tl.noinit.message.data)
  end)
  it("__iter", function()
    local iter = require 'meta.iter'
    local selector = require 'meta.selector'
    local pkgdirs = module.pkgdirs
    assert.has_value('lua', pkgdirs * selector[1] * tostring)
    assert.has_value('', pkgdirs * selector[1] * tostring)
    assert.keys({'a', 'b', 'c', 'i'}, table.map(loader('testdata.files')))
    assert.keys({'a', 'b', 'c', 'i'}, {} .. iter(loader('testdata.files')))
    assert.keys({'a', 'b', 'c', 'i'}, table() .. iter(loader('testdata.files')))
    assert.keys({'a', 'b', 'c', 'i'}, loader('testdata.files')*nil)
  end)
  it("__mul / __mod", function()
    local tt = function(x) return type(x) end
    local ok = function(x) return x and true or false end
    local isn = function(x) x=x or {}; return type(x[1]) == 'number' end

    assert.equal('nil', tt())

    local ltf = loader('testdata/files')

    assert.equal('table', type(ltf.a))
    assert.same({a='table', b='table', c='table', i='table'}, table()..ltf * type)

    local l = loader('testdata/asserts.d')
    assert.keys({'callable', 'ends', 'instance', 'has_key', 'has_value', 'indexable', 'iterable', 'keys', 'like', 'loader', 'module_name', 'mtname', 'similar', 'type', 'values'}, l*ok)
    assert.same({callable=true, ends=true, instance=true, has_key=true, has_value=true, indexable=true, iterable=true, keys=true, like=true, loader=true, module_name=true, mtname=true, similar=true, type=true, values=true}, l*ok)
    assert.same({callable="table", ends="table", instance="table", has_key="table", has_value="table", indexable="table", iterable="table", keys="table", like="table", loader="table", module_name="table", mtname='table', similar="table",
                type="table", values="table"}, l*tt)
    assert.same({callable=true, ends=false, instance=false, has_key=true, has_value=true, indexable=true, iterable=true,keys=true, like=true, loader=true, module_name=true, mtname=true, similar=true, type=false, values=true}, l*isn)
    assert.keys({'callable', 'ends', 'instance', 'has_key', 'has_value', 'indexable', 'iterable', 'keys', 'like', 'loader', 'module_name', 'mtname', 'similar', 'type', 'values'}, l * isn)

    local empty = loader('testdata/init2/dir')
    local def = loader('testdata/assert.d')
    assert.same({}, empty)
    assert.same({}, empty * type)

    assert.is_table(def)
    assert.is_table(def * type)
  end)
  it("handler", function()
    local l = loader('testdata.dir') ^ type
    assert.equal(type, module(l).handler)
    assert.equal('table', l.a)
    assert.equal('function', l.b)
    assert.loader(l)
  end)
end)