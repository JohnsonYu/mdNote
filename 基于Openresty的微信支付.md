基于Openresty 的微信支付
=======================
#### 背景介绍
最近做公司网站的微信支付。很常见的一个功能，大概实现的东西就是在网站上选择相应的产品，使用微信扫一扫付款。很多网站都有这个功能，鉴于这个功能的如此常见决定记录下中间遇到的问题。

#### 相关软件
+ [Openresty 框架](https://moonbingbing.gitbooks.io/openresty-best-practices/content/index.html) 很长一段时间的了解后，一直在此基础上用Lua做Web 开发，目前用起来还比较顺手，随着她传播的更广，应该会有更多的组件和更丰富的管理工具。
+ [LuaXml 库](http://viremo.eludi.net/LuaXML/)，由于微信端收发数据都是xml 格式，所以在Lua端需要解析和生成xml的相关操作，选择这个Lua库后，准备用此做为解析生成工具库。
+ [微信支付](https://pay.weixin.qq.com/wiki/doc/api/native.php?chapter=6_4)，本次实践采用的是扫码支付中的模式一，相关介绍和支付流程可见微信官方的简介和流程图。