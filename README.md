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
  ________________________________________________________________________________
 |         ----www.wordpress.com-----        |
 |          ______         ______            |
 |         | LB1  |       | LB1 |            |
 |         |__主__|       |__备__|           | 
 |                                           |
 |                                           |
 |      ______       _______     ______      |
 |     | www1 |      | www2 |   | www3 |     |
 |     |______|      |______|   |______|     |
 |                                           |
 |                                           |
 |          ______         ______            |
 |         | DB1  |       | DB2 |            |
 |         |__主__|       |__从__|            |
 |_________________________________________________________________________________


一 haproxy重点说明
创建角色目录，可以使用下面模板生成
ansible-galaxy init --init-path roles/ haproxy

haproxy目录里面
   -- tasks
       - main.yml
	   - install.yml
	   - configure.yml

安装说明部分：
   注册一个变量rc_v，判断命令执行的返回值，如果是存在，说明已经配置了haproxy，那么就跳过安装脚本haproxy_install.sh
- name: check haproxy install evn
  shell: "test -f /etc/haproxy/haproxy.cfg"
  register: rc_v
  #if haproxy is installed.so skip it.
  
  
  二 keepalived说明部分
 
 模板说明部分，这里根据定义的主备判断用那个模板，因为keepalived需要设置主备，所以这里使用了jinja2模板语法，当判断是主的时候，写入主的配置，当判断是从的时候，写入备的配置命令
  
vrrp_instance VI_1 {  
{% if ansible_all_ipv4_addresses[0] == MASTER_IP %}
state {{ MASTERHOST }}
priority {{ priority_m }}
{% elif  ansible_all_ipv4_addresses[0] == SLAVE_IP %}
state {{ SLAVEHOST }}
priority {{ priority_s }}
{% endif %}
#    state MASTER   #指定A节点为主节点 备用节点上设置为BACKUP即可  
    interface eth2   #绑定虚拟IP的网络接口  
    virtual_router_id 51  #VRRP组名，两个节点的设置必须一样，以指明各个节点属于同一VRRP组  
#    priority 100   #主节点的优先级（1-254之间），备用节点必须比主节点优先级低  
    advert_int 1   #组播信息发送间隔，两个节点设置必须一样  
    authentication {   #设置验证信息，两个节点必须一致  
        auth_type PASS  
        auth_pass 1111  
    }  
  
  
  配置部分说明：
  这里使用了tags标签，可以在运行的时候，指定标签。当修改了配置，那么就可以通过标签来操作。
  比如：ansible-playbook -i hosts lb.yml --tags=conf
  
  - name: rsync keepalived.confto /etc/keepalived
  template: src=keepalived.conf.j2 dest=/etc/keepalived/keepalived.conf
  notify:
  - restart keepalived
  tags: conf
- name: start keepalived
  service: name=keepalived state=started
  tags: conf
  
  
  三 nginx部分
  
  安装部分，使用了with_items命令，用于批量循环安装包，这可后续可以放到common角色里面去。
  
  - name: install nginx {{ item }}web server
  yum: name={{ item }} state=present
  with_items:
  - zlib-devel
  - pcre-devel
  
  
  四 mysql部分
  
  这里说明下主从部分，先导出主的wordpress数据库，然后导入到从库里面，停止从库复制，使用ansible的mysql_replication模块，获取master变量，然后根据master获取到的 File和POST，注册从库，启动从库，验证是否同步
  ---

- name: export database from master mysql
  shell: mysqldump -uwordpress -h{{ masterhost }} -pwordpress  wordpress>/root/wordpress.sql 

- name: import slave database from wordpress.sql
  shell: mysql -uwordpress -h{{ slavehost }} -pwordpress  wordpress</root/wordpress.sql 


- name: stopt slave
  mysql_replication: mode=stopslave 

- name: get master status
  mysql_replication: mode=getmaster login_host={{ masterhost }} login_user={{ repluser }} login_password={{ replpass }}
  register: master

- name: configure replication on slave
  mysql_replication:
      mode=changemaster
      master_host={{ masterhost }}
      master_user={{ repluser }}
      master_password={{ replpass }}
      master_log_file={{ master.File }}
      master_log_pos={{ master.Position }}

- name: start slave
  mysql_replication: mode=startslave 

  
