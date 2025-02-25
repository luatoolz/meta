describe("is.has_key", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.has_key)
    assert.truthy(is.callable(is.has_key))
    assert.truthy(is.has)
    assert.truthy(is.callable(is.has.key))
--    assert.equal(is.has.key, is.has_key)
  end)
end)