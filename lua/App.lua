local _M = {}
function _M.go()

    local controller = ngx.var.arg_c;
    controller = string.upper(string.sub(controller, 1, 1)) .. string.sub(controller, 2)
    local class_name = "controller." .. controller
    local class = require(class_name)
    local ins = class:new()
    ins.go()


end

return _M
