describe("wrapper", function()
  local meta
  setup(function()
    meta = require "meta"
    _ = meta.is ^ 'testdata'
  end)
  it("wrap3", function()
    local wrapper = assert(require "testdata.wrap3")
    assert.is_table(wrapper)
    assert.equal('testdata/wrap3', tostring(wrapper))
    assert.equal('testdata/init3', tostring(meta.cache.loader[wrapper]))
    assert.equal('table', wrapper.a)
    assert.same({a='table',b='table',c='table',d='table'}, wrapper)
    assert.same({a='TABLE',b='TABLE',c='TABLE',d='TABLE'}, wrapper * string.upper)
  end)
end)
