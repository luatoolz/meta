describe('computed', function()
  local meta, count
  local t, o, u, p, ps
  setup(function()
    meta = require "meta"
    count = function(x)
      local cc = 0;
      for i, v in pairs(x) do cc = cc + 1 end
      return cc
    end
  end)
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
    t = o
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.is_nil(t.none)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("complex dependent", t.ok)
    assert.equal("complex dependent", rawget(t, 'ok'))
    assert.equal("dependent", rawget(t, 'dependent'))
  end)
  it("nosave", function()
    t = u
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
    t = p
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.is_nil(t.failed)
    assert.is_nil(rawget(t, 'failed'))
    assert.equal('string', type(t.err))
  end)
  it("protected save", function()
    t = ps
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.equal('ok', rawget(t, 'ok'))
    assert.is_nil(t.failed)
    assert.is_nil(rawget(t, 'failed'))
    assert.equal('string', type(t.err))
  end)
end)
