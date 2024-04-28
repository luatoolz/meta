local testdata = 'testdata'
local preload = require "meta.preload"
local loader = require "meta.loader"
describe('preload', function()
  it("loader", function()
    local pl = loader(testdata .. ".ok", true, true)
    assert.equal('ok', (rawget(pl, 'message') or {}).data)
  end)
  it("call preload", function()
    local pl = loader(testdata .. ".preload") --, true, true)
    preload(pl.dot, true, true)
    local tt = {}
    for k,v in pairs(pl.dot) do
      tt[k]=v
    end
    assert.equal('ok', tt['ok.message'].data)
    assert.equal('ok', pl.dot['ok.message'].data)
    assert.equal('ok', pl.ok.message.data)
    assert.equal('ok', pl.noinit.message.data)
    assert.equal('ok', (rawget(pl.noinit, 'message') or {}).data)
  end)
end)
