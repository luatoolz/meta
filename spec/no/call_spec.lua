describe('no.call', function()
  local meta, no, log
  setup(function()
    meta = require "meta"
    no = meta.no
    log = meta.log
    _ = meta.is ^ 'testdata'
  end)
  teardown(function() log.protect = true end)
  it("true", function()
    assert.no_error(function() return no.call(function() return true, 'error' end) end)
    assert.is_true(no.call(function() return true, 'error' end))
    assert.is_true(assert(no.call(function() return true, 'error' end)))
  end)
  it("false", function()
    log.protect = false;
    assert.has_error(function() return assert(no.call(function() return false, 'error' end)) end);
    log.protect = true
    assert.is_false(no.call(function() return false, 'error' end))
    assert.equal('error', select(2, no.call(function() return false, 'error' end)))
  end)
  it("nil", function()
    log.protect = false;
    assert.has_error(function() return assert(no.call(function() return nil, 'error' end)) end);
    log.protect = true
    assert.is_nil(no.call(function() return nil, 'error' end))
  end)
  it("assert+true", function()
    assert.no_error(function() return assert(no.assert(pcall(function() return true, 'error' end))) end)
    assert.is_true(assert(no.assert(pcall(function() return true, 'error' end))))
  end)
  it("other", function()
    assert.no_error(function() return assert(no.assert(pcall(function() return true, 'error' end))) end)
    assert.is_string(assert(no.call(function() return 'test', 'error' end)))
    assert.is_table(no.require("testdata.ok"))

    local r = table.pack(no.call(function() return 'test' end))
    assert.equal(1, #r)
    assert.equal('test', r[1])

    r = table.pack(no.call(function() return 'test', 'two' end))
    assert.equal(2, #r)
    assert.equal('test', r[1])
    assert.equal('two', r[2])

    log.protect = false;
    assert.has_error(function()
      return no.call(function()
        error('err');
        return 'test', 'two'
      end)
    end);
    log.protect = true
  end)
end)