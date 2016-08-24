# goldendata_homework
这是goldendata的homework部署文档

通过在AWS上使用EC2、RDS、负载均衡器集合Ansible工具搭建了Discuz论坛

WEB层：使用了2台EC2，使用负载均衡器，使其能够根据权重实现负载均衡和高可用，比如当其中一台EC2的Nginx挂了之后，负载均衡器能够快速切换到另外一台EC2上，实现论坛的高可用

RDS层：使用了一台MySQL数据库，用于保存Discuz产生的数据。因为只是测试，所以只使用了一台数据库。如果访问量很大的情况下，可以建从库，实现主从复制和读写分离

应用层：应用程序使用的是Discuz 3.2x版本,由于时间原因，只开放了注册、发帖等功能

在部署的过程中使用了Ansible来搭建运行环境和安装Discuz。
Ansible节点设置：

vim /etc/ansible/hosts
[test]
52.78.28.33
52.78.145.133

Ansible的目录结构如下：
tree /ansible/
/ansible/
├── roles
│   ├── discuz
│   │   ├── defaults
│   │   ├── files
│   │   │   ├── discuz_install.sh
│   │   │   └── Discuz_X3.2_SC_UTF8.zip
│   │   ├── handlers
│   │   ├── meta
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   └── vars
│   ├── nginx
│   │   ├── defaults
│   │   ├── files
│   │   │   ├── nginx
│   │   │   └── nginx_install.sh
│   │   ├── handlers
│   │   ├── meta
│   │   ├── tasks
│   │   ├── templates
│   │   └── vars
│   └── php
│       ├── defaults
│       ├── files
│       │   ├── php-fpm
│       │   └── php_install.sh
│       ├── handlers
│       ├── meta
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       └── vars
└── web.yml


执行和检查：
cd /ansible
ansible-playbook web.yml --syntax-check  #检查语法
ansible-playbook web.yml  #执行


论坛地址：http://029city.cn


