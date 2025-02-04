describe("iter.ikeys", function()
  local meta, is, iter, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = iter.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.ikeys))
  end)
  it("positive", function()
    local test = {
      {{},{}},
      {{"x"},{1}},
      {{"x", "y"},{1, 2}},
      {{"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r", "q"}, {1, 2, 3, 4, 5, 6}},
      {{"a", nil, "x"}, {1, 3}},
      {{"a", nil, "x", a=1}, {1, 3}},
      {{b=2, "a", nil, "x", a=1}, {1, 3}},
      {{b=2, "a", nil, nil, "x", a=1}, {1, 4}},
      {{b=2, "a", nil, nil, nil, "x", a=1}, {1, 5}},
    }
    for it in iter(test) do
      assert.same(it[2], map(iter.ikeys(it[1])))
      assert.same(it[2], map(iter.ikeys(table(it[1]))))
      assert.same(it[2], map(iter.ikeys(setmetatable(it[1],{}))))
      assert.same(it[2], map(iter.ikeys(setmetatable(it[1],{__pairs=ipairs}))))
      assert.same(it[2], map(iter.ikeys(setmetatable(it[1],{__ipairs=ipairs}))))
      assert.same(it[2], map(iter.ikeys(setmetatable(it[1],{__ipairs=function(self) return table.nexti, self end}))))
    end
  end)
end)