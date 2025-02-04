describe("iter.tuple", function()
  local meta, is, iter, map
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    map = iter.map
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.tuple))
  end)
  it("positive", function()
    assert.same({}, map(iter.tuple()))
    assert.same({"x"}, map(iter.tuple("x")))
    assert.same({"x", "y"}, map(iter.tuple("x", "y")))
    assert.same({"a", "b", "c", "d", "e"}, map(iter.tuple("a", "b", "c", "d", "e")))

    assert.same({"a", "x"}, map(iter.tuple("a", nil, "x")))
    assert.same({"a", "x"}, map(iter.tuple("a", nil, nil, "x")))
    assert.same({"a", "x"}, map(iter.tuple("a", nil, nil, nil, "x")))
  end)
end)