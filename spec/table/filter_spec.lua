describe("table.filter", function()
  local meta, is, null, non_null, selector, filter
  setup(function()
    meta = require "meta"
    is = meta.is
    selector = meta.selector
    null = function(x) return type(x)=='nil' or nil end
    non_null = function(x) return type(x)~='nil' or nil end
    filter = table.filter
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(filter))
  end)
  it("positive", function()
    assert.equal(table{"x", "y", "z"}, table{"x", nil, "y", nil, "z"} % non_null)

    assert.is_true(null(nil))
    assert.falsy(not null(nil))
    assert.is_nil(non_null(nil))
    assert.is_nil(non_null(nil))

    assert.is_true(non_null("y"))
    assert.is_nil(non_null(nil))

    assert.equal(table{"x", "y", "z"}, table{"x", nil, "y", nil, "z"} % non_null)
--    assert.equal(table{'failed'}, (meta.module('testdata.loader2').files) % function(v) return v~='init.lua' end)
    assert.equal(table{x=true, z=true}, table{x=true, y=false, z=true} % function(v) return v and true or nil end)

    assert.equal(table{x=true, z=true}, table(setmetatable({x=true, y=false, z=true},{__mul=table.map}) * selector({x=true, z=true})))
    assert.equal(table{x=true, z=true}, table(setmetatable({x=true, y=false, z=true},{__mul=table.map}) * selector('x', 'z')))
    assert.equal(table{x=true, z=true}, table(setmetatable({x=true, y=false, z=true},{__mul=table.map}) * {'x', 'z'}))
    assert.equal(table{x=true, z=true}, table{x=true, y=false, z=true} * {'x', 'z'})

    assert.same({}, table.filter({}))
  end)
  it("negative", function()
    assert.is_nil(table.filter(''))
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