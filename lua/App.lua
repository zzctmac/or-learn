local _M = {}
local cjson = require "cjson"
function _M.go()
    ngx.say(cjson.encode({a=1}))
end

return _M
