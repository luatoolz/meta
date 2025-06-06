describe("is.match", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.match)
    assert.truthy(is.callable(is.match.root))
  end)
  it("positive", function()
    assert.truthy(is.match.root('meta'))
    assert.truthy(is.match.root('mEta_99'))
    assert.equal('meta',is.match.root('meta.loader'))
  end)
  it("negative", function()
    assert.is_nil(is.match.root('*(^&%&%'))
  end)
  it("nil", function()
    assert.is_nil(is.match.root(nil))
    assert.is_nil(is.match.root())
  end)
end)