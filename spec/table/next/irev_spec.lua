-- function table:irevpairs() return table.nextirev, self end

describe("table.next.irev", function()
	local meta, is, map, irev
	setup(function()
    meta = require "meta"
    is = meta.is
    map = table.map
    irev = require 'meta.table.next.irev'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(irev))
  end)
  it("positive", function()
    local test, rv

    test = function(t) return setmetatable(t, {__pairs = function(self) return irev, self, nil end}) end
    rv = test({'a', 'b', 'c'})
    assert.same({'c', 'b', 'a'}, map(rv))

    test = function(t) return setmetatable(t, {__pairs = function(self) return irev, self, nil end}) end
    rv = test({'a', 'b', 'c'})
    assert.same({'c', 'b', 'a'}, map(rv))
  end)
end)