local _M = {
    _VERSION = '0.1'
}
local mt = { __index = _M }

-- 配置商户信息
_M.appid = "  商户appid  "
_M.mch_id = "  商户mch_id  "
_M.notify_url = "http://服务器地址/pay/wx/notify" -- 接收微信支付异步通知回调地址，通知url必须为直接可访问的url，不能携带参数
_M.spbill_create_ip = "服务器IP地址" -- 服务器IP地址
_M.private_key = "*****************" -- 商户在Api安全中设置的私钥

return _M