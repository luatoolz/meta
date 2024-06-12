describe("is", function()
  local meta, is, cache, no
  setup(function()
    meta = require "meta"
    is = meta.is
    cache = meta.cache
    no = meta.no
  end)
  it("std", function()
    assert.is_true(is.loader(meta))
  end)
  it("tostring", function()
    is = is['t']
    assert.equal('t', tostring(is))
    assert.equal('t/loadable', tostring(is.loadable))
    assert.equal('t/indexable', tostring(is.indexable))
    assert.equal('t/net/ip', tostring(is.net.ip))
  end)
  it("call", function()
    assert.is_true(is.callable(string.format))
    assert.is_true(is.cache(cache.loaded))
    assert.equal('table', type(no))
    assert.equal('table', type(meta))
  end)
end)
