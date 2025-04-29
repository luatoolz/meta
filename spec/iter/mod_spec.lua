describe("iter.mod", function()
  local meta, is, iter
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.iter))
  end)
  it("positive", function()
    local test = {
      {{},{},is.string},
      {{},{5}, is.string},
      {{5},{5}, is.number},
      {{"x"},{"x"}, is.string},
      {{"x", "y"},{"x", "y", 6}, is.string},
    }
    for it in iter.ivalues(test) do
      assert.same(it[1], table.map(iter.mod(iter.items(it[2]), it[3])))
      assert.same(it[1], table.filter(iter.items(it[2]), it[3]))
      assert.same(it[1], {}..iter(iter.items(it[2]))%it[3])
      assert.same(it[1], {}..iter(it[2])%it[3])
    end
  end)
end)