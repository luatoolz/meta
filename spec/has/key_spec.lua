describe("has.key", function()
	local is, has
	setup(function()
    is = require "meta.is"
    has = is.has
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(has)
    assert.truthy(has.key)
    assert.truthy(is.callable(has.key))
  end)
  it("positive", function()
    assert.truthy(has.key('a', {a=true}))
    assert.truthy(has.key('a', {a=true, b=true}))
    assert.truthy(has.key('a', {a=false}))
    assert.truthy(has.key('a', {a=false, b=true}))
    assert.truthy(has.key(true, {[true]=true}))
    assert.truthy(has.key(true, {[true]=false}))
    assert.truthy(has.key(true, {[true]=true, b=true}))
    assert.truthy(has.key(true, {[true]=false, b=true}))
    assert.truthy(has.key(true, {[true]=true, [false]=true, b=true}))
    assert.truthy(has.key(true, {[true]=true, [false]=false, b=true}))
    assert.truthy(has.key(true, {[true]=false, [false]=true, b=true}))
    assert.truthy(has.key(true, {[true]=false, [false]=false, b=true}))
    assert.truthy(has.key(false, {[true]=true, [false]=true, b=true}))
    assert.truthy(has.key(false, {[true]=true, [false]=false, b=true}))
    assert.truthy(has.key(false, {[true]=false, [false]=true, b=true}))
    assert.truthy(has.key(false, {[true]=false, [false]=false, b=true}))
  end)
  it("negative", function()
    assert.falsy(has.key('a', {}))
    assert.falsy(has.key('a', {b=true}))
    assert.falsy(has.key(false, {[true]=true}))
    assert.falsy(has.key(false, {[true]=false}))
    assert.falsy(has.key(false, {[true]=true, b=true}))
    assert.falsy(has.key(false, {[true]=false, b=true}))
    assert.falsy(has.key('a'))
    assert.falsy(has.key('a', nil))
    assert.falsy(has.key('a', true))
    assert.falsy(has.key('a', 'some'))
    assert.falsy(has.key('a', 77))
    assert.falsy(has.key('a', table.remove))
  end)
  it("nil", function()
    assert.falsy(has.key(nil, nil))
    assert.falsy(has.key(nil))
    assert.falsy(has.key())
  end)
end)