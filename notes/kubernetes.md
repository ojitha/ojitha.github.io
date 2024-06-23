---
layout: notes 
title: Kubernetes
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

**Kubernetes notes**

* TOC
{:toc}
## Kubernetes

### Install cri-dockerd

Install necessary tools

```bash
# install make
sudo apt install make
# install go
sudo snap install go --classic
```

Clone

```bash
git clone https://github.com/Mirantis/cri-dockerd.git
```

Then, build and install



```bash
# Build
cd cri-dockerd
make cri-dockerd

# Installation
sudo mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
```

activate

```bash
sudo install packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker.socket
```

After installing kubectl add to the bash-completion

```bash
sudo apt-mark hold kubelet kubeadm kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```

To create the cluster

```bash
 sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock
```

As an output

```
kubeadm join 192.168.1.121:6443 --token f9zlr3.jrbkjy4gagp16ym7 \
	--discovery-token-ca-cert-hash sha256:43ae7ab6a144b1c5605ea6ae9715e0f491668df1e36091fda8067acdaeea40c4 
```

As the above output stated

```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Create network driver

```bash
sysctl net.bridge.bridge-nf-call-iptables=1
```

use the fannel as the driver

```bash
# no sudo need
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Verify all the namespaces are running

```bash
kubectl get pods --all-namespaces
```

To find all the running nodes

```bash
kubectl get nodes
```



![CleanShot 2024-06-22 at 14.06.46@2x](/assets/images/UnixTools/CleanShot 2024-06-22 at 14.06.46@2x.png)

Now, you have to install and activate the CRI in the worker nodes. After that join the worker to cluster

```
kubeadm join 192.168.1.121:6443 --token f9zlr3.jrbkjy4gagp16ym7 \
	--discovery-token-ca-cert-hash sha256:43ae7ab6a144b1c5605ea6ae9715e0f491668df1e36091fda8067acdaeea40c4 --cri-socket unix:///var/run/cri-dockerd.sock
```

> The postfix `--cri-socket unix:///var/run/cri-dockerd.sock` has been added because you have to install and activate the crib on the worker nodes as well. 

The output will be something similar to:

![Nodes Status](/assets/images/UnixTools/nodes_status.png)

Command to verify the cluster

```bash
{ clear && \
  echo -e "\n=== Kubernetes Status ===\n" && \
  kubectl get --raw '/healthz?verbose' && \
  kubectl version --short && \
  kubectl get nodes && \
  kubectl cluster-info; 
} | grep -z 'Ready\| ok\|passed\|running'
```



### General commands

The simple diagnostic for the cluster

```bas
kubectl get componentstatuses
```

Output:

![Simple diagnostic](/assets/images/UnixTools/simple_diagnostic.png)

To get more information about nodes:

```bash
kubectl describe nodes rpi2
```

The Kubernetes proxy is responsible for routing network traffic to load-balanced services in the cluster. The proxy must be present on every node in the cluster. You can find the kube proxy under the `kube-system` namespace:

```bash
kubectl get daemonSets --namespace=kube-system
```

ouptput

![Kube Proxy](/assets/images/UnixTools/kube_proxy.png)

To get the services

```bash
kubectl get services --namespace=kube-system kube-dns
```

Output where you can find the cluster IP:

![services](/assets/images/UnixTools/services.png)

Get the deployments to the cluster

```bash
kubectl get deployments --namespace=kube-system
```

![deployments](/assets/images/UnixTools/deployments.png)

To create a new namespace: stuff.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mystuff
```

and run the command (1)

```bash
kubectl apply -f stuff.yaml
```

To create a pod on `mystuff` namespace (3):

```bash
kubectl run nginx --image=nginx:1.23.0 --restart=Never -n mystuff
```

![create pod in a namespace](/assets/images/UnixTools/create_a_pod_in_a_namespace.png)

To change the default namespace:

```bash
kubectl config set-context my-context --namespace=mystuff
# use the context
kubectl config use-context my-context 
```



### Deploy

Declarative deployment (echoserver.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: hello
  name: hello
spec:
  replicas: 1
  selector:
    matchLabels:
      run: hello
  template:
    metadata:
      labels:
        run: hello
    spec:
      containers:
      - image: registry.k8s.io/echoserver:1.9
        name: hello
        ports:
        - containerPort: 8080
```

To deploy to cluster

```bash
kubectl apply -f echoserver.yaml
```

![echo server deployment](/assets/images/UnixTools/echo_server_deployment.png)

You have to expose the service before use (1)

```bash
kubectl expose deployment hello --type=NodePort
```

![expose the service](/assets/images/UnixTools/expose_the_service.png)

You can see the exactly mapped port (2).

if you want to change the port:

```bash
kubectl patch service hello --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31001}]'
```

For more information: `kubectl describe service hello`

To scale the deployment:

```bash
kubectl scale deployment hello --replicas=1
```

To list that scaling

```bash
kubectl get pods -l run=hello
```

To get the list of running pods

```bash
kubectl get pods --selector=run=hello
```

To delete the pod

```bash
kubectl delete --now pod hello-6d65ff4755-qvzg6
```

To watch 

```bash
watch kubectl get pods --selector=run=hello
```
