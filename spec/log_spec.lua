describe('log', function()
  local meta, log
  setup(function()
    meta = require "meta"
    log = meta.log
  end)
  it("conf", function()
    assert.is_boolean(log.report)
    assert.is_function(log.logger)
    assert.equal(log, log^false)
    assert.is_false(log.report)
    assert.equal(log, log^true)
    assert.is_true(log.report)

    assert.equal(log, log^nil)
    assert.is_nil(log.logger)
    assert.equal(log, log^print)
    assert.equal(print, log.logger)

    assert.equal(log, log^'xxx')
    assert.equal(print, log.logger)
    assert.is_true(log.report)

    assert.equal(log, log^function() return 77 end)
    assert.equal(log, log^false)
    assert.is_nil(log())
    assert.equal(log, log^true)
    assert.equal(77, log())
  end)
end)
