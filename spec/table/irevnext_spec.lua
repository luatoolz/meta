describe("table.irev", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table.nextirev))
  end)
  it("positive", function()
    local test, rv

    test = function(t) return setmetatable(t, {__pairs=table.irevpairs}) end
    rv = test({'a', 'b', 'c'})
    assert.same({'c', 'b', 'a'}, table.map(rv))

    test = function(t) return setmetatable(t, {__pairs=function(self) return table.nextirev, self, nil end}) end
    rv = test({'a', 'b', 'c'})
    assert.same({'c', 'b', 'a'}, table.map(rv))
  end)
end)