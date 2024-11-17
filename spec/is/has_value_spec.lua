describe("is.has_value", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.has_value)
    assert.truthy(is.callable(is.has_value))
    assert.truthy(is.has)
    assert.truthy(is.callable(is.has.value))
    assert.equal(is.has.value, is.has_value)
  end)
end)