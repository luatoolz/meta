describe("string.matches", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(string.matches))
  end)
  it("positive", function()
    assert.equal(2, #("google.com"):matches("%w", "%."))
    assert.equal(2, #("google.com"):matches("google", "com"))
    assert.equal(2, #("www.google.com"):matches("google", "com"))
    assert.equal(3, #("www.google.com"):matches("www", "google", "com"))
    assert.equal(1, #("www.google.com"):matches("", "google", ""))
  end)
  it("negative", function()
    local empty = ''

    assert.equal(0, #empty:matches(''))
    assert.equal(0, #empty:matches('',''))
    assert.equal(0, #empty:matches('','',''))
    assert.equal(0, #empty:matches('',nil))
    assert.equal(0, #empty:matches({}))
    assert.equal(0, #empty:matches(0))
    assert.equal(0, #empty:matches(1))
    assert.equal(0, #empty:matches(false))
    assert.equal(0, #empty:matches(true))

    assert.equal(0, #empty:matches(nil,nil,nil))
    assert.equal(0, #empty:matches(nil,nil))
    assert.equal(0, #empty:matches(nil))
    assert.equal(0, #empty:matches())
  end)
end)