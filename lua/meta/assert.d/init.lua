local pkg = ...
require 'meta.module'
local maxi, assert, say, is, loader =
  require "meta.table.maxi",
  require "luassert",
  require "say",
  require 'meta.is',
  require 'meta.loader'

return loader(pkg) ^ function(argz, name, modpath)
  if not argz then return end
  local n, f, msg = nil, nil, {}
  for i=1,#argz do
    if type(argz[i])=='number' then n=argz[i] end
    if (not f) and is.callable(argz[i]) then f=argz[i] end
    if type(argz[i])=='string' then msg[#msg+1]=argz[i] end
  end
  local assertion = "assertion." .. name
  local ist = f or is[name]
  if not ist then return pkg:error('not found: is.%s'^name) end
  local test = function(state, arguments)
    local len = math.max(n or 0, maxi(arguments) or 0)
    if len>0 then return ist(table.unpack(arguments, 1, len)) end
    return ist(table.unpack(arguments))
  end
  if #msg>0 then say:set(assertion .. ".positive", msg[1]) end
  if #msg>1 then say:set(assertion .. ".negative", msg[2]) end

  assert:register("assertion", name, test,
                  assertion .. ".positive",
                  assertion .. ".negative")
  return test
  end