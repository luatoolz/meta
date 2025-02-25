local pkg = ...
local loader, is, assert, say =
  require 'meta.loader',
  require "meta.is",
  require "luassert",
  require "say"

return loader(pkg) ^ function(arg, name, modpath)
  if not arg then return end
  local n, f, msg = nil, nil, {}
  for i=1,#arg do
    if type(arg[i])=='number' then n=arg[i] end
    if not f and is.callable(arg[i]) then f=arg[i] end
    if type(arg[i])=='string' then msg[#msg+1]=arg[i] end
  end
  local assertion = "assertion." .. name
  local ist = f or is[name]
  if not ist then return pkg:error('not found: is.%s'^name) end
  local test = function(state, arguments)
    local len = math.max(n or 0, table.maxi(arguments) or 0)
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