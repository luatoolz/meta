describe("iter.ivalues", function()
  local meta, is, iter, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = iter.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.ivalues))
  end)
  it("positive", function()
    local test = {
      {{},{}},
      {{"x"},{"x"}},
      {{"x", "y"},{"x", "y"}},
      {{"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r"}, {"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r"}},
      {{"a", nil, "x"}, {"a", "x"}},
      {{"a", nil, "x", a=1}, {"a", "x", a=1}},
      {{b=2, "a", nil, "x", a=1}, {"a", "x", b=2, a=1}},
      {{b=2, "a", nil, nil, "x", a=1}, {"a", "x", b=2, a=1}},
      {{b=2, "a", nil, nil, nil, "x", a=1}, {"a", "x", b=2, a=1}},
    }
    for it in iter.ivalues(test) do
      assert.same(it[2], map(it[1]))
    end
  end)
  describe("map", function()
    it("nil/wrong", function()
      assert.is_nil(map())
      assert.is_nil(map(nil))
      assert.is_nil(map(nil, nil))
    end)
    it("empty", function()
      assert.same({}, map({}))
      assert.same({}, map(table({})))
      assert.same({}, map({}, tostring))
      assert.same({}, map(table({}), tostring))

      assert.equal(table{}, map(table({})))
      assert.equal(table{}, map(table({}), tostring))
    end)
    it("table", function()
      local b = table({"x", "y", "z"})
      assert.same({"x", "y", "z"}, map(b))
      assert.same(b, map(b))
      assert.same({"x", "y", "z"}, map(b, tostring))
      assert.same(b, map(b))
      assert.same(b, map(b, tostring))
    end)
    it("iterator", function()
      local data = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
      local fn = function(x) return data[x] end
      local b = map(iter.range(10), fn)

      assert.same({}, map(function() return nil end))
      assert.same({'1', '2', '3'}, map(iter.range(3), fn))
      assert.same(data, map(iter.range(10), fn))
      assert.same(b, map(iter.range(10), fn))
    end)
  end)
end)