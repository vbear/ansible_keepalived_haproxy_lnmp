# ansible_keepalived_haproxy_lnmp

# 学习ansible总结，通过部署 lnmp+keepalived+haproxy高可用，来实战ansbile的格式。
 
主要 内容有下面几个部分
1.批量安装nginx
2.批量安装mysql
3.自动配置mysql主从复制
4.批量安装keepalived
5.批量安装haproxy
6.配置haproxy高可用
 
架构图 部分：
      ----www.wordpress-----
           ______        ______
          | LB1 |       | LB1 |   
          |_____|       |_____|  
  
  
       ______       ______     ______ 
      | LB1 |       | LB1 |   | www3 |
      |_____|       |_____|   |______|
      
      
      
      
