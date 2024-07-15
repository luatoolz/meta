return function(x)
  return  type(x)=='nil' or
          x==false or
          x==0 or x=='0' or
          x=="" or
          ((type(x)=='string' and x:match("^%s+$")~=nil) and true or false) or
          (type(x)=='table' and type(next(x))=='nil') end