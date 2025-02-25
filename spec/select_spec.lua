describe("select", function()
	local meta, is, select
	setup(function()
    meta = require "meta"
    is = meta.is
    select = meta.select
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(select))
  end)
  it("positive", function()
    assert.equal(2, select.x({x=2,y=4}))
    assert.equal(4, select.y({x=2,y=4}))

    assert.equal(table{2}, table({x=2,y=4})*select.x)
    assert.equal(table{2}, table({{x=2,y=4}})*select.x)
    assert.equal(table{4}, table({{x=2,y=4}})*select.y)
    assert.equal(table{2,4}, table({{x=2,y=4},{x=4,y=8}})*select.x)
    assert.equal(table{2,44}, table({{x=2,y=4},{w=4,y=8},{x=44,y=8}})*select.x)
    assert.equal(table{a=2,c=44}, table({a={x=2,y=4},b={w=4,y=8},c={x=44,y=8}})*select.x)
    assert.equal(table{q=2,e=4}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*select.x)

    assert.equal(table{q={x=2},e={x=4}}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*select('x'))
    assert.equal(table{q={x=2},e={z=99},r={x=4}}, table({q={x=2,y=4},w={c=88},e={z=99},r={x=4,y=8}})*select('x','z'))

    assert.equal(table{q={x=2},e={x=4}}, table({q={x=2,y=4},w={c=88},e={x=4,y=8}})*select({'x'}))
    assert.equal(table{q={x=2},e={z=99},r={x=4}}, table({q={x=2,y=4},w={c=88},e={z=99},r={x=4,y=8}})*select({'x','z'}))

    assert.equal(table{{x=2}}, table({{x=2,y=4}})*select('x'))
    assert.equal(table{{x=2},{x=4}}, table({{x=2,y=4},{x=4,y=8}})*select('x'))

    assert.equal(table{{x=2,y=4},{x=4,y=8}}, table({{a=8,x=2,y=4},{x=4,y=8,q=9}})*select('x','y'))

    assert.equal(table{4,8,44}, table{{2,4,8},{4,8},{},{12},{1,44,8}}*select[2])
    assert.equal(table{{2,4},{4,8},{12},{1,44}}, table{{2,4,8},{4,8},{},{12},{1,44,8}}*select(1,2))
  end)
  it("negative", function()
    assert.is_nil(select.q({x=2,y=4}))
    assert.equal(table{}, table({x=2,y=4})*select.q)
    assert.equal(table{}, table({{x=2,y=4}})*select.q)
  end)
  it("nil", function()
    assert.is_nil(select())
    assert.is_nil(select(nil))
    assert.is_nil(select(nil, nil))
    assert.is_nil(select(nil, nil, nil))
  end)
end)