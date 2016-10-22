local log = ngx.log
local ERR = ngx.ERR

local utils = require "lua.utils"
local pay_utils = require "lua.pay.wx.pay_utils"
require "LuaXml"
xml = require "xml"

ngx.req.read_body()
local args = ngx.req.get_post_args()

-- 获取notify 数据，验证支付
local notify_xml_table = {}
local flag = false
for key, val in pairs(args) do
    if val == true then
        flag = true
        local notify_xml_data = xml.eval(key)
        for key, val in pairs(notify_xml_data) do
            if key > 0 then
                if type(val) == 'table' then
                    notify_xml_table[val[0]] = val[1]
                end
            end
        end
    end
end

local function generate_notify_resp(isSuccess)
    local resp_data = {}
    if isSuccess then
        resp_data["return_code"] = "SUCCESS"
        resp_data["return_msg"] = "OK"
    else
        resp_data["return_code"] = "FAIL"
        resp_data["return_msg"] = "verify error"
    end
    return pay_utils.generate_xml(resp_data)
end

if not flag then
    -- notify回调失败
    local resp_xml = generate_notify_resp(false)
    ngx.say(xml.str(resp_xml))
    return
end

-- TODO 订单更新流程
--[[
    返回数据格式
        time_end  20161021162543
        total_fee  1
        appid  wxedb0c4d29d518c4c
        trade_type  NATIVE
        bank_type  CFT
        sign  246DEFB9BD0DEC2EAD67249B0DD4F905
        openid  oRFx7v-G_gzl2t2wb6gKoqoqiUdE
        transaction_id  4009472001201610217304011698
        return_code  SUCCESS
        result_code  SUCCESS
        nonce_str  779e58573fcecdd1e95fc3b1e7e36418
        fee_type  CNY
        mch_id  1397875102
        is_subscribe  N
        out_trade_no  O1234fdsfsaf2
        cash_fee  1
]]

local resp_xml = generate_notify_resp(true)
ngx.say(xml.str(resp_xml))