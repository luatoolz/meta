describe("has.tonumber", function()
	local meta, is, has
	setup(function()
    meta = require "meta"
    is = meta.is
    has = is.has
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(has.tonumber)
    assert.truthy(is.callable(has.tonumber))
    assert.is_nil(has.tonumber())
    assert.is_true(has.tonumber(setmetatable({},{__tonumber=is.noop})))
  end)
end)
