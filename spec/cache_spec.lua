describe('cache', function()
  local cache, no, loader
  setup(function()
    require "compat53"
    cache = require "meta.cache"
    no = require "meta.no"
    loader = require "meta.loader"
  end)
  before_each(function()
    cache.tester=nil
    cache.new.tester=nil
  end)
  it("new from empty", function()
    cache.none.ok='ok'
    assert.equal('ok', cache.none.ok)
    cache.none.other='done'
    assert.equal('done', cache.none.other)
    cache.none.other=nil
    assert.is_nil(cache.none.other)
  end)
  it("refresh", function()
    assert.is_nil(cache.tester.status)
    cache.tester.status=true
    assert.is_true(cache.tester.status)
    cache.tester=nil
    assert.is_nil(cache.tester.status)
    cache.tester.status=true
    assert.is_true(cache.tester.status)
    _ = cache.refresh.tester
    assert.is_nil(cache.tester.status)
  end)
  it("no normalize", function()
    local tester = cache('tester')
    local ok = {ok=true}
    tester.ok=ok
    tester.status=ok
    tester.other=ok
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.status)
    assert.equal(ok, tester.other)
    assert.is_true(cache.tester.other.ok)
  end)
  it("normalize", function()
    local tester = cache('tester', string.lower)
    local ok = {ok=true}
    tester.OK=ok
    tester.staTus=ok
    assert.equal(ok, tester['OK'])
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.OK)
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.staTus)
    assert.equal(ok, tester.status)
    assert.is_true(cache.tester.status.ok)
  end)
  it("new/normalize with string", function()
    local cc = cache('tester', string.lower, string.upper)
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("new/normalize with object", function()
    local cc = cache('tester', no.sub, loader)
    local meta = require "meta"
    assert.not_nil(cc)
    assert.not_nil(meta)
    assert.equal(meta, cc(meta, 'meta', 'x', 'some'))
    assert.equal(meta, cc.x)
    assert.equal(meta, cc.some or 'fake')
  end)
  it("-new -normalize", function()
    local cc = cache.tester
    assert.not_nil(cc)
    assert.equal(cache, cc(cache, 'x', 'y'))
    assert.equal(cache, cc.x)
    assert.equal(cache, cc.y or 'fake')
  end)
  it("with new", function()
    local sub = cache.sub
    assert.not_nil(sub)
    assert.is_nil(sub(''))
    assert.equal('meta', sub('meta'))
    assert.equal('meta', sub.meta)
    assert.equal('meta/loader', sub(sub.meta, 'loader'))
    assert.equal('loader', sub.loader)
    assert.equal('meta/another', sub('meta', 'another'))
    assert.equal('another', sub.another)
  end)
  it("no new edit params", function()
    cache.tester=nil
    local tester = cache('tester', string.lower)
    local ok = {ok=true}
    tester['ok']=ok
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.OK)
    assert.equal(string.lower, cache.normalize.tester)
    cache.normalize.tester=nil
    assert.is_nil(cache.normalize.tester)
    cache.normalize.tester=string.upper
    cache.normalize.tester=nil
    assert.is_nil(cache.normalize.tester)
    cache('tester', string.upper)
    assert.equal(string.upper, cache.normalize.tester)
    tester['sOme']=ok
    tester['anY']=ok
    tester[ok]=ok
    assert.equal(ok, tester(ok))
    assert.equal(ok, tester['SOME'])
    assert.equal(ok, tester.ANY)
  end)
  it("autocreate if edit nonexistent", function()
    cache.normalize.tester=string.lower
    cache.new.tester=string.upper
    assert.equal(string.lower, cache.normalize.tester)
    assert.equal(string.upper, cache.new.tester)
    assert.equal('OK', cache.tester.ok)
    assert.equal('OK', cache.tester.OK)
  end)
--  it("cache.new[cache.module]", function()
--    local new = cache.new
--    assert.equal({x='2'}, getmetatable(new[cache.module]))
--  end)
end)
