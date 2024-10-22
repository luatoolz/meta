describe("has.tostring", function()
	local meta, is, has
	setup(function()
    meta = require "meta"
    is = meta.is
    has = is.has
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(has.tostring)
    assert.truthy(is.callable(has.tostring))
    assert.is_nil(has.tostring())
    assert.is_true(has.tostring(setmetatable({},{__tostring=is.noop})))
  end)
end)
