local cjson = require("cjson.safe")
local config = require "pay.wx.wx_config"
local pay_utils = require "pay.wx.pay_utils"

local log = ngx.log
local ERR = ngx.ERR
local ngx_time = ngx.time
local ngx_md5 = ngx.md5
local string_upper = string.upper

-- 微信相关配置
local appid = config.appid
local mch_id = config.mch_id
local private_key = config.private_key
local nonce_str = pay_utils.generate_nonce_str()
local time_stamp = ngx_time()

-- TODO 填写你自己的product_id 号
local product_id = "***********"
local stringA = "appid=" .. appid .."&mch_id=" .. mch_id .. "&nonce_str=" .. nonce_str .. "&product_id=" .. product_id 
    .. "&time_stamp=" .. time_stamp
local stringSignTemp =  stringA .. "&key=" .. private_key
local sign = string_upper(ngx_md5(stringSignTemp))

local url = "weixin://wxpay/bizpayurl?&appid=" ..  appid.. "&mch_id=" .. mch_id.. "&nonce_str=".. nonce_str .. "&product_id="
            .. product_id.. "&time_stamp=" .. time_stamp .. "&sign=" .. sign

ngx.say(cjson.encode(response))