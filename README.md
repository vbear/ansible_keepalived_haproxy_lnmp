# ansible_keepalived_haproxy_lnmp

# 学习ansible总结，通过部署 lnmp+keepalived+haproxy高可用，来实战ansbile的格式。

系统运行说明：
    通过ansible一键部署LNMP，用户访问www.wordpress.com 后，会进入haproxy,haproxy主会反向代理到nginx（www1,www2,www3）随机一台服务器上，数据库为主从，DB1为主，DB2为读。当发生故障的时候，LB1如果宕机或应用僵死，那么会自动切换到LB1上，应用服务器www1,www2,www3,为无状态服务，当其中一台挂掉后，haproxy会踢出去，数据库层面没有做高可用，只做了主从复制，没有做主主从从的架构。


主要 内容有下面几个部分
1.批量安装nginx
2.批量安装mysql
3.自动配置mysql主从复制
4.批量安装keepalived
5.批量安装haproxy
6.配置haproxy高可用
 
架构图 部分：
__________________________________________________________________________________
          ----www.wordpress.com-----
           ______         ______
          | LB1  |       | LB1 |   
          |__主__|       |__备__|  
  
  
       ______       _______     ______ 
      | www1 |      | www2 |   | www3 |
      |______|      |______|   |______|
      
      
           ______         ______
          | DB1  |       | DB2 |   
          |__主__|       |__从__|       
      
___________________________________________________________________________________
