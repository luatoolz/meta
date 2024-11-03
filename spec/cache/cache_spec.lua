describe('cache', function()
  local meta, cache, no, loader, to
  setup(function()
    meta = require "meta"
    cache = meta.cache
    no = meta.no
    loader = meta.loader
    to = {number=function(x) return ((getmetatable(x) or {}).__tonumber or function() return end)(x) end}
  end)
  before_each(function()
    assert.equal(0, to.number(-cache.tester))
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
    assert.truthy(cache.tester/{normalize=string.lower, new=string.upper})
    local cc = cache.tester
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, to.number(-cache.tester))

    assert.truthy(cache.tester/{normalize=string.lower, new=string.upper})
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

    assert.equal(0, to.number(-cache.tester))

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

    assert.equal(0, to.number(-cache.tester))

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
    local sub = cache('tester', no.sub, no.sub)
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
    local root = cache.ordered.test_root
    assert.equal(root, cache.test_root)
    assert.same({}, root)
    assert.equal(0, to.number(root))
    assert.equal(1, to.number(root + 'meta'))
    assert.same({'meta'}, root)
    root['t'] = true
    assert.equal(2, to.number(root))
    --    assert.equal(2, #root)
    assert.equal(true, root['t'])
    assert.same({'meta', 't'}, root)
    root['z'] = 'ok'
    assert.equal(3, to.number(root))
    assert.equal(true, root['z'])
    assert.same({'meta', 't', 'z'}, root)
    assert.equal(2, to.number(root - 'z'))
    assert.is_nil(root['z'])
    assert.same({'meta', 't'}, root)
    root['z'] = nil
    assert.equal(2, to.number(root))
    assert.is_nil(root['z'])
    assert.same({'meta', 't'}, root)
    assert.equal(3, to.number(root .. {'z'}))
    assert.equal(true, root['z'])
    assert.same({'meta', 't', 'z'}, root)
    root['z'] = nil
    assert.equal(2, to.number(root))
    assert.is_nil(root['z'])
    assert.same({'meta', 't'}, root)
    assert.equal(3, to.number(root .. {'z'}))
    assert.equal(3, to.number(root + 'z'))
    assert.equal(3, to.number(root .. {}))
    assert.equal(3, to.number(root .. nil))
    assert.equal(3, to.number(root + nil))
    assert.truthy(-root)
  end)
  it("revordered", function()
    local root = cache.revordered.test_root
    assert.equal(root, cache.test_root)
    assert.equal(true, cache.conf.test_root.ordered)
    assert.equal(true, cache.conf.test_root.rev)
    assert.same({}, root)
    assert.equal(0, to.number(root))
    assert.equal(1, to.number(root + 'meta'))
    assert.same({'meta'}, root)
    root['t'] = true
    assert.equal(2, to.number(root))
    --    assert.equal(2, #root)
    assert.equal(true, root['t'])
    assert.same({'t', 'meta'}, root)
    root['z'] = 'ok'
    assert.equal(3, to.number(root))
    assert.equal(true, root['z'])
    assert.same({'z', 't', 'meta'}, root)
    assert.equal(2, to.number(root - 't'))
    assert.is_nil(root['t'])
    assert.same({'z', 'meta'}, root)
    root['t'] = nil
    assert.equal(2, to.number(root))
    assert.is_nil(root['t'])
    assert.same({'z', 'meta'}, root)
    assert.equal(3, to.number(root .. {'t'}))
    assert.equal(true, root['z'])
    assert.same({'t', 'z', 'meta'}, root)
    root['z'] = nil
    assert.equal(2, to.number(root))
    assert.is_nil(root['z'])
    assert.same({'t', 'meta'}, root)
    assert.equal(3, to.number(root .. {'z'}))
    assert.equal(3, to.number(root + 'z'))
    assert.equal(3, to.number(root .. {}))
    assert.equal(3, to.number(root .. nil))
    assert.equal(3, to.number(root + nil))
    assert.truthy(-root)
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
    cache.toindex=nil

    toindex = cache.toindex/{try=type}
    cache.toindex = {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])
    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])
    cache.toindex=nil

    toindex = cache.toindex/{try=type} .. {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])
    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])
  end)
  it("try root", function()
    local root = cache.root
    assert.callable(cache.conf.root.try)
    assert.equal('meta', root.meta)
    assert.equal('meta', root['meta.loader'])
  end)
  it("__unm", function()
    local cc = cache.tester
    cache.new.tester = string.lower
    local _ = cc + 'any'
    assert.equal(1, to.number(cc))
    assert.equal(0, to.number(-cc))
    assert.is_nil(cache.new.tester)
    cache.normalize.tester = string.lower
    assert.equal(0, to.number(-cc))
    assert.is_nil(cache.rawnew.tester)
    for _,it in ipairs({'get','put','call'}) do
      cache[it].tester = rawget
      assert.equal(0, to.number(-cc))
      assert.is_nil(cache[it].tester)
    end
  end)
  describe("conf/get/put/call", function()
    it("conf", function()
      local conf = {
        normalize = string.lower,
        new = string.upper,
        ordered = true,}
      assert.same({}, cache.conf.tester)
      cache.conf.tester=conf
      assert.equal(string.lower, cache.normalize.tester)
      assert.equal(string.upper, cache.new.tester)
      assert.same(conf, cache.conf.tester)
      cache.tester=nil
      assert.same({}, cache.conf.tester)
    end)
    it("put", function()
      local cc = cache.tester
      cache.put.tester=rawset
      assert.equal(rawset, cache.put.tester)
      cache.tester.x=true
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)

      assert.equal(0, to.number(-cc))

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

      assert.equal(0, to.number(-cc))

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

      assert.equal(0, to.number(-cc))

      cache.call.tester=rawset
      assert.equal(rawset, cache.call.tester)
      cache.tester('x', true)
      assert.equal(true, cache.tester.x)
      assert.equal(true, cache[cc].x)
    end)
    it("all", function()
      local cc = cache.tester
      cache.put.tester  = function(self, k, v) k=tostring(k or ''); rawset(self, '__'..k, type(v)=='number' and v or (to.number(v) or 1)) end
      cache.get.tester  = function(self, k) local v=rawget(self, '__' .. tostring(k or '')); return type(v)=='number' and v or (to.number(v) or 1) end
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
      assert.equal(0, to.number(-cc))
      for _,it in ipairs({'get','put','call'}) do
        assert.is_nil(cache[it].tester)
      end
    end)
    it("all create by call", function()
      local cc = cache('tester', {
        put  = function(self, k, v) k=tostring(k or ''); rawset(self, '__'..k, type(v)=='number' and v or (to.number(v) or 1)) end,
        get  = function(self, k) local v=rawget(self, '__' .. tostring(k or '')); return type(v)=='number' and v or (to.number(v) or 1) end,
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
      assert.equal(0, to.number(-cc))
      for _,it in ipairs({'get','put','call'}) do
        assert.is_nil(cache[it].tester)
        assert.is_nil(cache[it][cc])
      end
    end)
  end)
  describe("getter/setter/caller", function()
    it("getter/setter", function()
      assert.truthy(cache.tester/{normalize = string.upper})
      local get, set = cache.getter.tester, cache.setter.tester
      assert.equal(cache.getter.tester, get)
      assert.equal(cache.setter.tester, set)
      set('ok', 'super')
      assert.equal('super', cache.tester.ok)
      assert.equal('super', get('ok'))
      set('ok', nil)
      assert.is_nil(get('ok'))
      assert.is_nil(cache.tester.ok)
      cache.tester=nil
    end)
    it("adder/remover", function()
      assert.truthy(cache.tester/{normalize = string.upper, new = string.trim})
      local add, rm, get, exists = cache.adder.tester, cache.remover.tester, cache.getter.tester, cache.existing.tester
      assert.equal(cache.adder.tester, add)
      assert.equal(cache.remover.tester, rm)
      assert.equal(cache.getter.tester, get)
      assert.is_nil(exists('ok'))
      add(' ok ')
      assert.equal('OK', cache.tester.ok)
      assert.equal('OK', get('ok'))
      assert.equal('OK', exists('ok'))
      rm('ok')
      assert.is_nil(exists('ok'))
      cache.tester=nil
    end)
    it("caller", function()
      assert.truthy(cache.tester/{call=function(_, ...) return string.upper(...) end})
      local call = cache.caller.tester
      assert.equal(cache.caller.tester, call)
      assert.equal('SUPER', call('super'))
      cache.tester=nil
    end)
  end)
end)