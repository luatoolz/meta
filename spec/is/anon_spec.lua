describe("is.non", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = require "meta.is"
	end)
	teardown(function()
    is.non=nil
	end)
  it("meta", function()
    assert.truthy(is)
    assert.equal(is, meta.is)
    assert.truthy(is.callable)

    assert.equal(is, package.loaded['meta.is'])
    assert.truthy(is.table)
    assert.truthy(is.callable(is.table))

    local non = rawget(is, 'non')
    assert.equal(nil, non)
    assert.equal('nil', type(non))

    non = is.non
    assert.equal('table', type(non))
    assert.equal(non, is.non)

    assert.equal(getmetatable(is), getmetatable(is.non))
    assert.equal(true, rawget(non, '__non'))
    assert.equal(true, non.__non)
    assert.equal(true, is.non.__non)

    assert.equal(nil, rawget(non, '__path'))
    assert.equal(nil, non.__path)
    assert.equal(nil, is.__path)

    assert.equal(non, rawget(is, 'non'))
    assert.equal(rawget(is, 'non'), rawget(package.loaded['meta.is'], 'non'))
    assert.equal(is.non, package.loaded['meta.is'].non)

    assert.falsy(is.__non)
    assert.truthy(is.callable(is.non.callable))
    assert.not_function(is.non.callable)
    assert.not_function(is.non.atom)
    assert.is_function(is.non.falsy)
    assert.is_function(is.non.truthy)
  end)
  it("positive", function()
    assert.is_true(is.atom(77))
    assert.is_true(is.non.callable({}))
    assert.is_true(is.non.atom({}))
    assert.is_true(is.non.falsy())
  end)
  it("negative", function()
    assert.is_nil(is.non.callable(is))
    assert.is_nil(is.non.callable(is.callable))
    assert.is_nil(is.non.callable(string.format))
    assert.is_nil(is.non.truthy())
  end)
  it("nil", function()
    assert.is_true(is.non.callable())
    assert.is_true(is.non.callable(nil))
  end)
end)