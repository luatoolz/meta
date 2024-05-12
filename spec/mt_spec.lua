describe("mt", function()
  local mt, mtindex
  setup(function()
    mt = require "meta.mt"
    mtindex = require "meta.mtindex"
  end)
  it("new", function()
    assert.is_table(mt({}))
  end)
  it("getset", function()
    local __test = "__tostring.test"
    local __tostring = function(self) return __test end
    local __call = function(self, n) return __test .. tostring(n) end
    local t = {}
    local nmt = { __tostring=__tostring }

    assert.equal(nmt, mt(t, nmt))
    assert.equal(__call, mt(t, { __call = __call }).__call)

    assert.equal(__tostring, getmetatable(t).__tostring)
    assert.equal(__call, getmetatable(t).__call)

    assert.equal(__tostring, mt(t).__tostring)
    assert.equal(__call, mt(t).__call)

    mt(t).__call = nil
    assert.is_nil(mt(t).__call)
    assert.is_nil(getmetatable(t).__call)
  end)
  describe("mtindex", function()
    it("#1", function()
      local top = {}
      local t = setmetatable({}, { __index = { __index = { __index = top}}})
      assert.equal(top, mtindex(t))
    end)
  end)
end)
