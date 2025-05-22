describe("module.loaded", function()
	local is, loaded
	setup(function()
    require 'meta'
    require 'meta.module'
    require 'meta.loader'
    is = require 'meta.is' ^ 'testdata'
    loaded = require 'meta.module.loaded'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.is_true(is.callable(loaded))
  end)
  it("positive", function()
    assert.equal('meta', loaded('meta'))
    assert.equal('meta.module', loaded('meta.module'))
    assert.equal('meta.module', loaded('meta/module'))

    assert.equal('meta.loader', loaded('meta.loader'))
    assert.equal('meta.loader', loaded('meta/loader'))

    assert.equal('meta/assert.d', loaded('meta/assert.d'))
    assert.equal('meta.is.like', loaded('meta/is/like'))

    assert.equal('meta.is.toindex', loaded('meta/is/toindex'))
    assert.equal('testdata.ok', loaded('testdata.ok'))
    assert.equal('testdata.ok', loaded('testdata/ok'))

    assert.equal('testdata/files/a/a', loaded('testdata/files/a/a'))
    assert.equal('testdata.files.a.a', loaded('testdata.files.a.a'))

    assert.equal('testdata/files/b/b', loaded('testdata/files/b/b'))
    assert.equal('testdata/assert.d/callable', loaded('testdata/assert.d/callable'))
--    assert.equal('libpaths', loaded('libpaths'))
  end)
  it("negative", function()
    assert.is_nil(loaded(''))
    assert.is_nil(loaded({}))
    assert.is_nil(loaded({'type'}))
    assert.is_nil(loaded(0))
    assert.is_nil(loaded(false))
    assert.is_nil(loaded(true))
  end)
  it("nil", function()
    assert.is_nil(loaded(nil))
    assert.is_nil(loaded())
  end)
end)