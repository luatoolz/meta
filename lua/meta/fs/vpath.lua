require 'meta.string'
local join      = string.joiner('/')
return function(self, k) if self and k then
  local dir=tostring(self):gsub('%/+$','')
  local last={}
  for p in k:gmatch('[^%/]+') do
    local was = dir
    if p=='..' then
      if #dir==0 then error('err parsing dir: "%s"' ^ was) end
      dir=dir:gsub('[^%/]+$','')
      if dir~='/' then dir=dir:gsub('%/$','') end
    else
      if not p:match('^%.+$') then
        dir=join(dir~='' and dir or nil,p)
      else
        error('err parsing p: "%s"' ^ p)
      end
    end
    last={dir:match('^(.*)%/([^%/]+)$')}
  end
  return dir, last
end return nil end