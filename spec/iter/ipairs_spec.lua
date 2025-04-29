describe("iter.ipairs", function()
  local meta, is, iter, ivalues
  setup(function()
    meta = require "meta"
    assert.truthy(meta)
    is = meta.is
    iter = meta.iter
    ivalues = iter.ivalues
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(ivalues))
  end)
  it("positive", function()
    local test = {
      {{},{}},
      {{"x", "y"},{"y", "x"}},
      {{"a", "b", "c", "d", "e"}, {"e", "d", "c", "b", "a"}},
    }
    for it in ivalues(test) do
      assert.same(it[2], table()..iter.ipairs(it[2]))
      assert.same(it[2], table()..iter.ipairs(table()..iter.ipairs(it[1]), -1))
      assert.same(it[2], table()..iter.ipairs(table()..iter.ipairs(it[1]), true))
      assert.same(it[2], table()..iter.ipairs(table()..iter.ipairs(table()..iter.ipairs(it[1]), 1), -1))
    end
  end)
end)