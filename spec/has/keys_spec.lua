describe("has.keys", function()
	local is, has
	setup(function()
    is = require "meta.is"
    has = is.has
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(has.keys)
    assert.truthy(is.callable(has.keys))
  end)
  it("positive", function()
    assert.truthy(is.callable(has.keys))
    assert.truthy(has.keys({}, {}))
    assert.truthy(has.keys({'a'}, {a=true}))
    assert.truthy(has.keys({'a', 'b'}, {b=true, a=true}))
    assert.truthy(has.keys({'a', 'b'}, {a=true, b=true}))
  end)
  it("negative", function()
    assert.falsy(has.keys({'a'}, {}))
    assert.falsy(has.keys({'a'}, {b=true}))
  end)
  it("nil", function()
    assert.falsy(has.keys(nil, nil))
    assert.falsy(has.keys(nil))
    assert.falsy(has.keys())
  end)
end)