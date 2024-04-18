# 如果您想要自动获取服务器IP地址，您可以通过Shell脚本动态获取本地网络接口的IP地址，并将其用于安装k3s代理节点。以下是修改后的脚本：

# bash
#!/bin/bash

# 获取本地网络接口的IP地址
SERVER_IP=$(hostname -I | cut -d' ' -f1)

# 安装k3s服务器
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -

# 获取服务器节点的密钥
NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# 安装k3s代理节点
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$NODE_TOKEN" sh -
# 这样，脚本会自动获取本地网络接口的IP地址，并将其用于安装k3s代理节点。


# 安装完成后，您将拥有一个运行k3s的 Kubernetes 集群。您可以使用 kubectl 命令与集群进行交互，部署和管理容器化应用程序。以下是一些常用的kubectl命令示例：

# 检查集群状态：

# bash
# kubectl cluster-info
# 查看节点信息：

# bash
# kubectl get nodes
# 部署一个示例应用：

# bash
# kubectl create deployment nginx --image=nginx
# 检查部署状态：

# bash
# kubectl get deployments
# 检查Pod状态：

# bash
# kubectl get pods
# 检查服务状态：

# bash
# kubectl get services
# 您还可以根据您的需求使用其他kubectl命令来管理您的应用程序和集群。
