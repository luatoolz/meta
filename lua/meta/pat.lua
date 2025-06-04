require 'meta.string'
local mt    = require 'meta.gmt'
local call  = require 'meta.call'
local save  = require 'meta.table.save'
local computed = require 'meta.mt.computed'
local load  = require 'meta.module.load'

local function nuller(...) return nil end
local invert = {
  ltrim   = true,
  rtrim   = true,
  trim    = true,
  match   = true,
  matchs  = true,
  gsub    = true,
  gsuber  = true,
  find    = true,
  gmatch  = true,
  count   = true,
  split   = true,
  splitz  = true,
}
return setmetatable({}, {
__computed = {
  ok        = function(self) return (#self>0 and type(self.patterns)=='string') and true or nil end,
  isindexed = function(self) local p=self.pattern;  return (type(p)=='string' and (p:match('[^%%]%(.*%)') or p:match('^%(.*%)'))) and true or nil end,
  iswhole   = function(self) local p=self.pattern;  return (type(p)=='string' and p:match('^%^.+%$$')) and true or nil end,

  patterns  = function(self) local p=self.pattern;  return type(p)=='string' and p:gsub('^%^',''):gsub('%$$','') or nil end,
  startp    = function(self) local p=self.patterns; return type(p)=='string' and '^'..p or nil end,
  endp      = function(self) local p=self.patterns; return type(p)=='string' and p..'$' or nil end,
  patternp  = function(self) local p=self.patterns; return type(p)=='string' and ('()('..p..')()') or nil end,

  ltrim     = function(self) return self.ok and function(s) s=string(s, true); return s and s:gsub(self.startp, '') or nil end end,
  rtrim     = function(self) return self.ok and function(s) s=string(s, true); return s and s:gsub(self.endp, '') or nil end end,
  trim      = function(self) return self.ok and function(s) return self.ltrim(self.rtrim(s)) end end,

  match     = function(self) return self.ok and function(s, ...)    s=string(s, true); if s then return s:match(self.pattern, ...)  end; return nil end end,
  matchs    = function(self) return self.ok and function(s, ...)    s=string(s, true); if s then return s:match(self.patterns, ...) end; return nil end end,
  gsub      = function(self) return self.ok and function(s, r, ...) s=string(s, true); if s then return s:gsub(self.patterns, r or '', ...) end; return nil end end,
  find      = function(self) return self.ok and function(s, ...)    s=string(s, true); if s then return s:find(self.patterns, ...)  end; return nil end end,
},
__computable = {
  options   = function(self) return #self>0 and self[2] or nil end,
  pattern   = function(self) return #self>0 and self[1] or nil end,

  gsuber    = function(self) return self.ok and function(r, n) return function(s) s=string(s, true); if s then return self.gsub(s, r or '', n) end; return nil end end end,

  gmatch    = function(self) return self.ok and function(s) s=string(s, true); return s and s:gmatch(self.patterns) or nuller end end,
  count     = function(self) local n=0; return self.ok and function(s) for v in self.gmatch(s) do n=n+1 end; return n end end,
  splitz    = function(self) if self.ok then local f,i,n,got
    return function(s, ...) s=string(s, true); if s then f=s:gmatch(self.patternp); return call.lift(f, function(a,b,c)
      n=(n or 0)+1
      if (not i) and (not a) then return n==1 and s or nil end
      got, i = s[{i or 1,(a and (a-1) or #s)}] or '', c
      return got
    end) end end end end,
  split    = function(self) return self.ok and function(s) return self.splitz(string.null(self.trim(s))) end end,
},
__name='pat',
__tostring=function(self) return table.concat(self, ',') or '' end,
__index = function(self, k) if #self>0 then return computed(self, k) end
  if invert[k] then
    return save(self, k, setmetatable({},{
      __index=function(inv, kk) return (self[kk] or {})[k] end,
    }))
  end
  local search = function(x) return (mt(self)[x] or mt(self).__computable[x] or mt(self).__computed[k]) and true or nil end
  if search(k) then return nil end
  return save(self, k, self(load('matcher', k))) end,
__call = function(self, p, opts)
  if type(p)=='table' then p, opts = table.unpack(p) end
  if type(p)~='string' then return nil end
  assert(type(opts)=='number' or type(opts)=='string' or type(opts)=='nil', 'opts is not a number/string/nil: '..type(opts))
  if #self==0 then return setmetatable({p, opts}, getmetatable(self)) end

  local subj=p and tostring(p) or ''
  if self.isindexed then
    return table.nulled((table()..table.pack(self.match(subj, opts)))-'n') or nil
  end
  return self.match(subj, opts)
end,
})