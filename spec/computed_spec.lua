
describe('computed', function()
  local meta, count, noerror, mt
  local t, o, u, p, ps
  local error_types
  setup(function()
    meta = require "meta"
    mt = require "meta.mt"
    noerror = require "meta.noerror"
    computed = require "meta.computed"
    error_types = { ["string"]=true, ["nil"]=true }
    count = function(x)
      local cc = 0;
      for i, v in pairs(x) do cc = cc + 1 end
      return cc
    end
  end)
  before_each(function()
    o = computed({}, {ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end}, true)
    u = computed({}, {ok = function(self) return "complex" .. ' ' .. self.dependent end, dependent = function(self) return "dependent" end}, false)
    p = computed({}, {
      ok = function(self) return "ok" end,
      failed = function(self)
        local x=nil;
        return x.failed;
      end,
    }, false)
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
    assert.is_true(mt(t).__computed.__save)

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

    assert.equal("table", type(mt(t).__computed))
    assert.is_false(mt(t).__computed.__save)

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
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.is_nil(t.failed)
    assert.is_true(error_types[type(noerror[t])])
    assert.is_nil(rawget(t, 'failed'))
  end)
  it("protected save", function()
    t = ps
    assert.equal("table", type(t))
    assert.equal(0, count(t))
    assert.equal('ok', t.ok)
    assert.equal('ok', rawget(t, 'ok'))
    assert.is_nil(t.failed)
    assert.is_true(error_types[type(noerror[t])])
    assert.is_nil(rawget(t, 'failed'))
  end)
end)
