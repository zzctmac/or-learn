local _M = {}
_M._VERSION = '1.0'
local mt = { __index = _M }

function _M.new(self)
    return setmetatable({}, mt)
end

function _M.go()
    local memcached = require "resty.memcached"
    local memc, err = memcached:new()
    if not memc then
        ngx.say("failed to instantiate memc:", err)
        return
    end
    memc:set_timeout(1000)

    local ok, err = memc:connect("127.0.0.1", 11211)
    if not ok then
        ngx.say("failed to connect:", err)
        return
    end


    local ok,err = memc:add("dog", 32)
    if not ok then
        ngx.say("failed to set dog: ", err)
        return
    end

    local res, flags, err = memc:get("dog")
    if err then
        ngx.say("failed to get dog: ", err)
        return
    end

    if not res then
        ngx.say("dog not found")
        return
    end

    ngx.say("dog: ", res)

    local ok, err = memc:set_keepalive(10000, 100)
    if not ok then
        ngx.say("cannot set keepalive: ", err)
        return
    end


end

return _M