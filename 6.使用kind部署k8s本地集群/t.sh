# install docker 
sudo apt install docker.io



# install kubectl 
sudo apt install apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt install kubeadm kubelet kubectl kubernetes-cni
kubectl version --client=true --short

# install kind 
go install sigs.k8s.io/kind@v0.12.0


kind version


# create cluster 
# kind create cluster

# kubectl cluster-info --context kind-kind



#  kubectl get nodes -o wide
#   docker ps


kind create cluster --config cluster.yaml --name kindcluster

kind create cluster --config kind.yaml --name spiders

kind create cluster --config kind-config.yaml --image=kindest/node:v1.19.11
