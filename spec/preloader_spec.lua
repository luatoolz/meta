local meta = require "meta"
local preloader = meta.preloader
describe('preloader', function()
  it("test.ok", function()
    local pl = preloader("test.ok", true, true)
    assert.equal('ok', (rawget(pl, 'message') or {}).data)
  end)
end)
