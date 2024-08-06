describe("type", function()
  local meta, tt
  setup(function()
    meta = require "meta"
    tt = meta.type
  end)
  it("type", function()
    assert.is_table(meta)
    assert.is_table(tt)
    assert.equal('meta/loader', tt(meta.loader))
    assert.equal('meta', tt(meta))
    assert.equal('meta/module', tt(meta.module))
  end)
end)
