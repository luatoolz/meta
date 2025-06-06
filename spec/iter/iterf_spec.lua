describe("iter.iterf", function()
  local meta, is, iter, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = table.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.iter))
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
    for it in iter.items(test) do
      assert.same(it[2], map(it[1]))
      assert.same(it[2], map(iter.items(it[1])))
      assert.same(it[2], map(iter.iter(it[1])))
    end
  end)
end)