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

    assert.equal(table{2}, table({{x=2,y=4}})*select.x)
    assert.equal(table{4}, table({{x=2,y=4}})*select.y)

    assert.equal(table{x=2}, table({x=2,y=4})*select.x)
    assert.equal(table{y=4}, table({x=2,y=4})*select.y)

    assert.equal(table{2,4}, table({{x=2,y=4},{x=4,y=8}})*select.x)
  end)
  it("negative", function()
    assert.equal(nil, select.q({x=2,y=4}))
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