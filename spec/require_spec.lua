local testdata = 'testdata'
local require = require "meta.require"(testdata)
describe('require', function()
  it("ok", function()
    local t, err = require ".ok"
    assert.is_table(t)
    assert.is_nil(err)
    assert.equal('ok', t.message.data)
  end)
  it("noneexistent", function()
    assert.has_error(function() return require(".noneexistent") end)
    assert.has_error(function() return require("noneexistent") end)
  end)
  it("failed", function()
    assert.has_error(function() return require(".failed") end)
  end)
  it("or", function()
    assert.truthy(require("noneexistent", false) or require(".ok"))
    assert.truthy(require(".ok") or require("noneexistent", false))
    assert.truthy(require("noneexistent", false) or require("os"))
    assert.truthy(require("os") or require("noneexistent", false))
    assert.truthy((require("noneexistent", false) or require("os")).remove)
  end)
end)