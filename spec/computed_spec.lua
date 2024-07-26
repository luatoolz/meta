describe('computed', function()
  local mt, t, o, u, p, ps
  setup(function()
    mt = require "meta.mt"
    computed = require "meta.computed"
  end)
  before_each(function()
    o = computed({}, {ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end})
    u = computed({}, {}, {ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end})
    p = computed({}, {}, {
      ok = function(self) return "ok" end,
      failed = function(self)
        local x=nil;
        return x.failed;
      end,
    })
    ps = computed({}, {
      ok = function(self) return "ok" end,
      failed = function(self)
        local x=nil;
        return x.failed;
      end,
    })
  end)
  it("save", function()
    t = o
    assert.equal("table", type(t))
    assert.equal("table", type(mt(t)))
    assert.equal("table", type(mt(t).__computed))
    assert.equal(nil, mt(t).__computable)

    assert.is_nil(t.none)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("complex dependent", t.ok)
    assert.equal("complex dependent", rawget(t, 'ok'))
    assert.equal("dependent", rawget(t, 'dependent'))
  end)
  it("nosave", function()
    t = u
    assert.equal("table", type(t))
    assert.equal(nil, mt(t).__computed)
    assert.equal("table", type(mt(t).__computable))

    assert.is_nil(rawget(t, 'none'))
    assert.is_nil(t.none)
    assert.is_nil(rawget(t, 'ok'))
    assert.equal("complex dependent", t.ok)
    assert.is_nil(rawget(t, 'ok'))
    assert.is_nil(rawget(t, 'dependent'))
    assert.equal("dependent", t.dependent)
    assert.is_nil(rawget(t, 'dependent'))
  end)
  it("protected nosave", function()
    t = p
    assert.equal("table", type(t))
    assert.equal('ok', t.ok)
    assert.is_nil(t.failed)
    assert.is_nil(rawget(t, 'failed'))
  end)
  it("protected save", function()
    t = ps
    assert.is_table(getmetatable(t))
    assert.equal("table", type(t))

    assert.equal('ok', t.ok)
    assert.equal('ok', rawget(t, 'ok'))
    local a, b = t.failed
    assert.is_nil(a)
    assert.is_nil(b)
    assert.is_nil(rawget(t, 'failed'))
  end)
end)
