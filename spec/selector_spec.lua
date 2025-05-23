describe("selector", function()
	local meta, is, selector
	setup(function()
    meta = require 'meta'
    is = meta.is
    selector = meta.selector
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(selector))
  end)
  it("positive", function()
    assert.equal(2, selector.x({x=2,y=4}))
    assert.equal(4, selector.y({x=2,y=4}))

    assert.equal(table{2}, table({x=2,y=4})*selector.x)
    assert.equal(table{2}, table({{x=2,y=4}})*selector.x)
    assert.equal(table{4}, table({{x=2,y=4}})*selector.y)
    assert.equal(table{2,4}, table({{x=2,y=4},{x=4,y=8}})*selector.x)
    assert.equal(table{2,44}, table({{x=2,y=4},{w=4,y=8},{x=44,y=8}})*selector.x)
    assert.equal(table{a=2,c=44}, table({a={x=2,y=4},b={w=4,y=8},c={x=44,y=8}})*selector.x)
    assert.equal(table{q=2,e=4}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*selector.x)

    assert.equal(table{q={x=2},e={x=4}}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*selector('x'))
    assert.equal(table{q={x=2},e={z=99},r={x=4}}, table({q={x=2,y=4},w={c=88},e={z=99},r={x=4,y=8}})*selector('x','z'))

    assert.equal(table{q={x=2},e={x=4}}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*selector({'x'}))
    assert.equal(table{q={x=2},e={z=99},r={x=4}}, table({q={x=2,y=4},w={c=88},e={z=99},r={x=4,y=8}})*selector({'x','z'}))

    assert.equal(table{{x=2}}, table({{x=2,y=4}})*selector('x'))
    assert.equal(table{{x=2},{x=4}}, table({{x=2,y=4},{x=4,y=8}})*selector('x'))

    assert.equal(table{{x=2,y=4},{x=4,y=8}}, table({{a=8,x=2,y=4},{x=4,y=8,q=9}})*selector('x','y'))

    assert.equal(table{4,8,44}, table{{2,4,8},{4,8},{},{12},{1,44,8}}*selector[2])
    assert.equal(table{{2,4},{4,8},{12},{1,44}}, table{{2,4,8},{4,8},{},{12},{1,44,8}}*selector(1,2))
  end)
  it("negative", function()
    assert.is_nil(selector.q({x=2,y=4}))
    assert.equal(table{}, table({x=2,y=4})*selector.q)
    assert.equal(table{}, table({{x=2,y=4}})*selector.q)
  end)
  it("nil", function()
    assert.is_nil(selector())
    assert.is_nil(selector(nil))
    assert.is_nil(selector(nil, nil))
    assert.is_nil(selector(nil, nil, nil))
  end)
end)