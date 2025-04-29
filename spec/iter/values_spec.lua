describe("iter.values", function()
  local meta, is, iter, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = table.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.values))
  end)
  it("positive", function()
    local test = {
      {{},{}},
      {{"x"},{}},
      {{"x", "y"},{}},
      {{"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r"}, {q="q", w="w", e="e", r="r"}},
      {{"a", nil, "x"}, {}},
      {{"a", nil, "x", a=1}, {a=1}},
      {{b=2, "a", nil, "x", a=1}, {b=2, a=1}},
      {{b=2, "a", nil, nil, "x", a=1}, {b=2, a=1}},
      {{b=2, "a", nil, nil, nil, "x", a=1}, {b=2, a=1}},
    }
    for it in iter.ivalues(test) do
      assert.same(it[2], map(iter.values(it[1])))
      assert.same(it[2], map(iter.values(table(it[1]))))
      assert.same(it[2], map(iter.values(setmetatable(it[1],{}))))
    end
  end)
end)