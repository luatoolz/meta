--return function(v) return v~='.' and v~='..' end
return function(v) return (v and v~='.' and v~='..') and v or nil end