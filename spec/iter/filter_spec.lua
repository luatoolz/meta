describe("iter.filter", function()
  local meta, is, iter, null, non_null
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
    null = function(x) return type(x)=='nil' or nil end
    non_null = function(x) return type(x)~='nil' or nil end
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.filter))
  end)
  it("predicate", function()
    assert.is_true(null(nil))
    assert.falsy(not null(nil))
    assert.is_nil(non_null(nil))
    assert.is_nil(non_null(nil))

    assert.is_true(non_null("y"))
    assert.is_nil(non_null(nil))
  end)
  it("positive", function()
    assert.same({}, iter.filter({}))
    assert.same({"x", "y", "z"}, iter.filter({"x", nil, "y", nil, "z"}))
    assert.same({"x", "y", "z"}, iter.filter({"x", nil, "y", nil, "z"}, non_null))
    assert.same({x=true, z=true}, iter.filter({x=true, y=false, z=true}, function(v) return v and true or nil end))
    assert.same({x=true, z=true}, iter.filter({x=true, y=false, z=true}, {'x', 'z'}))
  end)
  it("negative", function()
    assert.is_nil(iter.filter(''))
    assert.is_nil(iter.filter(0))
    assert.is_nil(iter.filter(1))
    assert.is_nil(iter.filter(false))
    assert.is_nil(iter.filter(true))
  end)
  it("nil", function()
    assert.is_nil(iter.filter())
    assert.is_nil(iter.filter(nil))
  end)
end)