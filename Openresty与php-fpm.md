Openresty 与php-fpm
===
##背景介绍
最近做的东西需要结合部分php程序，此篇将这个部署过程记录下来。


##相关软件

###1. PHP-FPM

+ [PHP-FPM](https://php-fpm.org/): 关于CGI、FastCGI、PHP-FPM 之间的关系，网络上有个比较有趣的说法：

> &emsp;&emsp;你(PHP)去和爱斯基摩人(web服务器，如 Apache、Nginx)谈生意
> 你说中文(PHP代码)，他说爱斯基摩语(C代码)，互相听不懂，怎么办？那就都把各自说的话转换成英语(FastCGI 协议)吧。
> 怎么转换呢？你就要使用一个翻译机(PHP-FPM) (当然对方也有一个翻译机，那个是他自带的)
> 我们这个翻译机是最新型的，老式的那个（PHP-CGI）被淘汰了。不过它(PHP-FPM)只有年轻人（Linux系统）会用，老头子们（Windows系统）不会摆弄它，只好继续用老式的那个。

附带几篇相关的资料：

* [FastCgi与PHP-fpm之间是个什么样的关系](https://segmentfault.com/q/1010000000256516)
* [Nginx+Php-fpm运行原理详解](https://segmentfault.com/a/1190000007322358)

###2. Openresty
* [Best Practices](https://moonbingbing.gitbooks.io/openresty-best-practices/content/index.html)

##开始配置

机器环境：

```
ubuntu@ubuntu:~$ cat /proc/version
Linux version 4.2.0-27-generic (buildd@lcy01-23) (gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) ) #32~14.04.1-Ubuntu SMP Fri Jan 22 15:32:26 UTC 2016

ubuntu@ubuntu:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04.4 LTS
Release:	14.04
Codename:	trusty
```
安装PHP-FPM

`sudo apt-get install php5-fpm`

配置步骤：

1. 修改`/etc/php5/fpm/php.ini` 这个文件中 `cgi.fix_pathinfo=0`(***默认被注释或者=1，改为=0***)






