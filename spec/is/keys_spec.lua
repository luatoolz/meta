describe("is.keys", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.keys)
    assert.truthy(is.callable(is.keys))
    assert.truthy(is.has)
    assert.truthy(is.callable(is.has.keys))
--    assert.equal(is.has.keys, is.keys)
  end)
end)