describe('require', function()
  local meta
  setup(function() meta = require "meta" end)
  it(".dot", function()
    local require = meta.require("meta.module")
    assert.is_function(require)
    assert.equal(meta.loader, require(".loader"))
  end)
end)
