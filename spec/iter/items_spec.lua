describe("iter.items", function()
  local meta, is, iter, paired, ipaired
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    paired = function(x) return setmetatable(x, {__pairs=function(self) return next, self end}) end
    ipaired = function(x) return setmetatable(x, {__pairs=ipairs}) end
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.items))
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
      {paired({"x"}),{"x"}},
      {ipaired({"x"}),{"x"}},
    }
    local els = iter.items(test)
    assert.callable(els)
    local i = 1
    for it in els do
      local it1 = iter.items(it[1])
      assert.callable(it1)
      assert.same(it[2], iter.map(it1), 'error in iter.items %d' ^ i)
      i=i+1
    end
  end)
end)