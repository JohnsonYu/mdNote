##以下是使用Openresty 遇到的一些问题，随时记录随时更新
###ngx.location.capture
* ``ngx.var.reqeuest_method`` 这个是Nginx 的变量，此变量无论是在主查询还是子查询中都是获取的主查询的method。

	章老师自己的解释：[mail list](https://groups.google.com/forum/#!searchin/openresty/ngx.var.request_method|sort:relevance/openresty/uhwfB3cwN2Y/esATmDbgP08J)
	> 1. Nginx 标准的 $request_method 变量的值永远是主请求的请求方法。而 ngx_lua 的 
	ngx.req.get_method() 返回的总是当前（子）请求的请求方法。 
	> 2. Nginx 标准的 $arg_NAME 变量的值总是未经过 URI 转义解码的，所以你在 Lua 里面通过 
	ngx.var.arg_NAME 接口读取时（比如 ngx.var.arg_url），应自己再用 ngx.unescape_uri() 
	进行转义（当然，你也可以直接使用 ngx.req.get_uri_args 函数，因为它和 ngx.req.get_post_args 
	一样都会自动进行）。 
	
	> 建议仔细阅读我的 nginx 中文连载教程，以节约时间：http://openresty.org/download/agentzh-nginx-tutorials-zhcn.html 
	里面对这些细节都有专门的讨论。 
	
* capture 子查询会直接跳过access 层请求的处理阶段。[mail list](https://groups.google.com/forum/#!topic/openresty/56h7rzCEBFo)

* 在capture中传递参数时，
	> ngx.location.capture() 的 args 选项参数设置的总是 URL 参数，而不是 urlencoded 的 
POST 表单参数。建议仔细阅读 ngx.location.capture 
的文档：https://github.com/chaoslawful/lua-nginx-module#ngxlocationcapture 



###ngx.timer.at
* 加入在 ``init_worker_by_lua_file`` 中使用了 ``ngx.timer.at`` 在指定了多worker的环境下会被每个worker都执行，如某些只需一个worker执行的在指定 ``worker_id``

```
 local delay = 5
 local handler
 handler = function (premature)
     -- do some routine job in Lua just like a cron job
     if premature then
         return
     end
     local ok, err = ngx.timer.at(delay, handler)
     if not ok then
         ngx.log(ngx.ERR, "failed to create the timer: ", err)
         return
     end
 end
 
-- 指定id号为0 的worker 执行下发
if 0 == ngx.worker.id() then
     local ok, err = ngx.timer.at(delay, handler)
	 if not ok then
	     ngx.log(ngx.ERR, "failed to create the timer: ", err)
	     return
	 end
end
```