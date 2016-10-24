local log = ngx.log
local ERR = ngx.ERR
local ngx_md5 = ngx.md5
local ngx_time = ngx.time

local http = require "resty.http"
local config = require "lua.pay.wx.wx_config"
local pay_utils = require("lua.pay.wx.pay_utils")
local unicode_to_utf8 = pay_utils.unicode_to_utf8
local utf8_to_unicode = pay_utils.utf8_to_unicode
require "LuaXml"
xml = require "xml"

local generate_xml = pay_utils.generate_xml
local generate_sign = pay_utils.generate_sign
local generate_callback_xml = pay_utils.generate_callback_xml

ngx.req.read_body()
local args = ngx.req.get_post_args()

-- 获取扫码的callback 数据，验证扫码是否成功
local callback_xml_table = {}
local flag = false
for key, val in pairs(args) do
    if val == true then
        flag = true
        local callback_xml_data = xml.eval(key)
        for key, val in pairs(callback_xml_data) do
            if key > 0 then
                if type(val) == 'table' then
                    callback_xml_table[val[0]] = val[1]
                end
            end
        end
    end
end

if not flag then
    -- 扫码回调失败
    local resp_data = {}
    resp_data["prepay_id"] = 0
    resp_data["return_code"] = "FAIL"
    resp_data["return_msg"] = "unifiedorder error"
    resp_data["result_code"] = "FAIL"
    resp_data["err_code_des"] = "unifiedorder error"
    local resp_xml = pay_utils.generate_callback_xml(resp_data)
    ngx.say(xml.str(resp_xml))
    return
end

-- 调用统一下单接口生成pre_pay 订单
-- 以下设置待支付产品信息

-- TODO 修改此处商品信息
local product_id = callback_xml_table["product_id"] -- trade_type=NATIVE，此参数必传。此id为二维码中包含的商品ID，商户自行定义
local body = utf8_to_unicode("test body")      -- 商品描述
local detail = utf8_to_unicode("test detail") -- 商品详情
local attach = utf8_to_unicode("test attach") -- 附加信息,判断当前的订单类型
local out_trade_no = "O1234fdsfsaf2" -- 商户订单号
local total_fee = 1 -- 商品总价，单位为分。

local trade_type = "NATIVE" -- 取值如下：JSAPI，NATIVE，APP
local openid = tostring(callback_xml_table["openid"]) -- trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识

local unifiedorder_table = {}
unifiedorder_table["appid"] = config.appid
unifiedorder_table["attach"] = config.attach
unifiedorder_table["spbill_create_ip"] = config.spbill_create_ip
unifiedorder_table["mch_id"] = config.mch_id
unifiedorder_table["notify_url"] = config.notify_url
unifiedorder_table["body"] = body
unifiedorder_table["nonce_str"] = pay_utils.generate_nonce_str()
unifiedorder_table["out_trade_no"] = out_trade_no
unifiedorder_table["total_fee"] = total_fee
unifiedorder_table["trade_type"] = trade_type
unifiedorder_table["openid"] = openid
unifiedorder_table["sign"] = generate_sign(unifiedorder_table)

local unifiedorder_xml_data = generate_xml(unifiedorder_table)
-- 调用统一下单接口
local xml_str = unicode_to_utf8(xml.str(unifiedorder_xml_data)) -- change to xml string
local hc = http:new()
local res, err = hc:request_uri("https://api.mch.weixin.qq.com/pay/unifiedorder", {
    method = "POST",
    body = xml_str,
    headers = {
        ["Content-Type"] = "text/xml",
    },
    ssl_verify = false
})

-- 解析微信服务器返回的结果
local return_xml_data = xml.eval(res.body)
local return_xml_table = {}
for key, val in pairs(return_xml_data) do
    if key > 0 then
        if type(val) == 'table' then
            return_xml_table[val[0]] = val[1]
        end
    end
end

if return_xml_table["return_code"] == "FAIL" or return_xml_table["result_code"] == "FAIL" then
    -- TODO 统一下单失败
    local resp_data = {}
    resp_data["prepay_id"] = 0
    resp_data["return_code"] = "FAIL"
    resp_data["return_msg"] = return_xml_table["return_msg"]
    resp_data["result_code"] = "FAIL"
    resp_data["err_code_des"] = return_xml_table["err_code_des"]
    local resp_xml = pay_utils.generate_callback_xml(resp_data)
    ngx.say(xml.str(resp_xml))
    return
end

-- 统一下单成功
local resp_data = {}
resp_data["prepay_id"] = return_xml_table["prepay_id"]
resp_data["return_code"] = "SUCCESS"
resp_data["return_msg"] = "OK"
resp_data["result_code"] = "SUCCESS"
resp_data["err_code_des"] = "OK"
local resp_xml = generate_callback_xml(resp_data)
ngx.say(xml.str(resp_xml))