describe('errors', function()
  local meta
  setup(function()
    meta = require "meta"
  end)
  it("", function()
    assert.falsy(meta.errors())
    meta.errors(true)
    assert.truthy(meta.errors())
    meta.errors(false)
    assert.falsy(meta.errors())
  end)
end)
