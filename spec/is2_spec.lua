describe("is2", function()
  local is
  setup(function()
    is = require "meta.is2"
  end)
  it("meta", function()
    assert.truthy(is)
    assert.equal(is, is ^ 'meta')
    assert.equal('is', tostring(is))

    assert.equal('is', is[1])
    assert.equal('is', is[-1])
    assert.same({'is'}, is[{}])
  end)
--[[
  it("is.iter", function()
    local sub = is.iter
    assert.equal('is.iter', tostring(sub))
    assert.equal('is.iter', tostring(is.iter))
    assert.equal(sub, is.iter)
    assert.equal(is, is.iter['..'])

    assert.is_table(is.iter)
--    assert.is_true(is.iter(require('meta.iter')))
    assert.is_function(is.iter)
  end)
--]]
end)