local _M = {
    _VERSION = '0.1'
}
local mt = { __index = _M }

local ngx_md5 = ngx.md5
local string_upper = string.upper
local table_sort = table.sort
local table_concat = table.concat
local ngx_time = ngx.time
local config = require "lua.pay.wx.wx_config"
require "LuaXml"
xml = require "xml"

-- 将Lua table 生成xml格式的string
local function generate_nonce_str()
    return ngx_md5(ngx_time() .. config.mch_id)
end

-- 将Lua table 生成xml格式的string
local function generate_xml(resp_data)
    local xml_data = xml.new("xml")
    for key, val in pairs(resp_data) do
        xml_data:append(key)[1] = val
    end
    return xml_data
end

-- 安装微信的要求生成sign
local function generate_sign( resp_data)
    local tmp = {}
    local count = 1
    for k,v in pairs(resp_data) do
        tmp[count] = k .. "=" .. v
        count = count + 1
    end
    -- 按字典序排序
    table_sort(tmp)
    -- 链接密钥生成sign
    local result_str = table_concat(tmp, "&") .. "&key=" .. config.private_key
    return string_upper(ngx_md5(result_str))
end

local function generate_callback_xml(callback_table)
    local resp_data = {}
    resp_data["appid"] = config.appid
    resp_data["mch_id"] = config.mch_id
    resp_data["nonce_str"] = ngx_md5(ngx_time() .. config.mch_id)
    resp_data["prepay_id"] = callback_table["prepay_id"]
    resp_data["return_code"] = callback_table["return_code"]
    resp_data["return_msg"] = callback_table["return_msg"]
    resp_data["result_code"] = callback_table["result_code"]
    resp_data["err_code_des"] = callback_table["err_code_des"]
    resp_data["sign"] = generate_sign(resp_data)
    return generate_xml(resp_data)
end

_M.generate_sign = generate_sign
_M.generate_xml = generate_xml
_M.generate_callback_xml = generate_callback_xml
_M.generate_nonce_str = generate_nonce_str
return _M