describe('no.call', function()
  local meta, no, call
  setup(function()
    meta = require "meta"
    no = meta.no
    call = meta.call
    _ = meta.is ^ 'testdata'
  end)
  teardown(function() call.protect = true end)
  it("true", function()
    assert.no_error(function() return call(function() return true, 'error' end) end)
    assert.is_true(call(function() return true, 'error' end))
    assert.is_true(assert(call(function() return true, 'error' end)))
  end)
  it("false", function()
    call.protect = false;
    assert.has_error(function() return assert(call(function() return false, 'error' end)) end);
    call.protect = true
    assert.is_false(call(function() return false, 'error' end))
    assert.equal('error', select(2, call(function() return false, 'error' end)))
  end)
  it("nil", function()
    call.protect = false;
    assert.has_error(function() return assert(call(function() return nil, 'error' end)) end);
    call.protect = true
    assert.is_nil(call(function() return nil, 'error' end))
  end)
  it("other", function()
    assert.is_string(assert(call(function() return 'test', 'error' end)))
    assert.is_table(no.require("testdata.ok"))

    local r = table.pack(call(function() return 'test' end))
    assert.equal(1, #r)
    assert.equal('test', r[1])

    r = table.pack(call(function() return 'test', 'two' end))
    assert.equal(2, #r)
    assert.equal('test', r[1])
    assert.equal('two', r[2])

    call.protect = false;
    assert.has_error(function()
      return call(function()
        error('err');
        return 'test', 'two'
      end)
    end);
    call.protect = true
  end)
end)