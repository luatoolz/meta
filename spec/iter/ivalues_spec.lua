describe("iter.ivalues", function()
  local meta, is, iter, map, ivalues, nexti
  setup(function()
    meta = require "meta"
    assert.truthy(meta)
    is = meta.is
    iter = meta.iter
    map = table.map
    ivalues = iter.ivalues
    nexti = require('meta.table.next.i')
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(ivalues))
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
    local i=0
    for it in ivalues(test) do
      i=i+1
      assert.is_table(it)
      assert.same(it[2], map(ivalues(it[1])), 'fail 1')
      assert.same(it[2], map(ivalues(table(it[1]))), 'fail 2')
      assert.same(it[2], map(ivalues(setmetatable(it[1],{}))), 'fail 3')
      assert.same(it[2], map(ivalues(setmetatable(it[1],{__pairs=ipairs}))), 'fail 4')
--      assert.same(it[2], map(ivalues(setmetatable(it[1],{__ipairs=ipairs}))), 'fail 5')
      assert.same(it[2], map(ivalues(setmetatable(it[1],{__ipairs=function(self) return nexti, self end}))), 'fail 6')
    end
  end)
end)