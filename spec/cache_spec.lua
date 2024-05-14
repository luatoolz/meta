describe('cache', function()
  local cache, loader, meta
  setup(function()
    require "compat53"
    meta = require "meta"
    cache = require "meta.cache"
    loader = require "meta.loader"
--    testdata = 'testdata'
--    preload = require "meta.preload"
--    loader = require "meta.loader"
  end)
  it("no normalize", function()
    local tester = cache('tester')
    local ok = {ok=true}
    assert.equal(ok, tester(ok, 'ok', 'status', 'other'))
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.status)
    assert.equal(ok, tester.other)
  end)
  it("normalize", function()
    local tester2 = cache('tester2', string.lower)
    local ok = {ok=true}
    assert.equal(ok, tester2(ok, 'OK', 'staTus'))
    assert.equal(ok, tester2['OK'])
    assert.equal(ok, tester2['ok'])
    assert.equal(ok, tester2.staTus)
    assert.equal(ok, tester2.status)
  end)
  it("check saves from other run", function()
    assert.is_true(cache.tester.other.ok)
    assert.is_true(cache.tester2.status.ok)
  end)
  it("with new", function()
    local cc = cache('loader', nil, loader)
    assert.equal(meta, cc.meta)
    assert.equal(meta, cc(cc.meta, 'loader'))
    assert.equal(meta, cc.loader)
    assert.equal(meta, cc('meta', 'another'))
    assert.equal(meta, cc.another)
  end)
  it("with new as text arg", function()
    local cc = cache('loader2', nil, loader)
    assert.equal(meta, cc('meta', 'another'))
    assert.equal(meta, cc.another)
    assert.equal(meta, cc.meta)
    assert.equal(meta, cc(cc.meta, 'loader'))
    assert.equal(meta, cc.loader)
  end)
  it("no new edit params", function()
    local tester = cache('tester4', string.lower)
    local ok = {ok=true}
    assert.equal(ok, tester(ok, 'OK', 'staTus'))
    assert.equal(ok, tester.OK)
    assert.equal(ok, tester.status)
    cache('tester4', string.upper)
    local ok = {ok=true}
    assert.equal(ok, tester(ok, 'sOme', 'anY'))
    assert.equal(ok, tester.SOME)
    assert.equal(ok, tester.ANY)
  end)
end)
