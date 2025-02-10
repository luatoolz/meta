describe("rex", function()
  local meta, is, rex, lib
  setup(function()
    meta = require "meta"
    is = meta.is ^ 'testdata'
    rex = require 'meta.rex'
    lib = require 'rex_pcre2'
  end)
  it("meta", function()
    assert.truthy(is)
    assert.callable(lib.new)
  end)
  it("new", function()
    local re = lib.new('^(?<first>__[\\w_]+)\\s*(?<last>[a-z]+)?')
    assert.same({'__call', 'name', first='__call', last='name'}, re('__call name'))

    re = lib.new('^__[\\w_]+\\s+\\w+$')
    assert.equal('__call name', re('__call name'))

    re = lib.new('^(__[\\w_]+\\s+\\w+)$')
    assert.same({'__call name'}, re('__call name'))

    re = lib.new('^(__[\\w_]+)\\s+(\\w+)$')
    assert.same({'__call', 'name'}, re('__call name'))

    local flags = {}
    lib.flags(flags)
    assert.equal(8, flags.CASELESS)

    re = lib.new('^(__[\\w_]+)\\s+([a-z]+)?', 'ix')
    assert.same({'__call', 'NAME'}, re('__call NAME'))
  end)
  it("matcher", function()
    assert.same('__index', rex.mtname('__index'))
  end)
  it("__mod/__mul", function()
    assert.equal('__index', '__index'*rex.mtname)
    assert.is_true('__index'%rex.mtname)
  end)
end)