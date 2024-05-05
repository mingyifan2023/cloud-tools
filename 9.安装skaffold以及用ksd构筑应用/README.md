# k3dとskaffoldで始めるKubernetesローカル開発
これは、k3dとskaffoldで始めるKubernetesローカル開発するチュートリアルです。

## prerequisite

- OS
  - ubuntu 20.04 or cloudshell
- Tools
  - docker
  - kubectl
  - make
  - curl

## install k3d
```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

## install skaffold
```
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```

## create cluster 
```
make create
```

## develop using skaffold
```
make dev
```

