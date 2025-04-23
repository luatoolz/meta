describe("basic", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable)
    assert.truthy(is.callable(is.callable))
--    assert.truthy(is.callable(is.is))
--    assert.truthy(is.is(is))
    assert.is_table(is.mt)
--    assert.truthy(is.callable(is.bulk))
--    assert.truthy(is.is(is.noneexistent))

--    local rv, e = is.noneexistent()
--    assert.is_nil(rv)
--    assert.not_nil(e)
--    assert.is_nil(is.noneexistent.__rv)
  end)
end)