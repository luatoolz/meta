describe('log', function()
  local meta, log
  setup(function()
    meta = require "meta"
    log = meta.log
  end)
  it("conf", function()
    assert.is_boolean(log.report)
    assert.is_function(log.logger)

    log.logger=false
    assert.is_false(log.report)
    log.report=true
    assert.is_true(log.report)
    log.logger=nil
    assert.is_nil(log.logger)
    log.logger=print
    assert.equal(print, log.logger)
    log.logger='xxx'
    assert.equal(print, log.logger)
    assert.is_true(log.report)

    local printer=function() return 77 end
    log.logger=printer
    assert.equal(printer, log.logger)
    log.report=false
    assert.is_nil(log())
    log.report=true
    assert.equal(77, log())
  end)
  it("switch", function()
    if log.protect then
      assert.truthy(log.protect)
      log.protect = false
      assert.falsy(log.protect)
      log.protect = true
      assert.truthy(log.protect)
    else
      assert.falsy(log.protect)
      log.protect = true
      assert.truthy(log.protect)
      log.protect = false
      assert.falsy(log.protect)
    end
  end)
end)