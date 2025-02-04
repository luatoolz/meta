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
      {{"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r"}, {"a", "b", "c", "d", "e"}},
      {{"a", nil, "x"}, {"a", "x"}},
      {{"a", nil, "x", a=1}, {"a", "x"}},
      {{b=2, "a", nil, "x", a=1}, {"a", "x"}},
      {{b=2, "a", nil, nil, "x", a=1}, {"a", "x"}},
      {{b=2, "a", nil, nil, nil, "x", a=1}, {"a", "x"}},
    }
    for it in iter.ivalues(test) do
      assert.same(it[2], map(iter.ivalues(it[1])))
      assert.same(it[2], map(iter.ivalues(table(it[1]))))
      assert.same(it[2], map(iter.ivalues(setmetatable(it[1],{}))))
      assert.same(it[2], map(iter.ivalues(setmetatable(it[1],{__pairs=ipairs}))))
      assert.same(it[2], map(iter.ivalues(setmetatable(it[1],{__ipairs=ipairs}))))
      assert.same(it[2], map(iter.ivalues(setmetatable(it[1],{__ipairs=function(self) return table.nexti, self end}))))
    end
  end)
end)