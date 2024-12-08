describe("table.sub", function()
  local meta, is, sub
  setup(function()
    meta = require "meta"
    is = meta.is
    sub = table.sub
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(sub))
  end)
  it("positive", function()
    local z={1,2,3,4,5}

    assert.same({1}, sub(z,1,1))
    assert.same({},sub({},1,5))

    assert.same({1}, sub(z,1,1))
    assert.same({1,2}, sub(z,1,2))
    assert.same({1,2,3}, sub(z,1,3))
    assert.same({1,2,3,4}, sub(z,1,4))
    assert.same(z, sub(z,1,5))

    assert.same(z, sub(z,1,5))
    assert.same({2,3,4,5}, sub(z,2,5))
    assert.same({3,4,5}, sub(z,3,5))
    assert.same({4,5}, sub(z,4,5))
    assert.same({5}, sub(z,5,5))

    assert.same({1}, sub(z,1,-5))
    assert.same({1,2}, sub(z,1,-4))
    assert.same({1,2,3}, sub(z,1,-3))
    assert.same({1,2,3,4}, sub(z,1,-2))
    assert.same(z, sub(z,1,-1))

    assert.same(z, sub(z,-5,5))
    assert.same({2,3,4,5}, sub(z,-4,5))
    assert.same({3,4,5}, sub(z,-3,5))
    assert.same({4,5}, sub(z,-2,5))
    assert.same({5}, sub(z,-1,5))

    assert.same(z, sub(z,1))
    assert.same({5}, sub(z,-1))

    assert.not_equal(z, sub(z))
    assert.same(z, sub(z))

    assert.not_equal(z, sub(table(1,2,3,4,5)))
    assert.same(z, sub(table(1,2,3,4,5)))
  end)
  it("negative", function()
    assert.is_nil(sub(''))
    assert.is_nil(sub(0))
    assert.is_nil(sub(1))
    assert.is_nil(sub(false))
    assert.is_nil(sub(true))
  end)
  it("nil", function()
    assert.is_nil(sub())
    assert.is_nil(sub(nil))
  end)
end)