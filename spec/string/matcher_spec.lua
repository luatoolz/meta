describe("string.matcher", function()
  local meta, match
  setup(function()
    meta = require "meta"
    match = meta.wrapper('meta/matcher', string.matcher)
  end)
  it("match", function()
    assert.equal('module', ('x/pic.same/module'):match('[^./]*$'))
    assert.equal('module', match.id('x/pic.same/module'))

    local basename = string.matcher('[^./]*$')
    assert.equal('module', basename('x/pic.same/module'))
    assert.equal('module', match.basename('x/pic.same/module'))

    local root = string.matcher('^[^/.]+')
    assert.equal('meta', root('meta.loader'))
    assert.equal('meta', root('meta/loader'))
    assert.equal('meta', root('meta'))

    assert.equal('meta', match.root('meta.loader'))
    assert.equal('meta', match.root('meta/loader'))
    assert.equal('meta', match.root('meta'))
    assert.is_nil(root(''))

    assert.is_function(string.gmatch('meta', "^%w+"))
    assert.is_nil(string.gmatch('meta', "^%w+")())
  end)
end)