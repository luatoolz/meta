require "compat53"

local mm = require "meta.methods"

local o = setmetatable({}, {__call = function(self, ...) end, __div = function(self, ...) end, test = function(self, ...) end})

describe('methods', function()
  it("__metamethods", function()
    assert.equal('function', type(mm))
    local r = mm(o)
    assert.equal('table', type(r))
    assert.equal('function', type(r.__call))
    assert.equal('nil', type(r.__index))
    assert.equal('function', type(r.__div))
    assert.equal('nil', type(r.test))
  end)
  it("__metamethods + __index", function()
    assert.equal('function', type(mm))
    local r = mm(o, {__index = function() end})
    assert.equal('table', type(r))
    assert.equal('function', type(r.__call))
    assert.equal('function', type(r.__index))
    assert.equal('function', type(r.__div))
    assert.equal('nil', type(r.test))
  end)
end)