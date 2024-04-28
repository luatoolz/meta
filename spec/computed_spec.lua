--local testdata = 'testdata'
local meta = require "meta"
--local computed = meta.computed
local count = function(o)
  local count = 0;
  for i, v in pairs(o) do count = count + 1 end
  return count;
end
describe('computed', function()
  local o, u, p, ps
  before_each(function()
    o = meta.computed({ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end}, true, false)
    u = meta.computed({ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end}, false, false)
    p = meta.computed({
      ok = function(self) return "ok" end,
      failed = function(self)
        local x=nil;
        return x.failed;
      end,
    }, false, true)
    ps = meta.computed({
      ok = function(self) return "ok" end,
      failed = function(self)
        local x=nil;
        return x.failed;
      end,
    }, true, true)
  end)
  it("save", function()
    local t = o
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.is_nil(t.none)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("complex dependent", t.ok)
    assert.equal("complex dependent", rawget(t, 'ok'))
    assert.equal("dependent", rawget(t, 'dependent'))
  end)
  it("nosave", function()
    local t = u
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.is_nil(t.none)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("complex dependent", t.ok)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("dependent", t.dependent)
    assert.is_nil(rawget(t, 'dependent'))
  end)
  it("protected nosave", function()
    local t = p
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.is_nil(t.failed)
    assert.is_nil(rawget(t, 'failed'))
    assert.equal('string', type(t.err))
  end)
  it("protected save", function()
    local t = ps
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.equal('ok', rawget(t, 'ok'))
    assert.is_nil(t.failed)
    assert.is_nil(rawget(t, 'failed'))
    assert.equal('string', type(t.err))
  end)
end)
