describe("iter.reduce", function()
  local meta, is, iter
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.reduce))
  end)
  it("positive", function()
    assert.equal(6, iter.reduce({1, 2, 3}, function(a, b) return a+b end, 0))
    assert.equal(6, iter.reduce({1, 2, 3}, function(a, b) return a+b end))

    assert.equal(3, iter.reduce({1, 2}, function(a, b) return a+b end, 0))
    assert.equal(3, iter.reduce({1, 2}, function(a, b) return a+b end))

    assert.equal(1, iter.reduce({1}, function(a, b) return a+b end, 0))
    assert.equal(1, iter.reduce({1}, function(a, b) return a+b end))

    assert.equal(0, iter.reduce({}, function(a, b) return a+b end, 0))
    assert.is_nil(iter.reduce({}, function(a, b) return a+b end))
  end)
  it("common operations", function()
    assert.equal(0, iter.count({}))
    assert.equal(1, iter.count({'a'}))
    assert.equal(2, iter.count({'a','b'}))
    assert.equal(3, iter.count({'a','b','c'}))
    assert.equal(3, iter.count({'a','b',c=8}))
  end)
  it("equal", function()
    assert.is_nil(iter.equal({}))
    assert.is_nil(iter.equal(iter({})))

    assert.is_true(iter.equal({'a','a','a'}))
    assert.is_nil(iter.equal({'a','b','a'}))

    assert.is_true(iter.equal({table('a','a','a'),table('a','a','a'),table('a','a','a')}))
  end)
  it("rawequal", function()
    assert.is_true(iter.rawequal({is,is,is}))
    assert.is_nil(iter.rawequal({is,is,setmetatable({},getmetatable(is))}))
    assert.is_nil(iter.rawequal({table('a','a','a'),table('a','a','a'),table('a','a','a')}))
  end)
end)