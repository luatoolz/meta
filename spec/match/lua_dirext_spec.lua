describe("match.lua_dirext", function()
  local meta, is, match
  setup(function()
    meta = require "meta"
    is = meta.is
    match = meta.mt.match
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table))
    assert.truthy(is.callable(match.lua_dirext))
  end)
  it("positive", function()
    assert.equal('/init.lua', match.lua_dirext('/init.lua'))
  end)
  it("negative", function()
    assert.is_nil(match.lua_dirext(''))
    assert.is_nil(match.lua_dirext(' '))
    assert.is_nil(match.lua_dirext('  '))
    assert.is_nil(match.lua_dirext('   '))
    assert.is_nil(match.lua_dirext('    '))
    assert.is_nil(match.lua_dirext(true))
    assert.is_nil(match.lua_dirext(false))
    assert.is_nil(match.lua_dirext('.lua'))
  end)
  it("nil", function()
    assert.is_nil(match.lua_dirext())
    assert.is_nil(match.lua_dirext(nil))
  end)
end)