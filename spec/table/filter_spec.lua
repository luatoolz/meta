describe("table.filter", function()
  local meta, is, non
  setup(function()
    meta = require "meta"
    is = meta.is
    non = is.non
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table.filter))
  end)
  it("positive", function()
    assert.equal(table{"x", "y", "z"}, table{"x", nil, "y", nil, "z"} % function(x) return x ~= nil end)

    assert.is_true(is.null(nil))
    assert.falsy(not is.null(nil))
    assert.is_nil(is.non.null(nil))
    assert.is_nil(non.null(nil))

    assert.is_true(non.null("y"))
    assert.is_nil(non.null(nil))

    assert.equal(table{"x", "y", "z"}, table{"x", nil, "y", nil, "z"} % non.null)
    assert.equal(table{'failed'}, table.map(meta.module('testdata.loader').files) % function(v) return v~='init.lua' end)
    assert.equal(table{x=true, z=true}, table{x=true, y=false, z=true} % function(v) return v and true or nil end)
    assert.equal(table{x=true, z=true}, table{x=true, y=false, z=true} % {'x', 'z'})
  end)
  it("negative", function()
    assert.is_nil(table.filter(''))
--    assert.is_nil(table.filter({}))
    assert.is_nil(table.filter(0))
    assert.is_nil(table.filter(1))
    assert.is_nil(table.filter(false))
    assert.is_nil(table.filter(true))
  end)
  it("nil", function()
    assert.is_nil(table.filter())
    assert.is_nil(table.filter(nil))
  end)
end)

--[[
  it("filter", function()
    local not_nil = function(x) return x ~= nil end
    local withnil = table {"x", nil, "y", nil, "z"}
    assert.same({"x", "y", "z"}, withnil:filter(not_nil))
    assert.same({'failed.lua'}, table.map(meta.module('testdata.loader').iterfiles, function(x) if x ~= 'init.lua' then return x end end))
  end)
--]]