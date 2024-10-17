describe("is.values", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.values)
    assert.truthy(is.callable(is.values))
    assert.truthy(is.has)
    assert.truthy(is.callable(is.has.values))
    assert.equal(is.has.values, is.values)
  end)
end)
