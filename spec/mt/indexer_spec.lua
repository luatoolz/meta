describe("mt.indexer", function()
	local meta, is, mt, indexer, new, new2
	setup(function()
    meta = require "meta"
    is = meta.is
    mt = meta.mt
    indexer = mt.indexer
    new = setmetatable({}, table.clone(getmetatable(table)))
    new2 = setmetatable({}, table.clone(getmetatable(table)))
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(indexer))
  end)
  it("__indexer", function()
    getmetatable(new).__index=indexer
    getmetatable(new).__indexer = {
      table.index,
      table.interval,
      table.select
    }
    assert.same(table({'a','b','c'}), new({'a','b','c'}))
    assert.same(table({'a','b','c'})[-1], new({'a','b','c'})[-1])
    assert.same(table({'a','b','c'})[{1}], new({'a','b','c'})[{1}])
    assert.same(table({a='a',b='b',c='c'})[{'b','c'}], new({a='a',b='b',c='c'})[{'b','c'}])

    assert.same({b='b', c='c'}, new({a='a',b='b',c='c'})[{'b','c'}])
  end)
  it("mt", function()
    getmetatable(new2).__index=indexer
    local g=getmetatable(new2)
    table.insert(g, table.index)
    table.insert(g, table.interval)
    table.insert(g, table.select)

    assert.same(table({'a','b','c'}), new2({'a','b','c'}))
    assert.same(table({'a','b','c'})[-1], new2({'a','b','c'})[-1])
    assert.same(table({'a','b','c'})[{1}], new2({'a','b','c'})[{1}])
    assert.same(table({a='a',b='b',c='c'})[{'b','c'}], new2({a='a',b='b',c='c'})[{'b','c'}])

    assert.same({b='b', c='c'}, new2({a='a',b='b',c='c'})[{'b','c'}])
  end)
end)