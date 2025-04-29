describe("iter.keys", function()
  local meta, is, iter, map, sorted
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = table.map
    sorted = table.sorted
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.keys))
  end)
  it("positive", function()
    local test = {
      {{},{}},
      {{"x"},{}},
      {{"x", "y"},{}},
      {{"a", "b", "c", "d", "e", q="q", w="w", e="e", r="r", "q"}, {'q','w','e','r'}},
      {{"a", nil, "x"}, {}},
      {{"a", nil, "x", a=1}, {'a'}},
      {{b=2, "a", nil, "x", a=1}, {'a','b'}},
      {{b=2, "a", nil, nil, "x", a=1}, {'a','b'}},
      {{b=2, "a", nil, nil, nil, "x", a=1}, {'a','b'}},
    }
    for it in iter(test) do
      assert.same(sorted(it[2]), sorted(map(iter.keys(it[1]))))
      assert.same(sorted(it[2]), sorted(map(iter.keys(table(it[1])))))
      assert.same(sorted(it[2]), sorted(map(iter.keys(setmetatable(it[1],{})))))
    end
  end)
  it("keys", function()
    local a = table(3, 2, 1)
    local b = table({"x", "y", "z"})
    assert.same(b, map(b, tostring))
    for k in iter.keys(b) do assert.equal(table.remove(a), k) end
    local c = table({})
    assert.same(c, map(c, tostring))
    local d = table()
    assert.same(d, map(d, tostring))
  end)
end)