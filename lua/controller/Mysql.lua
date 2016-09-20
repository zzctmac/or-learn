local cjson = require "cjson"
local mysql = require "resty.mysql"

local _M = {}
_M._VERSION = '1.0'
local mt = { __index = _M }

function _M.new(self)
    return setmetatable({}, mt)
end

function _M.go()
    local db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql:", err)
    end
    db:set_timeout(1000)
    local ok, err, errcode, sqlstate = db:connect{
        host = "192.168.33.1",
        port = 3306,
        database = "cms",
        user = "root",
        password = "root",
        max_packet_size = 1024 * 1024
    }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return
    end

    res, err, errcode, sqlstate = db:query("select * from user order by id asc", 10)
    if not res then
        ngx.say("bad result:", err, ": ", errcode, ": ", sqlstate , ".")
        return
    end



    ngx.say(cjson.encode(res))

    res, err, errcode, sqlstate = db:query("select * from user order by id asc limit 10;select 1; select 2; select 3;")
    if not res then
        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    ngx.say("result #1: ", cjson.encode(res))

    local i = 2
    while err == "again" do
        ngx.say(err)
        res, err, errcode, sqlstate = db:read_result()
        if not res then
            ngx.log(ngx.ERR, "bad result #", i, ": ", err, ": ", errcode, ": ", sqlstate, ".")
            return ngx.exit(500)
        end

        ngx.say("result #", i, ": ", cjson.encode(res))
        i = i + 1
    end

    db:send_query("select * from t_b2c limit 2000;select 2;select 3;")
    res, err, errcode, sqlstate =  db:read_result()
    ngx.say("\n")
    ngx.say("result #1: ", cjson.encode(res))
    local i = 2
    while err == "again" do
        ngx.say(err)
        res, err, errcode, sqlstate = db:read_result()
        if not res then
            ngx.log(ngx.ERR, "bad result #", i, ": ", err, ": ", errcode, ": ", sqlstate, ".")
            return ngx.exit(500)
        end

        ngx.say("result #", i, ": ", cjson.encode(res))
        i = i + 1
    end


    local ok, err = db:set_keepalive(10000, 100)
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end
end

return _M