if debug.setmetatable then
describe("mt_debug", function()
  local getmetatable, setmetatable = getmetatable, setmetatable
  local i=nil
  setup(function()
    require "compat53"
    getmetatable = require "meta.get"
    setmetatable = require "meta.set"
  end)
  before_each(function()
    i=nil
  end)
  it("number", function()
    i = 17
    local n = 77
    assert.is_nil(getmetatable(n))
    assert.is_table(getmetatable(n, {}))
    setmetatable(n, {__call = function(self, ...) return self end})
    assert.is_table(getmetatable(n))
    assert.equal(77, n())
    setmetatable(i, nil)
    assert.is_nil(getmetatable(i))
  end)
  it("boolean", function()
    i = true
    local b = true
    assert.is_nil(getmetatable(b))
    assert.is_table(getmetatable(b, {}))
    setmetatable(b, {__call = function(self, ...) return self end})
    assert.is_table(getmetatable(b))
    assert.equal(true, b())
    setmetatable(i, nil)
    assert.is_nil(getmetatable(i))
  end)
  it("function", function()
    i = function() end
    local f = function() return '10' end
    local g = function() return '20' end
    assert.is_nil(getmetatable(f))
    assert.is_table(getmetatable(f, {}))
    setmetatable(f, {__index = function(self, k) return getmetatable(self)[k] or '88' end, __exec = function(self, ...) return '50' end})
    assert.is_table(getmetatable(f))
    assert.equal('88', f[7])
    assert.equal('88', g[{}])
    assert.equal('10', f())
    assert.equal('20', g())
    assert.equal('50', f:__exec())
    assert.equal('50', g:__exec())
    setmetatable(i, nil)
    assert.is_nil(getmetatable(i))
  end)
  it("nil", function()
    i = nil
    assert.is_nil(getmetatable(i))
    assert.is_table(getmetatable(i, {}))
    setmetatable(i, {__call = function(self, ...) return 'none' end})
    assert.is_table(getmetatable(i))
    assert.equal('none', i())
    setmetatable(i, nil)
    assert.is_nil(getmetatable(i))
  end)
  it("table", function()
    i = {}
    assert.is_nil(getmetatable(i))
    assert.is_table(getmetatable(i, {}))
    setmetatable(i, {__call = function(self, ...) return 'none' end})
    assert.is_table(getmetatable(i))
    assert.equal('none', i())
    setmetatable(i, nil)
    assert.is_nil(getmetatable(i))
  end)
end)
end
