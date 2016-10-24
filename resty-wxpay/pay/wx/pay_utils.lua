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
        if k == "body" or k == "detail" or k == "attach" then
            tmp[count] = k .. "=" .. unicode_to_utf8(v)
        else
            tmp[count] = k .. "=" .. v
        end
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

local function unicode_to_utf8(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    while true do
        local num1=string.byte(convertStr,i)
        local unicode
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end
        print(unicode)

        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))   
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))    
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    return resultStr
end

local function utf8_to_unicode(str)  
    if not str or str == "" or str == ngx.null then  
        return nil  
    end  
    local res, seq, val = {}, 0, nil  
    for i = 1, #str do  
        local c = string_byte(str, i)  
        if seq == 0 then  
            if val then  
                res[#res + 1] = string_format("%04x", val)  
            end
           seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or  
                              c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or  
                              0  
            if seq == 0 then  
                ngx.log(ngx.ERR, 'invalid UTF-8 character sequence' .. ",,," .. tostring(str))  
                return str  
            end  
  
            val = bit_band(c, 2 ^ (8 - seq) - 1)  
        else  
            val = bit_bor(bit_lshift(val, 6), bit_band(c, 0x3F))  
        end  
        seq = seq - 1  
    end  
    if val then  
        res[#res + 1] = string_format("%04x", val)  
    end  
    if #res == 0 then  
        return str  
    end  
    return "\\u" .. table_concat(res, "\\u")  
end  

_M.generate_sign = generate_sign
_M.generate_xml = generate_xml
_M.generate_callback_xml = generate_callback_xml
_M.generate_nonce_str = generate_nonce_str
return _M