describe("pkgdir", function()
	local meta, is, pkgdir
	setup(function()
    meta = require "meta"
    is = meta.is
    pkgdir = meta.pkgdir
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(pkgdir))
  end)
  it("positive", function()
--    local pkgdirs = (table() .. package.path:gmatch('[^;]+')) * pkgdir

    local mcache = require 'meta.mcache'
    local pkgdirs2 = require 'meta.mcache.pkgdirs2'
    assert.equal(pkgdirs2, mcache.pkgdirs2)
    _ = mcache.pkgdirs2['meta']

--    print(package.path)
--    for pkg in table.iter(pkgdirs) do
--      for mod, it in table.iter(pkg) do mcache.pkgdirs2[mod]=tostring(it) end
--    end

--    print('pkgdirs2', mcache.pkgdirs2)
--    print('pkgdirs2', pkgdirs2)

--    print('cache.files = ', mcache.files)
--    print('cache.dirs = ', mcache.dirs)
--    print('cache.modules = ', mcache.modules)
--    print('cache.fqmn = ', mcache.fqmn)
  end)
  it("nil", function()
    assert.is_nil(pkgdir())
    assert.is_nil(pkgdir(nil))
    assert.is_nil(pkgdir(nil, nil))
    assert.is_nil(pkgdir(nil, nil, nil))
  end)
end)