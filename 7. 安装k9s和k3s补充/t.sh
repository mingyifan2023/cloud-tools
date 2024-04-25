

#  install k3 
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION="v1.23.15+k3s1" sh -          

kubectl get nodes

# chmod +x k9s
# mv k9s /usr/local/bin/
# # 将k3s的配置文件放到.kube/cofig下，k9s才可以用
# cp /etc/rancher/k3s/k3s.yaml .kube/config

#  install  k9s


# 好的，让我们将查找 k9s 的实际安装路径并将其添加到 PATH 环境变量中，以便可以直接使用 k9s 命令。

# bash
# 安装 Snapd
sudo yum -y install epel-release
sudo yum -y install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

# 重新安装 k9s
sudo snap install k9s

# 查找 k9s 的实际安装路径
k9s_path=$(sudo find /snap/ -name k9s)

# 将 k9s 安装路径添加到 PATH 环境变量中
echo "export PATH=\"\$PATH:$k9s_path\"" >> ~/.zshrc  # 如果使用的是 zsh
# echo "export PATH=\"\$PATH:$k9s_path\"" >> ~/.bashrc  # 如果使用的是 bash

# 使环境变量生效
source ~/.zshrc  # 如果使用的是 zsh
# source ~/.bashrc  # 如果使用的是 bash
# 这样做将会将 k9s 的安装路径添加到 ~/.zshrc（如果你使用的是 zsh）或 ~/.bashrc（如果你使用的是 bash）文件中，并使其生效，这样你就可以直接在终端中使用 k9s 命令了。

echo "alias k9s='/snap/k9s-nsg/11/bin/k9s'" >> ~/.bashrc




