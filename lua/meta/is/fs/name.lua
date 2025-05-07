local skip = {
  ['']=true,
  ['.']=true,
  ['..']=true,
  ['...']=true,
}
return function(x) return (x~=nil and (not skip[x])) and true or nil end