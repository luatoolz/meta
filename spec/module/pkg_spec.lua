describe('pkg', function()
  local module, pkg, iter, number, is
  setup(function()
    require('meta')
    iter    = require 'meta.iter'
    module  = require 'meta.module'
    pkg     = require 'meta.pkg'
    number  = require 'meta.number'
    is      = require 'meta.is'
    _       = pkg ^ 'testdata'
  end)
  teardown(function()
    _ = pkg('testdata') ^ false
  end)
  describe("new", function()
    it("pkg", function()
      assert.equal('meta/number', tostring(pkg('meta/number')))
      assert.equal('meta/number', tostring(pkg(number)))

      assert.equal('meta/is', tostring(pkg('meta/is')))
      assert.equal('meta/is', tostring(pkg(is)))

      assert.equal('meta/is/number', tostring(pkg(is, 'number')))
      assert.equal('pkg', getmetatable(pkg(is, 'number')).__name)

--      _ = is ^ 't'
--      assert.truthy(number.abbrev)
--      _ = module('t') ^ false
    end)
    it("__tostring", function()
      assert.equal('', tostring(pkg))
      assert.equal('testdata', pkg('testdata')['.'])
      assert.equal('testdata', tostring(pkg('testdata')))
      assert.equal('testdata/files', tostring(pkg('testdata/files')))
    end)
    it("__concat", function()
      assert.equal(pkg, pkg+nil)
      assert.equal(pkg('meta'), pkg('meta')..nil)
      assert.equal(pkg('meta'), pkg('meta')..'')
      assert.equal(pkg('meta'), pkg..'meta')

      assert.equal(pkg('meta/mcache'), pkg('meta')..'mcache')

      assert.equal(pkg('meta/assert.d'), pkg('meta')..'assert.d')
      assert.equal(pkg('meta/assert.d'), pkg..'meta/assert.d')

      assert.equal(pkg('testdata/assert.d'), pkg('testdata')..'assert.d')
      assert.equal(pkg('testdata/assert.d'), pkg..'testdata/assert.d')
    end)
    it("__add", function()
      assert.equal('meta', tostring(pkg('meta/module')+'..'))
      assert.equal('meta/module', tostring(pkg('meta')+'module'))

      assert.equal(pkg('meta/module'), pkg('meta')+'module')
      assert.equal(pkg('meta'), pkg('meta/module')+'..')
      assert.equal(pkg('meta'), pkg('meta/module')['..'])
    end)
    it("__index", function()
      assert.equal(module, pkg('meta').module)
    end)
  end)
  it("#pkg", function()
    assert.equal(1, #pkg('meta'))
    assert.equal(2, #pkg('meta/module'))
    assert.equal(3, #pkg('meta/is/number'))
  end)
  it("chain", function()
    local chain = require 'meta.module.chain'
    assert.same(table()..{'testdata','meta'}, table()..chain)
  end)
  it("__iter", function()
    assert.keys({'a', 'b', 'c', 'i'}, table.map(pkg('testdata/files')))
    assert.keys({'a', 'b', 'c', 'i'}, {} .. iter(pkg('testdata/files')))
    assert.keys({'a', 'b', 'c', 'i'}, table() .. iter(pkg('testdata/files')))
    assert.keys({'a', 'b', 'c', 'i'}, pkg('testdata/files')*nil)
  end)
  it("__mul / __mod", function()
    local tt = function(x) return type(x) end
    local ok = function(x) return x and true or false end
    local isn = function(x) x=x or {}; return type(x[1]) == 'number' end

    assert.equal('nil', tt())

    local ltf = pkg('testdata/files')

    assert.equal('table', type(ltf.a))
    assert.same({a='table', b='table', c='table', i='table'}, ltf * type)

    local l = pkg('testdata/asserts.d')
    assert.keys({'callable', 'ends', 'instance', 'has_key', 'has_value', 'indexable', 'iterable', 'keys', 'like', 'loader', 'module_name', 'mtname', 'similar', 'type', 'values'}, l*ok)
    assert.same({callable=true, ends=true, instance=true, has_key=true, has_value=true, indexable=true, iterable=true, keys=true, like=true, loader=true, module_name=true, mtname=true, similar=true, type=true, values=true}, l*ok)
    assert.same({callable="table", ends="table", instance="table", has_key="table", has_value="table", indexable="table", iterable="table", keys="table", like="table", loader="table", module_name="table", mtname='table', similar="table",
                type="table", values="table"}, l*tt)
    assert.same({callable=true, ends=false, instance=false, has_key=true, has_value=true, indexable=true, iterable=true,keys=true, like=true, loader=true, module_name=true, mtname=true, similar=true, type=false, values=true}, l*isn)
    assert.keys({'callable', 'ends', 'instance', 'has_key', 'has_value', 'indexable', 'iterable', 'keys', 'like', 'loader', 'module_name', 'mtname', 'similar', 'type', 'values'}, l * isn)

    local empty = pkg('testdata/init2/dir')
    local def = pkg('testdata/assert.d')

    assert.same({}, {}..iter(iter.pairs(empty)))
    assert.same({}, table()..iter.pairs(empty))
    assert.same({}, empty * type)

    assert.is_table(def)
    assert.is_table(def * type)
  end)
  it("handler", function()
    local l = pkg('testdata/dir') ^ type
    assert.equal(type, (-l).handler)
--    assert.equal('boolean', l.aa)
    assert.equal('table', l.a)
    assert.equal('function', l.b)
  end)
end)