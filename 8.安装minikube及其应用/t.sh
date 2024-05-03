
# k8s至少需要2core cpu
# install Minikube & application 


# install docker & kubectl 

yum list docker-ce --showduplicates | sort -r;
yum -y install docker-ce;
systemctl start docker;
systemctl enable docker;
docker  version;


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client



# 安装 Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube


minikube start


# 默认为单节点，可添加节点，https://minikube.sigs.k8s.io/docs/commands/node

# minikube node list
# minikube node add


# 可视化

# minikube dashboard --url
# # 让其它 IP 可以访问
# kubectl proxy --port=8888 --address='0.0.0.0' --accept-hosts='^.*'



# 四、部署应用与访问应用
# kubectl create deployment nginx --image=nginx
# kubectl expose deployment nginx --port=80 --type=NodePort
# # 获取访问地址
# minikube service --url nginx

# 也可以通过 kubectl proxy 拼接 url 访问，https://kubernetes.io/zh/docs/tasks/access-application-cluster/access-cluster/#manually-constructing-apiserver-proxy-urls
# http://10.74.2.71:8888/api/v1/namespaces/default/services/nginx:80/proxy/


# 使用负载均衡访问，Minikube 网络：https://minikube.sigs.k8s.io/docs/handbook/accessing



# # 新开窗口运行
# minikube tunnel --cleanup=true

# # 重新部署
# kubectl delete deployment nginx
# kubectl delete service nginx
# kubectl create deployment nginx --image=nginx
# kubectl expose deployment nginx --port=80 --type=LoadBalancer
# # 查看外部地址
# kubectl get svc


# 通过转发访问，https://kubernetes.io/zh/docs/tasks/access-application-cluster/port-forward-access-application-cluster

# kubectl port-forward pods/nginx-6799fc88d8-p8llb 8080:80 --address='0.0.0.0'


# 五、卸载
# https://minikube.sigs.k8s.io/docs/commands/delete

# minikube stop
# minikube delete --all
# docker rmi kicbase/stable:v0.0.25
# rm -rf ~/.kube ~/.minikube
# sudo rm -rf /usr/local/bin/kubectl /usr/local/bin/minikube
# docker system prune -a
# https://github.com/AliyunContainerService/minikube/wiki

# https://kubernetes.io/zh/docs/tutorials/hello-minikube

# https://www.cnblogs.com/k4nz/p/14543016.html

