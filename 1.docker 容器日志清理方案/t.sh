# docker 容器日志清理方案 https://www.jianshu.com/p/28f1acb11f6b
docker容器日志清理方案
找出容器日志
在linux上，容器日志一般存放在/var/lib/docker/containers/container_id/下面， 以json.log结尾的文件（业务日志）很大，查看各个日志文件大小的脚本内容如下：

#!/bin/sh

echo "======== docker containers logs file size ========"  

logs=$(find /var/lib/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
             ls -lh $log   
        done  
我们其中一台服务器的docker日志信息如下：


docker logs size
清理正在运行的容器日志（治标）
如果docker容器正在运行，那么使用rm -rf方式删除日志后，通过df -h会发现磁盘空间并没有释放。原因是在Linux或者Unix系统中，通过rm -rf或者文件管理器删除文件，将会从文件系统的目录结构上解除链接（unlink）。如果文件是被打开的（有一个进程正在使用），那么进程将仍然可以读取该文件，磁盘空间也一直被占用。正确姿势是cat /dev/null > *-json.log，当然你也可以通过rm -rf删除后重启docker。接下来，提供一个日志清理脚本内容如下：

#!/bin/sh 

echo "======== start clean docker containers logs ========"  

logs=$(find /var/lib/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
                echo "clean logs : $log"  
                cat /dev/null > $log  
        done  

echo "======== end clean docker containers logs ========"  
但是，这样清理之后，随着时间的推移，容器日志会像杂草一样，卷土重来。

设置Docker容器日志大小(治本)
设置一个容器服务的日志大小上限

在启动容器的时候增加一个参数设置该容器的日志大小，及日志驱动

--log-driver json-file  #日志驱动
--log-opt max-size=[0-9+][k|m|g] #文件的大小
--log-opt max-file=[0-9+] #文件数量
全局设置

编辑文件/etc/docker/daemon.json, 增加以下日志的配置

"log-driver":"json-file",
"log-opts": {"max-size":"500m", "max-file":"3"}
max-size=500m，意味着一个容器日志大小上限是500M，
max-file=3，意味着一个容器有三个日志，分别是id+.json、id+1.json、id+2.json。

然后重启docker守护进程

// 重启docker守护进程

# systemctl daemon-reload

# systemctl restart docker
注意：设置的日志大小，只对新建的容器有效。


