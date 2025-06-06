describe("set", function()
  local meta, set, number, map
  setup(function()
    meta = require 'meta'
    set = require 'meta.set'
    number = meta.number
    map = table.map
  end)
  describe("create", function()
    it("nil", function()
      assert.equal(set, meta.set)
      assert.is_table(set())
      assert.is_table(set({}))
      assert.same(set(), set({}))
      assert.is_nil(set()['a'])
      assert.is_nil(set()[''])
      assert.is_nil(set()[0])
      assert.is_nil(set()[nil])
    end)
    it("nil operations", function()
      assert.equal(set(), set() .. set())
      assert.equal(set(), set() + set())
      assert.equal(set(), set() - set())
      assert.equal(true, set() <= set())
      assert.equal(true, set() >= set())
      assert.equal(true, set() == set())
    end)
    it("1+nil operations", function()
      assert.equal(set('a'), set('a') + set())
      assert.equal(set('a'), set('a') + set('a'))
      assert.equal(set('a'), set() + set('a'))
      assert.equal(set('a'), set('a') .. set())
      assert.equal(set('a'), set('a') .. set('a'))
      assert.equal(set('a'), set() .. set('a'))
      assert.equal(set('a'), set('a') - set())
      assert.equal(set(), set('a') - set('a'))
      assert.equal(set(), set() - set('a'))
      assert.equal(set(), set() * set('a'))
    end)
    it("1+1+nil operations", function()
      assert.equal(set('a', 'b'), set('a') + set('b'))
      assert.equal(set('a', 'b'), set('b') + set('a'))
      assert.equal(set('a', 'b'), set('a') .. set('b'))
      assert.equal(set('a', 'b'), set('b') .. set('a'))
      assert.equal(set('a', 'b'), set('a', 'b') - set())
      assert.equal(set('b'), set('a', 'b') - set('a'))
      assert.equal(set(), set('a', 'b') - set('a', 'b'))
    end)
    it("2+ operations", function()
      assert.equal(set('a', 'b'), set('a', 'b') + set('b', 'a'))
      assert.equal(set('a', 'b'), set('b', 'a') + set('a', 'b'))
      assert.equal(set('a', 'b'), set('a', 'b') .. set('b', 'a'))
      assert.equal(set('a', 'b'), set('b', 'a') .. set('a', 'b'))
      assert.equal(set('a', 'b'), set('a', 'b') - set())
      assert.equal(set('b'), set('a', 'b') - set('a'))
      assert.equal(set(), set('a', 'b') - set('a', 'b'))
    end)
  end)
  it("regular operations", function()
    assert.equal(set(set('a', 'b', 'c')), map(set('a', 'b', 'c')))
    assert.equal('a', set('a')['a'])
  end)
  it("of", function()
    assert.equal(set(1, 7, 88), set('1', '7', '88', '1')*number)
  end)
  it("compare", function()
    assert.is_true(set('a', 'b', 'c') <= set('a', 'b', 'c', 'd'))
    assert.is_true(set('a', 'd', 'b', 'c') <= set('a', 'b', 'c', 'd'))
    assert.is_true(set('a', 'd', 'b', 'c') == set('a', 'b', 'c', 'd'))
  end)
  it("__add + __sub", function()
    assert.equal(set('b') + 'c', set('a', 'b', 'c')-'a')
  end)
  it("__pairs", function()
    local s = set('a', 'b', 'c')
    local rv = set()
    for v in pairs(s) do _=rv+v end
    assert.equal(rv, s)
    assert.equal(set(map(set('a', 'b', 'c'))), set('a', 'b', 'c'))
  end)
  it("__mul", function()
    assert.equal(set(2, 14, 176), set('1', '7', '88') * function(x) return number(x)*2,nil end)
    assert.equal(set(2, 14, 176), set('2', '14', '176') * number)
  end)
  it("__mod", function()
    assert.equal(set('88'), set('1', '7', '88') % function(x) return number(x)>50 end)
    assert.equal(set(88), set(88)+'aaq')
  end)
  it("__div", function()
    assert.truthy(set('1', '7', '88', '90', '56') / function(x) return number(x)>50 end)
    assert.equal('56', set('1', '7', '88', '90', '56') / '56')
  end)
  it("__tostring", function()
    assert.equal(set{'1', '7'}, set(1,7)*tostring)
  end)
--[[
  it("__export", function()
    local tex=t.exporter
    assert.values({}, tex(set()))
    assert.values({}, tex(set({})))
    assert.values({'a'}, tex(set('a')))
    assert.values({'a', 'b', 'c', 'd'}, tex(set('a', 'b', 'c', 'd')))
  end)
--]]
end)