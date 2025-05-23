describe("module.lazy", function()
  local is, lazy
  setup(function()
    is   = require 'meta.is'
    lazy = require "meta.module.lazy"
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(lazy))
  end)
  it("lazys", function()
    local ld = lazy
    assert.same('meta', ld[1])
    ld = setmetatable({'meta'}, getmetatable(ld))
    assert.same({'meta'}, ld)

    local call = ld+'call'
    assert.same({'meta','call'}, call)
    assert.equal(call, ld.call)
    assert.equal(call, rawget(ld,'call'))

    assert.same('meta.call', tostring(ld.call))
    assert.same('meta', tostring(ld))

    assert.equal(is, ld%'is')
    assert.is_nil(ld%'factory')

    assert.equal(ld, ld .. {'is','mt','table'})
    assert.equal('meta.table', tostring(ld.table))
  end)
  it("nil", function()
    assert.is_nil(lazy())
    assert.is_nil(lazy(nil))
    assert.is_nil(lazy(nil, nil))
    assert.is_nil(lazy(nil, nil, nil))
  end)
end)