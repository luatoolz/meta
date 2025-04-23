describe('require', function()
  local is, req, call, save
  setup(function()
    is = require "meta.is"
    req = require "meta.mt.require"
    call = require 'meta.call'
    save = call.report
    call.report=false
  end)
  teardown(function()
    call.report=save
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(req))
    assert.is_table(req('meta.mt.require'))
  end)
  it("positive", function()
    local m = req('meta')
    assert.equal(is, m.is)
    assert.equal(is, m('is'))
    assert.is_nil(select(2, req('is')))
  end)
  it("negative", function()
    assert.is_nil(req({}))
    assert.is_nil(req({'type'}))
    assert.is_nil(req(0))
    assert.is_nil(req(''))
    assert.is_nil(req(false))
    assert.is_nil(req(true))

    local m = req('meta')
    assert.is_nil(m())
    assert.is_nil(m(nil))
    assert.is_nil(m(''))

    assert.is_nil(m({}))
    assert.is_nil(m({'type'}))
    assert.is_nil(m(0))
    assert.is_nil(m(false))
    assert.is_nil(m(true))

    local tt = {['nil']=true, string=true}
    assert.is_true(tt[type(select(2, req('')) or nil)])
    assert.is_true(tt[type(select(2, req()) or nil)])
    assert.is_true(tt[type(select(2, m('')) or nil)])
    assert.is_true(tt[type(select(2, m()) or nil)])
  end)
  it("nil", function()
    assert.is_nil(req())
    assert.is_nil(req(nil))
    assert.is_nil(req(nil, nil))
  end)
end)