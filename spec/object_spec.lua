describe("object", function()
  local meta, mt, mtindex, object
  setup(function()
    meta = require "meta"
    mt = meta.mt
    mtindex = meta.mtindex
    object = meta.object
  end)
  it("loader", function()
    local o = require 'testdata.init4'
    assert.is_table(o, 'mt is not a function')
--    assert.equal({777}, o)
--    assert.same({x={name='ax'}, y={name='by'}}, o)  -- to load/preload modules
    assert.is_table(mt({}), 'mt({}) is not a table')
  end)
  it("getset", function()
    local __test = "__tostring.test"
    local __tostring = function(self) return __test end
    local __call = function(self, n) return __test .. tostring(n) end
    local t = {}
    local nmt = { __tostring=__tostring }

    assert.equal(t, mt(t, nmt))
    assert.equal(nmt, getmetatable(t))
    assert.equal(__tostring, getmetatable(t).__tostring)
    assert.equal(__tostring, mt(t).__tostring)
    assert.is_nil(mt(t).__call)

    assert.equal(__call, getmetatable(mt(t, { __call = __call })).__call)
    assert.equal(__tostring, mt(t).__tostring)
    assert.equal(__call, mt(t).__call)
    assert.equal(__call, nmt.__call)

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
