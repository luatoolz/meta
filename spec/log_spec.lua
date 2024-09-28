describe('log', function()
  local meta, log
  setup(function()
    meta = require "meta"
    log = meta.log
  end)
  it("conf", function()
    assert.is_boolean(log.report)
    assert.is_function(log.logger)
    assert.equal(false, log^false)
    assert.is_false(log.report)
    assert.equal(true, log^true)
    assert.is_true(log.report)

    assert.equal(nil, log^nil)
    assert.is_nil(log.logger)
    assert.equal(print, log^print)
    assert.equal(print, log.logger)

    assert.is_nil(log^'xxx')
    assert.equal(print, log.logger)
    assert.is_true(log.report)

    local printer=function() return 77 end
    assert.equal(printer, log^printer)
    assert.equal(false, log^false)
    assert.is_nil(log())
    assert.equal(true, log^true)
    assert.equal(77, log())
  end)
end)
