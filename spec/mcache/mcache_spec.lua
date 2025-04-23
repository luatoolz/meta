describe('mcache', function()
  local meta, mcache, sub, loader, to
  setup(function()
    meta = require "meta"
    mcache = meta.mcache
    sub = require "meta.module.sub"
    loader = meta.loader
    to = {number=function(x) return ((getmetatable(x) or {}).__tonumber or function() return end)(x) end}
  end)
  before_each(function()
    assert.equal(0, to.number(-mcache.tester))
  end)
  it("empty", function()
    assert.is_nil(mcache.none2.ok)
    mcache.none2.other = nil
    assert.is_nil(mcache.none2.other)
    _ = -mcache.none2
  end)
  it("new from empty", function()
    mcache.none.ok = 'ok'
    assert.equal('ok', mcache.none.ok)
    mcache.none.other = 'done'
    assert.equal('done', mcache.none.other)
    mcache.none.other = nil
    assert.is_nil(mcache.none.other)
  end)
  it("refresh", function()
    assert.is_nil(mcache.tester.status)
    mcache.tester.status = true
    assert.is_true(mcache.tester.status)
    mcache.tester = nil
    assert.is_nil(mcache.tester.status)
    mcache.tester.status = true
    assert.is_true(mcache.tester.status)
    _ = mcache.refresh.tester
    assert.is_nil(mcache.tester.status)
  end)
  it("no normalize", function()
    local tester = mcache('tester')
    local ok = {ok=true}
    tester.ok = ok
    tester.status = ok
    tester.other = ok
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.status)
    assert.equal(ok, tester.other)
    assert.is_true(mcache.tester.other.ok)
  end)
  it("normalize", function()
    local tester = mcache('tester', string.lower)
    local ok = {ok=true}
    tester.OK = ok
    tester.staTus = ok
    assert.equal(ok, tester['OK'])
    assert.equal(ok, tester['ok'])
    assert.equal(ok, tester.OK)
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.staTus)
    assert.equal(ok, tester.status)
    assert.is_true(mcache.tester.status.ok)
  end)
  it("objnormalize", function()
    local tester = mcache('objtester')
    local joiner = function(x) return table.concat(x, '.') end
    mcache.objnormalize.objtester=joiner
    assert.is_function(mcache.objnormalize.objtester)
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
    assert.truthy(mcache.tester/{normalize=string.lower, new=string.upper})
    local cc = mcache.tester
    assert.not_nil(cc)
    local no = mcache
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, to.number(-mcache.tester))

    assert.truthy(mcache.tester/{normalize=string.lower, new=string.upper})
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("create.call.i, new/normalize with string", function()
    local cc = mcache('tester', {normalize=string.lower, new=string.upper})
    assert.not_nil(cc)
    local no = mcache
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, to.number(-mcache.tester))

    mcache('tester', {normalize=string.lower, new=string.upper})
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("create.call.table, new/normalize with string", function()
    local cc = mcache('tester', string.lower, string.upper)
    assert.not_nil(cc)
    local no = mcache
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')

    assert.equal(0, to.number(-mcache.tester))

    mcache('tester', string.lower, string.upper)
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("new/normalize with string __pow", function()
    local cc = mcache('tester', string.lower)
    local no = mcache
    _ = cc ^ string.upper
    assert.not_nil(cc)
    assert.equal(no, cc(no, 'x', 'some'))
    assert.equal(no, cc.X)
    assert.equal(no, cc.x)
    assert.equal(no, cc.some or 'fake')
  end)
  it("new/normalize with object", function()
    local cc = mcache('tester', sub, loader)
    assert.not_nil(cc)
    assert.not_nil(meta)
    assert.equal(meta, cc(meta, 'meta', 'x', 'some'))
    assert.equal(meta, cc.x)
    assert.equal(meta, cc.some or 'fake')
  end)
  it("-new -normalize", function()
    local cc = mcache.tester
    assert.not_nil(cc)
    assert.equal(mcache, cc(mcache, 'x', 'y'))
    assert.equal(mcache, cc.x)
    assert.equal(mcache, cc.y or 'fake')
  end)
  it("-new -normalize __concat", function()
    local cc = mcache.tester
    assert.not_nil(cc)
    assert.equal(cc, cc .. {x=true, y=true})
    assert.equal(true, cc.x)
    assert.equal(true, cc.y)
    assert.equal(cc, cc .. {'a', 'b'})
    assert.equal(true, cc.a)
    assert.equal(true, cc.b)
  end)
  it("with new", function()
    local nsub = mcache('tester', sub, sub)
    assert.not_nil(nsub)
    assert.is_nil(nsub(''))
    assert.equal('meta', nsub('meta'))
    assert.equal('meta', nsub.meta)
    assert.equal('meta/loader', nsub(nsub.meta, 'loader'))
    assert.equal('loader', nsub.loader)
    assert.equal('meta/another', nsub('meta', 'another'))
    assert.equal('another', nsub.another)
  end)
  it("no new edit params", function()
    mcache.tester = nil
    local tester = mcache('tester', string.lower)
    local ok = {ok=true}
    tester['ok'] = ok
    assert.equal(ok, tester.ok)
    assert.equal(ok, tester.OK)
    assert.equal(string.lower, mcache.normalize.tester)
    mcache.normalize.tester = nil
    assert.is_nil(mcache.normalize.tester)
    mcache.normalize.tester = string.upper
    mcache.normalize.tester = nil
    assert.is_nil(mcache.normalize.tester)
    mcache('tester', string.upper)
    assert.equal(string.upper, mcache.normalize.tester)
    tester['sOme'] = ok
    tester['anY'] = ok
    tester[ok] = ok
    assert.equal(ok, tester(ok))
    assert.equal(ok, tester['SOME'])
    assert.equal(ok, tester.ANY)
  end)
  it("autocreate if edit nonexistent", function()
    mcache.normalize.tester = string.lower
    mcache.new.tester = string.upper
    assert.equal(string.lower, mcache.normalize.tester)
    assert.equal(string.upper, mcache.new.tester)
    assert.equal('OK', mcache.tester.ok)
    assert.equal('OK', mcache.tester.OK)
    assert.same({ok='OK'}, mcache.tester)
    assert.equal('ANY', mcache.tester.any)
    assert.same({ok='OK', any='ANY'}, mcache.tester)
  end)
  it("ordered", function()
    local root = mcache.ordered.test_root
    assert.equal(root, mcache.test_root)
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
    assert.equal(0, to.number(root))
  end)
  it("revordered", function()
    assert.truthy(-mcache.test_root)
    local root = mcache.revordered.test_root
    assert.equal(0, to.number(root))
    assert.equal(root, mcache.test_root)
    assert.equal(true, mcache.conf.test_root.ordered)
    assert.equal(true, mcache.conf.test_root.rev)
    assert.same({}, root)
--    assert.equal('', root)
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
    local toindex = mcache.toindex .. {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true, [false] = false}
    mcache.try.toindex = function(x) return x, type(x) end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])

    mcache.try.toindex=nil
    mcache.get.toindex=function(self, k) return self[k] or self[type(k)] or false end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.is_false(toindex[77])
    assert.is_false(toindex[true])
    assert.is_false(toindex[''])
    assert.is_false(toindex[nil])

    mcache.try.toindex=nil
    mcache.try.toindex = function(x) return x, type(x), false end
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])

    assert.is_false(toindex[77])
    assert.is_false(toindex[true])
    assert.is_false(toindex[''])
    assert.is_false(toindex[nil])
    mcache.toindex=nil

    toindex = mcache.toindex/{try=type}
    mcache.toindex = {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])
    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])
    mcache.toindex=nil

    toindex = mcache.toindex/{try=type} .. {['function'] = true, ['table'] = true, ['userdata'] = true, ['CFunction'] = true}
    assert.is_true(toindex[{}])
    assert.is_true(toindex[type])
    assert.falsy(toindex[77])
    assert.falsy(toindex[true])
    assert.falsy(toindex[''])
    assert.falsy(toindex[nil])
  end)
  it("try root", function()
    local _ = mcache.xtest/{try=string.lower}
    assert.callable(mcache.conf.xtest.try)
    assert.truthy(-mcache.xtest)
  end)
  it("__unm", function()
    local cc = mcache.tester
    mcache.new.tester = string.lower
    local _ = cc + 'any'
    assert.equal(1, to.number(cc))
    assert.equal(0, to.number(-cc))
    assert.is_nil(mcache.new.tester)
    mcache.normalize.tester = string.lower
    assert.equal(0, to.number(-cc))
    assert.is_nil(mcache.rawnew.tester)
    for _,it in ipairs({'get','put','call'}) do
      mcache[it].tester = rawget
      assert.equal(0, to.number(-cc))
      assert.is_nil(mcache[it].tester)
    end
  end)
  describe("conf/get/put/call", function()
    it("conf", function()
      local conf = {
        name='tester',
        normalize = string.lower,
        new = string.upper,
        ordered = true,}
      assert.same({name='tester'}, mcache.conf.tester)
      mcache.conf.tester=conf
      assert.equal(string.lower, mcache.normalize.tester)
      assert.equal(string.upper, mcache.new.tester)
      assert.same(conf, mcache.conf.tester)
      mcache.tester=nil
      assert.same({name='tester'}, mcache.conf.tester)
    end)
    it("put", function()
      local cc = mcache.tester
      mcache.put.tester=rawset
      assert.equal(rawset, mcache.put.tester)
      mcache.tester.x=true
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)

      assert.equal(0, to.number(-cc))

      mcache.put.tester=rawset
      assert.equal(rawset, mcache.put.tester)
      mcache.tester.x=true
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)
    end)
    it("get", function()
      local cc = mcache.tester
      mcache.get.tester=rawget
      assert.equal(rawget, mcache.get.tester)
      mcache.tester.x=true
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)

      assert.equal(0, to.number(-cc))

      mcache.get.tester=rawget
      assert.equal(rawget, mcache.get.tester)
      mcache.tester.x=true
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)
    end)
    it("call", function()
      local cc = mcache.tester
      mcache.call.tester=rawset
      assert.equal(rawset, mcache.call.tester)
      mcache.tester('x', true)
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)

      assert.equal(0, to.number(-cc))

      mcache.call.tester=rawset
      assert.equal(rawset, mcache.call.tester)
      mcache.tester('x', true)
      assert.equal(true, mcache.tester.x)
      assert.equal(true, mcache[cc].x)
    end)
    it("all", function()
      local cc = mcache.tester
      mcache.put.tester  = function(self, k, v) k=tostring(k or ''); rawset(self, '__'..k, type(v)=='number' and v or (to.number(v) or 1)) end
      mcache.get.tester  = function(self, k) local v=rawget(self, '__' .. tostring(k or '')); return type(v)=='number' and v or (to.number(v) or 1) end
      mcache.call.tester = function(self, k) k='__'..tostring(k or ''); rawset(self, k, rawget(self, k)*2) end
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
        assert.is_nil(mcache[it].tester)
      end
    end)
    it("all create by call", function()
      local cc = mcache('tester', {
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
        assert.is_nil(mcache[it].tester)
        assert.is_nil(mcache[it][cc])
      end
    end)
  end)
  describe("getter/setter/caller", function()
    it("getter/setter", function()
      assert.truthy(mcache.tester/{normalize = string.upper})
      local get, set = mcache.getter.tester, mcache.setter.tester
      assert.equal(mcache.getter.tester, get)
      assert.equal(mcache.setter.tester, set)
      set('ok', 'super')
      assert.equal('super', mcache.tester.ok)
      assert.equal('super', get('ok'))
      set('ok', nil)
      assert.is_nil(get('ok'))
      assert.is_nil(mcache.tester.ok)
      mcache.tester=nil
    end)
    it("adder/remover", function()
      assert.truthy(mcache.tester/{normalize = string.upper, new = string.trim})
      local add, rm, get, exists = mcache.adder.tester, mcache.remover.tester, mcache.getter.tester, mcache.existing.tester
      assert.equal(mcache.adder.tester, add)
      assert.equal(mcache.remover.tester, rm)
      assert.equal(mcache.getter.tester, get)
      assert.is_nil(exists('ok'))
      add(' ok ')
      assert.equal('OK', mcache.tester.ok)
      assert.equal('OK', get('ok'))
      assert.equal('OK', exists('ok'))
      rm('ok')
      assert.is_nil(exists('ok'))
      mcache.tester=nil
    end)
    it("caller", function()
      assert.truthy(mcache.tester/{call=function(_, ...) return string.upper(...) end})
      local call = mcache.caller.tester
      assert.equal(mcache.caller.tester, call)
      assert.equal('SUPER', call('super'))
      mcache.tester=nil
    end)
  end)
end)