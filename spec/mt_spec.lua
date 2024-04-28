require "compat53"

local test_meta=false
if test_meta and debug.setmetatable then
local get = require "meta.get"
local set = require "meta.set"

local i=nil

describe("mt", function()
  it("number", function()
    i = 17
    local n = 77
    assert.is_nil(get(n))
    assert.is_table(get(n, {}))
    set(n, {__call = function(self, ...) return self end})
    assert.is_table(get(n))
    assert.equal(77, n())
    set(i, nil)
    assert.is_nil(get(i))
  end)
  it("boolean", function()
    i = true
    local b = true
    assert.is_nil(get(b))
    assert.is_table(get(b, {}))
    set(b, {__call = function(self, ...) return self end})
    assert.is_table(get(b))
    assert.equal(true, b())
    set(i, nil)
    assert.is_nil(get(i))
  end)
  it("function", function()
    i = function() end
    local f = function() return '10' end
    local g = function() return '20' end
    assert.is_nil(get(f))
    assert.is_table(get(f, {}))
    set(f, {__index = function(self, k) return get(self)[k] or '88' end, __exec = function(self, ...) return '50' end})
    assert.is_table(get(f))
    assert.equal('88', f[7])
    assert.equal('88', g[{}])
    assert.equal('10', f())
    assert.equal('20', g())
    assert.equal('50', f:__exec())
    assert.equal('50', g:__exec())
    set(i, nil)
    assert.is_nil(get(i))
  end)
  it("nil", function()
    i = nil
    assert.is_nil(get(i))
    assert.is_table(get(i, {}))
    set(i, {__call = function(self, ...) return 'none' end})
    assert.is_table(get(i))
    assert.equal('none', i())
    set(i, nil)
    assert.is_nil(get(i))
  end)
  it("table", function()
    i = {}
    assert.is_nil(get(i))
    assert.is_table(get(i, {}))
    set(i, {__call = function(self, ...) return 'none' end})
    assert.is_table(get(i))
    assert.equal('none', i())
    set(i, nil)
    assert.is_nil(get(i))
  end)
end)
end
