describe("iter.range", function()
  local meta, is, iter, range, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    range = iter.range
    map = table.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.range))
  end)
  it("positive", function()
    assert.same({}, map(range(0)))
    assert.same({1, 2, 3, 4, 5, 6}, map(range(6)))
    assert.same({4, 5, 6, 7, 8}, map(range(4, 8)))
    assert.same({40, 50, 60, 70, 80}, map(range(40, 80, 10)))
  end)
  it("negative", function()
    assert.same({}, map(range(-1)))
    assert.same({1, 0, -1, -2, -3, -4, -5, -6}, map(range(1, -6, -1)))
    assert.same({-4, -5, -6, -7, -8}, map(range(-4, -8, -1)))
    assert.same({80, 70, 60, 50, 40}, map(range(80, 40, -10)))
    assert.same({0, -1}, map(range(0, -1, -1)))
  end)
end)