local require=require
describe('require', function()
  local no, no2
  setup(function()
    no = require "meta.no"
    no2 = require "meta/no"
  end)
  it("meta", function()
    assert.not_equal(require, no.require)
    assert.equal(no, no2)
  end)
end)