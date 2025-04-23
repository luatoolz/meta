require "compat53"
require 'meta.module'
return function(arg, name, modpath)
  local is     = require "meta.is"
  local assert = require "luassert"
  local say    = require "say"
  local n, f, msg = nil, nil, {}
  for i=1,#arg do
    if type(arg[i])=='number' then n=arg[i] end
    if not f and is.callable(arg[i]) then f=arg[i] end
    if type(arg[i])=='string' then msg[#msg+1]=arg[i] end
  end
  local assertion = "assertion." .. name
  local ist = f or is[name]
  local _ = ist or error('meta.assert: not found: is.%s' ^ name)
  local test = function(state, arguments)
    local len = math.max(n or 0, table.maxi(arguments) or 0)
    if len>0 then return ist(table.unpack(arguments, 1, len)) end
    return ist(table.unpack(arguments))
  end
  if #msg>0 then say:set(assertion .. ".positive", msg[1]) end
  if #msg>1 then say:set(assertion .. ".negative", msg[2]) end

-- instead of say it is possible to use:
--  state.failure_message = "unexpected result " .. tostring (i-1) .. ": " .. tostring (arguments [i])

  assert:register("assertion", name, test,
                  assertion .. ".positive",
                  assertion .. ".negative")
  return test
  end