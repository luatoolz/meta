describe("mt", function()
  local mt
  setup(function()
    require "meta"
    mt = require 'meta.mt.mt'
  end)
  it("new", function()
    assert.callable(mt, 'mt is not a function')
    assert.is_table(mt({}), 'mt({}) is not a table')
  end)
  it("getset", function()
    local __test = "__tostring.test"
    local __tostring = function(self) return __test end
    local __call = function(self, n) return __test .. tostring(n) end
    local t = {}
    local nmt = {__tostring=__tostring}
    assert.equal(t, mt(t, nmt))
    assert.equal(nmt, getmetatable(t))
    assert.equal(__tostring, getmetatable(t).__tostring)
    assert.equal(__tostring, mt(t).__tostring)
    assert.is_nil(mt(t).__call)
    assert.equal(__call, getmetatable(mt(t, {__call=__call})).__call)
    assert.equal(__tostring, mt(t).__tostring)
    assert.equal(__call, mt(t).__call)
    assert.equal(__call, nmt.__call)
    mt(t).__call = nil
    assert.is_nil(mt(t).__call)
    assert.is_nil(getmetatable(t).__call)
    local x = {}
    assert.is_nil(mt(x, false))
    assert.is_table(mt(x))
    assert.is_nil(getmetatable(x))
    assert.is_table(mt(x, true))
    assert.is_table(getmetatable(x))
  end)
  it("overwrite", function()
    local a,b =
      function(...) return 'a' end,
      function(...) return 'b' end
    local t = setmetatable({},{__tostring=a})

    assert.equal(getmetatable(t).__tostring, a)
    assert.equal(getmetatable(mt(t, {__tostring=b})).__tostring, b)
  end)
  it("no overwrite", function()
    local a,b =
      function(...) return 'a' end,
      function(...) return 'b' end
    local t = setmetatable({},{__tostring=a})

    assert.equal(getmetatable(t).__tostring, a)
    assert.equal(getmetatable(mt(t, {__tostring=b}, false)).__tostring, a)
  end)
end)