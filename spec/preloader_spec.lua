local testdata = 'testdata'
local meta = require "meta"
local preloader = meta.preloader
describe('preloader', function()
  it("ok", function()
    local pl = preloader(testdata .. ".ok", true, true)
    assert.equal('ok', (rawget(pl, 'message') or {}).data)
  end)
end)
