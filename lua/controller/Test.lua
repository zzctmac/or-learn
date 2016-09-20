local _M = {}
_M._VERSION = '1.0'
local mt = { __index = _M }

function _M.new(self)
    return setmetatable({}, mt)
end

function _M.go()
   ngx.say('hello test')



end

return _M