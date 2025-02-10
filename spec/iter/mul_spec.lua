describe("iter.iter", function()
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
      {{},{}},
      {{"x"},{"string"}},
      {{"x", "y"},{"string", "string"}},
      {{"x", 3},{"string", "number"}},
      {{"x", 3, a=string.lower},{"string", "number", a="function"}},
      {{a="x", b=3, c=string.lower},{a="string", b="number", c="function"}},
    }
    for it in iter.ivalues(test) do
      assert.same(it[2], iter.map(iter.mul(iter.iter(it[1]), type)))
      assert.same(it[2], iter.map(iter.mul(iter(it[1]), type)))
      assert.same(it[2], iter.map(iter(it[1], type)))
      assert.same(it[2], iter.map(iter(it[1]), type))
    end

    assert.same({"string"}, iter.map(iter({"a"})*type))
    assert.same({"testdata", "/tmp"}, iter.map(iter({"testdata", "/tmp"})%is.dir))

    local rex = require 'meta.rex'
    assert.same({"__call", "__iter", "__index"}, iter.map(iter({"some", "__call", "__iter", "any", "__index"})%rex.mtname))
    assert.same({"__call", "__iter", "__index"}, iter.map(iter({"some", "__call", "__iter", "any", "__index"})*rex.mtname))

    assert.same({"__call", "__iter", "__index"}, {} .. iter({"some", "__call", "__iter", "any", "__index"})*rex.mtname)
  end)
end)