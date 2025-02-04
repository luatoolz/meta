describe("iter.find", function()
  local meta, is, iter
  setup(function()
    meta = require "meta"
    is = meta.is
    iter = meta.iter
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(iter.find))
  end)
  it("positive", function()
    local positive = function(x) return x>0 end
    assert.equal(3, iter.find({-1, -2, 3}, positive))
    assert.equal(2, iter.find({-1, 2, -3}, positive))
    assert.equal(1, iter.find({1, 2, -3}, positive))
    assert.is_nil(iter.find({}, positive))
  end)
end)