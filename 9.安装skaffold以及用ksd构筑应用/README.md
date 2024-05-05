k3dとskaffoldで始めるKubernetesローカル開発
================================

## Skaffold的特点

* 没有服务器端组件，所以不会增加你的集群开销
* 自动检测源代码中的更改并自动构建/推送/部署
* 自动更新镜像TAG，不要担心手动去更改kubernetes的 manifest 文件
* 一次性构建/部署/上传不同的应用，因此它对于微服务同样完美适配
* 支持开发环境和生产环境，通过仅一次运行manifest，或者持续观察变更

## Skaffold 流程化(CICD)作用
* 用本地源代码构建 Docker 镜像
* 用它的sha256值作为镜像的标签
* 设置skaffold.yaml文件中定义的 kubernetes manifests 的镜像地址
* 用kubectl apply -f命令来部署 kubernetes 应用



####  k3dとskaffoldで始めるKubernetesローカル開発 https://cloudandbuild.jp/blog/article-2
####  https://github.com/cloudandbuild/example-development-k3d-skaffold
####  用 Skaffold 搭一个 Kubernetes & Spring Boot CI/CD 工作流 https://mp.weixin.qq.com/s/jZBVJU7Cgej7MnVGWLvWZQ
####   Skaffold-简化本地开发kubernetes应用的神器 https://mp.weixin.qq.com/s/oiHgV1zRrI9NSccvAtxtlg





[](about:blank#%E8%A6%81%E7%B4%84)[#](about:blank#%E8%A6%81%E7%B4%84)要約
-----------------------------------------------------------------------

*   Kubernetesのローカル開発環境を整える
*   skaffoldでビルド・デプロイを自動化する
*   docker-compose likeに使えるようMakefileを作ってみる

[](about:blank#%E3%81%AF%E3%81%98%E3%82%81%E3%81%AB)[#](about:blank#%E3%81%AF%E3%81%98%E3%82%81%E3%81%AB)はじめに
-------------------------------------------------------------------------------------------------------------

Kubernetes使ってますか？  
コンテナオーケストレーションのデファクトスタンダードと言われて久しいですが、私が業務で関わる案件は大体ECSが使われています（汗）  
自社開発ではKubernetes一択なのですが、なぜコンテナオーケストレーションとして、なぜKubernetesを選ぶかというと以下が理由です。

*   デファクトスタンダードである
*   特定のCloudベンダーにロックインされないので、ポータブルである
    *   ローカルでも論理的には近しい環境を構築できる（アーキテクチャ次第だが）
*   k8sのエコシステムを享受できる
*   枯れた技術（？）

ローカルでクラスターを構築できるという点が便利だなと思います。  
素のKubernetesクラスターを立てるのは大変なのですが、次のツールなどが出揃っていて、LaptopやDesktopでサクッとクラスターを構築できることが魅力です。これは、ローカル開発においてローカルのk8s cluster上にサービスをデプロイして本番に近しい構成でテストをすることができます。Cloudを使わなくてもテストができるので、結合テストやE2Eの自動化がやりやすくなりますし、開発スピードを向上できることが気に入っています。

[](about:blank#kubernetes%E3%83%87%E3%82%A3%E3%82%B9%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3)[#](about:blank#kubernetes%E3%83%87%E3%82%A3%E3%82%B9%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3)Kubernetesディストリビューション
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ローカル開発向けで代表的な Kubernetesディストリビューションを列挙します

*   microk8s
*   minikube
*   k3s
*   k3d
*   Docker for Mac
*   etc...

他にもあると思いますが、私が試したことがあるのが上記です。  
気に入ったものを使っていけば良いと思いますが、  
今回の記事では、`k3d` を使っていこうと思います。  
VMベースのものより、コンテナーベースのほうが軽量でストレスが少ないかなと思いました。  
`k3d`は、Docker上にk3sのServer, Agentが動くので、Clusterを作ったり破棄したりするのが簡単にできて便利だと思います。ベースになっている`k3s`はCNCFがホストしていますので、普及・成長を期待しています。  
k8s clusterのネットワーク上にRegistryのDockerコンテナを動作させて、ローカルでイメージをプッシュすれば、Clusterから参照することができます。これで、一通りローカルでデプロイまで完結することができます。

[](about:blank#%E5%89%8D%E6%8F%90)[#](about:blank#%E5%89%8D%E6%8F%90)前提
-----------------------------------------------------------------------

*   OS
    *   ubuntu 20.04
*   Tools
    *   docker
    *   kubectl
    *   make
    *   curl

この記事の全コードは  
[GitHub](https://github.com/cloudandbuild/blog-article-resources/tree/main/content/blog/article-2)  
を参照ください。  
CloudShellで試すこともできます。

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/cloudandbuild/blog-article-resources.git&cloudshell_tutorial=README.md&cloudshell_workspace=content/blog/article-2)

[](about:blank#workspace-directory)[#](about:blank#workspace-directory)workspace directory
------------------------------------------------------------------------------------------

```
mkdir -p ~/workspace/project
cd ~/workspace/project

```

[](about:blank#k3d-install)[#](about:blank#k3d-install)k3d install
------------------------------------------------------------------

[k3d](https://github.com/rancher/k3d)のGitHubに記載されている通り、Installを行います。  
この記事を作成時点では、`v4.2.0`です。

```
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

```

k3dがCLIで利用できることを確認します

```
$ k3d version
k3d version v4.2.0
k3s version v1.20.2-k3s1 (default)
$ k3d
Usage:
  k3d [flags]
  k3d [command]
Available Commands:
  cluster     Manage cluster(s)
  completion  Generate completion scripts for [bash, zsh, powershell | psh]
  help        Help about any command
  image       Handle container images.
  kubeconfig  Manage kubeconfig(s)
  node        Manage node(s)
  version     Show k3d and default k3s version
Flags:
  -h, --help      help for k3d
      --verbose   Enable verbose output (debug logging)
      --version   Show k3d and default k3s version
Use "k3d [command] --help" for more information about a command.

```

[](about:blank#makefile%E3%82%92%E4%BD%9C%E3%82%8B)[#](about:blank#makefile%E3%82%92%E4%BD%9C%E3%82%8B)Makefileを作る
------------------------------------------------------------------------------------------------------------------

docker-compose likeにClusterのcreateができるようMakefileを作ります  
簡単に説明すると`create`で下記のことを行います。`down`は逆のことを行います。

*   k3dでclusterを作る
*   volumeを作る
*   registory containerをk3d clusterと同じネットワークで実行する

```
# ~/workspace/project/Makefile
# k3d, registry vars
CLUSTER_NAME=myk3dcluster
REGISTRY_IMAGE=registry:2
REGISTRY_HOST=registry.local
REGISTRY_PORT=5000
REGISTRY_VOLUME=local_registry_volume
DEFAULT_REPO="$(REGISTRY_HOST):$(REGISTRY_PORT)"
# for k3d cluster
.PHONY: create
create:
	k3d cluster create $(CLUSTER_NAME) \
		--volume "$(PWD)/registry/registries.yaml:/etc/rancher/k3s/registries.yaml"
	docker volume create $(REGISTRY_VOLUME)
	docker container run -d \
		--net k3d-$(CLUSTER_NAME) \
		--name $(REGISTRY_HOST) \
		-v $(REGISTRY_VOLUME):/var/lib/registry \
		--restart always \
		-p $(REGISTRY_PORT):$(REGISTRY_PORT) \
		$(REGISTRY_IMAGE)
.PHONY: start
start:
	k3d cluster start $(CLUSTER_NAME)
.PHONY: dev
dev:
	skaffold dev --profile dev --port-forward --default-repo $(DEFAULT_REPO)
.PHONY: down
down:
	k3d cluster stop $(CLUSTER_NAME)
.PHONY: destroy
destroy:
	docker stop $(REGISTRY_HOST)
	docker rm $(REGISTRY_HOST)
	docker volume rm $(REGISTRY_VOLUME)
	k3d cluster delete $(CLUSTER_NAME)

```

[](about:blank#registry-config)[#](about:blank#registry-config)registry config
------------------------------------------------------------------------------

[k3dのprivate registryに関する公式ドキュメント](https://k3d.io/usage/guides/registries/)に記載されている通り、registries.yamlを配置することでローカルに立てたRegistryにアクセスすることが可能になります。

`mkdir -p ~/workspace/project/registry`

```
# ~/workspace/project/registry/registries.yaml
mirrors:
  "registry.local:5000":
    endpoint:
      - http://registry.local:5000


```

[](about:blank#make%E3%81%A7cluster%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%9F%E3%82%8A%E7%A0%B4%E6%A3%84%E3%81%99%E3%82%8B)[#](about:blank#make%E3%81%A7cluster%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%9F%E3%82%8A%E7%A0%B4%E6%A3%84%E3%81%99%E3%82%8B)makeでclusterを作ったり破棄する
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*   create

cluster及びregistryを生成します。

```
$ make create
k3d cluster create myk3dcluster \
        --volume "/home/sakurai/workspace/project/registry/registries.yaml:/etc/rancher/k3s/registries.yaml"
WARN[0000] No node filter specified                     
INFO[0000] Created network 'k3d-myk3dcluster'           
INFO[0000] Created volume 'k3d-myk3dcluster-images'     
INFO[0001] Creating node 'k3d-myk3dcluster-server-0'    
INFO[0003] Creating LoadBalancer 'k3d-myk3dcluster-serverlb' 
INFO[0010] Cluster 'myk3dcluster' created successfully! 
INFO[0010] You can now use it like this:                
kubectl cluster-info
docker volume create local_registry_volume
local_registry_volume
docker container run -d \
        --net k3d-myk3dcluster \
        --name registry.local \
        -v local_registry_volume:/var/lib/registry \
        --restart always \
        -p 5000:5000 \
        registry:2
7a343d43f1486db95b886a1985f83527dfea59e60bb25bb8da863dd3cee09dbe

```

docker psで確認します。

```
$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED              STATUS              PORTS                              NAMES
7a343d43f148   registry:2                 "/entrypoint.sh /etc…"   About a minute ago   Up About a minute   5000/tcp, 0.0.0.0:5000->5000/tcp   registry.local
4b1d863e3581   rancher/k3d-proxy:v3.0.1   "/bin/sh -c nginx-pr…"   About a minute ago   Up About a minute   80/tcp, 0.0.0.0:45627->6443/tcp    k3d-myk3dcluster-serverlb
589456e30bac   rancher/k3s:v1.18.6-k3s1   "/bin/k3s server --t…"   2 minutes ago        Up About a minute                                      k3d-myk3dcluster-server-0

```

cluster生成時に自動的に.`.kube/config`にアクセス情報が記載されるようです。  
下記のコマンドでkubernetesにアクセスできるか確認します。

```
kubectl cluster-info

```

*   stop

k3d containerのdocker stop が行われます。

```
$ make stop
k3d cluster stop myk3dcluster
INFO[0000] Stopping cluster 'myk3dcluster'              

```

*   start

k3d containerのdocker run が行われます。

```
$ make start
k3d cluster start myk3dcluster
INFO[0000] Starting cluster 'myk3dcluster'              
INFO[0000] Starting Node 'k3d-myk3dcluster-server-0' 

```

*   down

cluster及びregistryを削除します。

```
$ make down
k3d cluster stop myk3dcluster
INFO[0000] Stopping cluster 'myk3dcluster'              
docker stop registry.local
registry.local
docker rm registry.local
registry.local
docker volume rm local_registry_volume
local_registry_volume
k3d cluster delete myk3dcluster
INFO[0000] Deleting cluster 'myk3dcluster'              
INFO[0000] Deleted k3d-myk3dcluster-serverlb            
INFO[0000] Deleted k3d-myk3dcluster-server-0            
INFO[0000] Deleting cluster network '8bc0fecee2ca0660c549c7630a1689fc0f90e1082fedb1f60ae5895b655f9f6e' 
INFO[0000] Deleting image volume 'k3d-myk3dcluster-images' 
INFO[0000] Removing cluster details from default kubeconfig... 
INFO[0000] Removing standalone kubeconfig file (if there is one)... 
INFO[0000] Successfully deleted cluster myk3dcluster! 

```

[](about:blank#skaffold-config)[#](about:blank#skaffold-config)skaffold config
------------------------------------------------------------------------------

`make dev` が動作するようskaffoldを設定します。

*   skaffold.yaml

```
apiVersion: skaffold/v2beta1
kind: Config
metadata:
  name: service_name
build:
  artifacts:
    - image: hello
      context: .
  tagPolicy:
    sha256: {}
  local:
    useBuildkit: true
deploy:
  kubectl:
    manifests:
      - manifests/hello.yaml

```

[](about:blank#k8s-manifests)[#](about:blank#k8s-manifests)k8s manifests
------------------------------------------------------------------------

skaffoldのdeployでkubectlがapplyするmanifestを配置します。

*   manifests/hello.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  selector:
    app: hello
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello
  name: hello
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
        - image: hello
          imagePullPolicy: "IfNotPresent"
          name: hello
          command:
            - "./server"
          ports:
            - containerPort: 8080
              protocol: TCP

```

[](about:blank#hello-world-service)[#](about:blank#hello-world-service)Hello, World Service
-------------------------------------------------------------------------------------------

`8080`で`Hello, World`を出力するHTTP ServerをGoで作ります。

```
package main
import (
	"fmt"
	"net/http"
)
func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World")
}
func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}


```

Kubernetes上で動作するContainerImageを作ります。

```
FROM golang:1.15 as builder
WORKDIR /go/src/github.com/owner/repo
ENV GO111MODULE="on"
ENV CGO_ENABLED=0 
COPY . . 
RUN go build -o server main.go
FROM alpine
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/owner/repo/server  /go/bin/server
WORKDIR /go/bin/

```

[](about:blank#install-skaffold)[#](about:blank#install-skaffold)install skaffold
---------------------------------------------------------------------------------

```
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/

```

[](about:blank#%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E9%96%8B%E7%99%BA)[#](about:blank#%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E9%96%8B%E7%99%BA)ローカル開発
---------------------------------------------------------------------------------------------------------------------------------------------------

これでプログラムの準備ができました。  
`make dev` を実行します。  
`DEFAULT_REPO`はcluster作成時に一緒に作成したregistryのホスト名に置き換わります。

```
$ make dev
skaffold dev --port-forward --default-repo "registry.local:5000"
Listing files to watch...
 - hello
Generating tags...
 - hello -> registry.local:5000/hello:latest
Checking cache...
 - hello: Found Locally
Tags used in deployment:
 - hello -> registry.local:5000/hello:df5353aa06239ed065f981abe3c1198ea7f2473694e6163f0256b44018c877eb
Loading images into k3d cluster nodes...
 - registry.local:5000/hello:df5353aa06239ed065f981abe3c1198ea7f2473694e6163f0256b44018c877eb -> Found
Images loaded in 113.175619ms
Starting deploy...
 - service/hello created
 - deployment.apps/hello created
Waiting for deployments to stabilize...
 - deployment/hello is ready.
Deployments stabilized in 3.433 seconds
Press Ctrl+C to exit
Watching for changes...
Port forwarding service/hello in namespace default, remote port 8080 -> address 127.0.0.1 port 8080

```

node.jsでvue.jsやreactで開発された経験のある方は`npm run dev`などのコマンドでHotReloadを利用されているかと思います。skaffoldでもファイルの変更を検知して自動的にDocker build, kubectlでデプロイすることまでできます。port-forwardをしているので、portのバッティングなどがなければ、`127.0.0.1:8080`にアクセスするとHello, World Serviceにアクセスできると思います。  
きちんと動作しているかcurlコマンドを叩いてみましょう。

```
$ curl localhost:8080
Hello, World

```

`main.go`の`Hello, World`の部分を`Hello, k8s`の文字列に変えると再ビルド、デプロイが行われることを確認できます。また、curlコマンドを叩いてみましょう。

```
$ curl localhost:8080
Hello, k8s

```

[](about:blank#%E3%81%BE%E3%81%A8%E3%82%81)[#](about:blank#%E3%81%BE%E3%81%A8%E3%82%81)まとめ
------------------------------------------------------------------------------------------

必要最低限ですが、k3dとskaffoldを使ったローカル開発環境を構築しました。skaffoldをproduction,staging,develop環境でも使おうとするとprofileを分けたり、kustomizeやhelmを使って環境差異を埋めるようなことが必要になると思います。そのため、実用には遠いと思いますが、これからKubernetesでローカル開発環境を整えていこうという方にとって開発イメージがつかめて、一助になれば幸いです。

* * *

