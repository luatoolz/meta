describe('errors', function()
  local meta
  setup(function()
    meta = require "meta"
  end)
  it("switch", function()
    local current = meta.errors()
    if current then
      assert.truthy(meta.errors())
      meta.errors(false)
      assert.falsy(meta.errors())
      meta.errors(true)
      assert.truthy(meta.errors())
    else
      assert.falsy(meta.errors())
      meta.errors(true)
      assert.truthy(meta.errors())
      meta.errors(false)
      assert.falsy(meta.errors())
    end
  end)
end)
