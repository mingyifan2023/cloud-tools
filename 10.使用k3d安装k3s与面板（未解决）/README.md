使用k3d安装k3s与面板
https://blog.csdn.net/LuRenJia11083/article/details/129058160


1、安装：
1.1安装k3d
1.执行命令：

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
2.检查k3d命令是否安装完成。

Centos 安装 kubectl ：

cat < /etc/yum.repos.d/kubernetes.repo
 
[kubernetes]
 
name=Kubernetes
 
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
 
enabled=1
 
gpgcheck=1
 
repo_gpgcheck=1
 
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
 
EOF
执行安装

yum install -y kubectl

1.2创建 K3s 集群
使用 K3D 命令创建 K3s 集群

k3d cluster create k3scluster --api-port 6443 --servers 1 --agents 2 --port "30500-31000:30500-31000@server:0"
k3d 命令创建一个名为 k3scluster 的集群名称

API 端口设置为 6443

在 K3D/K3s 中，servers等同于控制节点

在 K3D/K3s 中，agents等同于工作节点

port 命令设置控制节点上开放的端口。我们将公开要使用的端口 30500-31000。

1.3查看
查看集群

k3d cluster list

查看节点

kubectl get nodes

kubectl get nodes -o wide

1.4、部署 Kubernetes 面板
1.4.1部署

kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
1.4.2仪表板 RBAC 配置

创建管理员权限。admin-user
创建以下资源清单文件：

dashboard.admin-user.yml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard




dashboard.admin-user-role.yml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
部署配置：admin-user

kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
1.4.3创建令牌

kubectl -n kubernetes-dashboard create token admin-user
1.4.4启动转发代理

kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443 --address=0.0.0.0
2、边缘计算

3、k3s架构
3.1、单节点的k3s架构

1）k3s server节点是运行k3s server命令的机器（裸机或者虚拟机），而k3s Agent 节点是运行k3s agent命令的机器。

2）单点架构只有一个控制节点（在 K3s 里叫做server node，相当于 K8s 的 master node），而且K3s的数据存储使用 sqlite 并内置在了控制节点上

3）在这种配置中，每个 agent 节点都注册到同一个 server 节点。K3s 用户可以通过调用server节点上的K3s API来操作Kubernetes资源。

3.2、高可用的K3S架构

虽然单节点 k3s 集群可以满足各种用例，但对于 Kubernetes control-plane 的正常运行至关重要的环境，可以在高可用配置中运行 K3s。一个高可用 K3s 集群由以下几个部分组成：

1）K3s Server 节点：两个或者更多的server节点将为 Kubernetes API 提供服务并运行其他 control-plane 服务

2）外部数据库：外部数据存储（与单节点 k3s 设置中使用的嵌入式 SQLite 数据存储相反）
—

加载仪表盘

http://ip:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
