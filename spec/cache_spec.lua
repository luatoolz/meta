describe('cache', function()
  local meta, cache, no, loader
  setup(function()
    meta = require "meta"
    cache = meta.cache
    no = meta.no
    loader = meta.loader
  end)
  before_each(function()
    assert.equal(0, tonumber(-cache.tester))
  end)
  it("empty", function()
    assert.is_nil(cache.none2.ok)
    cache.none2.other = nil
    assert.is_nil(cache.none2.other)
    _ = -cache.none2
  end)
  it("new from empty", function()
    cache.none.ok = 'ok'
    assert.equal('ok', cache.none.ok)
    cache.none.other = 'done'
    assert.equal('done', cache.none.other)
    cache.none.other = nil
    assert.is_nil(cache.none.other)
  end)
  it("refresh", function()
    assert.is_nil(cache.tester.status)
    cache.tester.status = true
    assert.is_true(cache.tester.status)
    cache.tester = nil
    assert.is_nil(cache.tester.status)
    cache.tester.status = true
    assert.is_true(cache.tester.status)
    _ = cache.refresh.tester
    assert.is_nil(cache.tester.status)
  end)
  it("no normalize", function()
    local tester = cache('tester')
    local ok = {ok=true}
    tester.ok = ok
    tester.status = ok
    tester.other = ok
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.status)
    assert.equal(ok, tester.other)
    assert.is_true(cache.tester.other.ok)
  end)
  it("normalize", function()
    local tester = cache('tester', string.lower)
    local ok = {ok=true}
    tester.OK = ok
    tester.staTus = ok
    assert.equal(ok, tester['OK'])
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.OK)
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.staTus)
    assert.equal(ok, tester.status)
    assert.is_true(cache.tester.status.ok)
  end)
  it("objnormalize", function()
    local tester = cache('objtester')
    local joiner = function(x) return table.concat(x, '.') end
    cache.objnormalize.objtester=joiner
    assert.is_function(cache.objnormalize.objtester)
    assert.equal('1.2.3', joiner({'1','2','3'}))
    assert.equal('x.y.z', joiner({'x','y','z'}))
    local ok = {ok=true}
    tester[{'1','2','3'}]=ok
    tester[{'x','y','z'}]=ok
    assert.equal(ok, tester['1.2.3'])
    assert.equal(ok, tester['x.y.z'])
    assert.equal(ok, tester[{'1','2','3'}])
    assert.equal(ok, tester[{'x','y','z'}])
  end)
  it("create.newindex, new/normalize with string", function()
    cache.tester = {normalize=string.lower, new=string.upper}
    local cc = cache.tester
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, tonumber(-cache.tester))

    cache.tester = {normalize=string.lower, new=string.upper}
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("create.call.i, new/normalize with string", function()
    local cc = cache('tester', {normalize=string.lower, new=string.upper})
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, tonumber(-cache.tester))

    cache('tester', {normalize=string.lower, new=string.upper})
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("create.call.table, new/normalize with string", function()
    local cc = cache('tester', string.lower, string.upper)
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, tonumber(-cache.tester))

    cache('tester', string.lower, string.upper)
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
    cache.tester = nil
    local tester = cache('tester', string.lower)
    local ok = {ok=true}
    tester['ok'] = ok
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.OK)
    assert.equal(string.lower, cache.normalize.tester)
    cache.normalize.tester = nil
    assert.is_nil(cache.normalize.tester)
    cache.normalize.tester = string.upper
    cache.normalize.tester = nil
    assert.is_nil(cache.normalize.tester)
    cache('tester', string.upper)
    assert.equal(string.upper, cache.normalize.tester)
    tester['sOme'] = ok
    tester['anY'] = ok
    tester[ok] = ok
    assert.equal(ok, tester(ok))
    assert.equal(ok, tester['SOME'])
    assert.equal(ok, tester.ANY)
  end)
  it("autocreate if edit nonexistent", function()
    cache.normalize.tester = string.lower
    cache.new.tester = string.upper
    assert.equal(string.lower, cache.normalize.tester)
    assert.equal(string.upper, cache.new.tester)
    assert.equal('OK', cache.tester.ok)
    assert.equal('OK', cache.tester.OK)
    assert.same({ok='OK'}, cache.tester)
    assert.equal('ANY', cache.tester.any)
    assert.same({ok='OK', any='ANY'}, cache.tester)
  end)
  it("ordered", function()
    local roots = cache.ordered.test_roots
    assert.equal(roots, cache.test_roots)
    assert.same({}, roots)
    assert.equal(0, tonumber(roots))
    assert.equal(1, tonumber(roots + 'meta'))
    assert.same({'meta'}, roots)
    roots['t'] = true
    assert.equal(2, tonumber(roots))
    --    assert.equal(2, #roots)
    assert.equal(true, roots['t'])
    assert.same({'meta', 't'}, roots)
    roots['z'] = 'ok'
    assert.equal(3, tonumber(roots))
    assert.equal(true, roots['z'])
    assert.same({'meta', 't', 'z'}, roots)
    assert.equal(2, tonumber(roots - 'z'))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    roots['z'] = nil
    assert.equal(2, tonumber(roots))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    assert.equal(3, tonumber(roots .. {'z'}))
    assert.equal(true, roots['z'])
    assert.same({'meta', 't', 'z'}, roots)
    roots['z'] = nil
    assert.equal(2, tonumber(roots))
    assert.is_nil(roots['z'])
    assert.same({'meta', 't'}, roots)
    assert.equal(3, tonumber(roots .. {'z'}))
    assert.equal(3, tonumber(roots + 'z'))
    assert.equal(3, tonumber(roots .. {}))
    assert.equal(3, tonumber(roots .. nil))
    assert.equal(3, tonumber(roots + nil))
  end)
  it("try", function()
    local toindex = cache.toindex .. {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true, [false] = false}
    cache.try.toindex = function(x) return x, type(x) end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])

    cache.try.toindex=nil
    cache.get.toindex=function(self, k) return self[k] or self[type(k)] or false end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.is_false(toindex[77])
    assert.is_false(toindex[true])
    assert.is_false(toindex[''])
    assert.is_false(toindex[nil])

    cache.try.toindex=nil
    cache.try.toindex = function(x) return x, type(x), false end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.is_false(toindex[77])
    assert.is_false(toindex[true])
    assert.is_false(toindex[''])
    assert.is_false(toindex[nil])
  end)
  it("__unm", function()
    local cc = cache.tester
    cache.new.tester = string.lower
    local _ = cc + 'any'
    assert.equal(1, tonumber(cc))
    assert.equal(0, tonumber(-cc))
    assert.is_nil(cache.new.tester)
    cache.normalize.tester = string.lower
    assert.equal(0, tonumber(-cc))
    assert.is_nil(cache.rawnew.tester)
    for _,it in ipairs({'get','put','call'}) do
      cache[it].tester = rawget
      assert.equal(0, tonumber(-cc))
      assert.is_nil(cache[it].tester)
    end
  end)
  describe("get/put/call", function()
    it("put", function()
      local cc = cache.tester
      cache.put.tester=rawset
      assert.equal(rawset, cache.put.tester)
      cache.tester.x=true
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)

      assert.equal(0, tonumber(-cc))

      cache.put.tester=rawset
      assert.equal(rawset, cache.put.tester)
      cache.tester.x=true
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)
    end)
    it("get", function()
      local cc = cache.tester
      cache.get.tester=rawget
      assert.equal(rawget, cache.get.tester)
      cache.tester.x=true
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)

      assert.equal(0, tonumber(-cc))

      cache.get.tester=rawget
      assert.equal(rawget, cache.get.tester)
      cache.tester.x=true
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)
    end)
    it("call", function()
      local cc = cache.tester
      cache.call.tester=rawset
      assert.equal(rawset, cache.call.tester)
      cache.tester('x', true)
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)

      assert.equal(0, tonumber(-cc))

      cache.call.tester=rawset
      assert.equal(rawset, cache.call.tester)
      cache.tester('x', true)
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)
    end)
    it("all", function()
      local cc = cache.tester
      cache.put.tester  = function(self, k, v) k=tostring(k or ''); rawset(self, '__'..k, type(v)=='number' and v or (tonumber(v) or 1)) end
      cache.get.tester  = function(self, k) local v=rawget(self, '__' .. tostring(k or '')); return type(v)=='number' and v or (tonumber(v) or 1) end
      cache.call.tester = function(self, k) k='__'..tostring(k or ''); rawset(self, k, rawget(self, k)*2) end
      cc.x=1
      assert.equal(1, cc.x)
      assert.equal(1, cc.x)
      cc.y=2
      assert.equal(2, cc.y)
      assert.equal(2, cc.y)
      cc.z=3
      assert.equal(3, cc.z)
      assert.equal(3, cc.z)
      cc('x')
      assert.equal(2, cc.x)
      cc('y')
      assert.equal(4, cc.y)
      cc('z')
      assert.equal(6, cc.z)
      assert.equal(0, tonumber(-cc))
      for _,it in ipairs({'get','put','call'}) do
        assert.is_nil(cache[it].tester)
      end
    end)
    it("all create by call", function()
      local cc = cache('tester', {
        put  = function(self, k, v) k=tostring(k or ''); rawset(self, '__'..k, type(v)=='number' and v or (tonumber(v) or 1)) end,
        get  = function(self, k) local v=rawget(self, '__' .. tostring(k or '')); return type(v)=='number' and v or (tonumber(v) or 1) end,
        call = function(self, k) k='__'..tostring(k or ''); rawset(self, k, rawget(self, k)*2) end,
      })
      cc.x=1
      assert.equal(1, cc.x)
      assert.equal(1, cc.x)
      cc.y=2
      assert.equal(2, cc.y)
      assert.equal(2, cc.y)
      cc.z=3
      assert.equal(3, cc.z)
      assert.equal(3, cc.z)
      cc('x')
      assert.equal(2, cc.x)
      cc('y')
      assert.equal(4, cc.y)
      cc('z')
      assert.equal(6, cc.z)
      assert.equal(0, tonumber(-cc))
      for _,it in ipairs({'get','put','call'}) do
        assert.is_nil(cache[it].tester)
        assert.is_nil(cache[it][cc])
      end
    end)
  end)
end)
