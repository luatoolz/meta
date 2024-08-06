describe('cache', function()
  local meta, cache, no, loader
  setup(function()
    require "compat53"
    meta = require "meta"
    cache = meta.cache
    no = meta.no
    loader = meta.loader
  end)
  before_each(function()
    cache.tester=nil
    cache.new.tester=nil
    cache.rawnew.tester=nil
  end)
  it("empty", function()
    assert.is_nil(cache.none2.ok)
    cache.none2.other=nil
    assert.is_nil(cache.none2.other)
    _ = -cache.none2
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
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("new/normalize with string __pow", function()
    local cc = cache('tester', string.lower)
    _ = cc ^ string.upper
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
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
  it("-new -normalize __concat", function()
    local cc = cache.tester
    assert.not_nil(cc)
    assert.equal(cc, cc .. {x=true, y=true})
    assert.equal(true, cc.x)
    assert.equal(true, cc.y)
    assert.equal(cc, cc .. {'a', 'b'})
    assert.equal(true, cc.a)
    assert.equal(true, cc.b)
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
    assert.same({ok='OK'}, cache.tester)
    assert.equal('ANY', cache.tester.any)
    assert.same({ok='OK',any='ANY'}, cache.tester)
  end)
  it("ordered", function()
    local roots = cache.ordered.test_roots
    assert.equal(roots, cache.test_roots)
    assert.same({}, roots)
		assert.equal(0, tonumber(roots))
    assert.equal(1, tonumber(roots + 'meta'))
    assert.same({'meta'}, roots)
    roots['t']=true
    assert.equal(2, tonumber(roots))
--    assert.equal(2, #roots)
    assert.equal(true, roots['t'])
    assert.same({'meta', 't'}, roots)
    roots['z']='ok'
    assert.equal(3, tonumber(roots))
    assert.equal(true, roots['z'])
    assert.same({'meta', 't', 'z'}, roots)
    assert.equal(2, tonumber(roots-'z'))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    roots['z']=nil
    assert.equal(2, tonumber(roots))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    assert.equal(3, tonumber(roots .. {'z'}))
    assert.equal(true, roots['z'])
    assert.same({'meta', 't', 'z'}, roots)
    roots['z']=nil
    assert.equal(2, tonumber(roots))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    assert.equal(3, tonumber(roots .. {'z'}))
    assert.equal(3, tonumber(roots + 'z'))
    assert.equal(3, tonumber(roots .. {}))
    assert.equal(3, tonumber(roots .. nil))
    assert.equal(3, tonumber(roots + nil))
  end)
end)
