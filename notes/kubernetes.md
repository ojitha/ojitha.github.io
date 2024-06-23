---
layout: notes 
title: Kubernetes
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

**Kubernetes notes**

* TOC
{:toc}
# Kubernetes

I am currently using Ubuntu 24.04 LTS on Raspberry Pi 5 for Kubernetes. As a first step[^2], extend the `/boot/firmware/cmdline.txt` with the following as a single line:

```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1
```

> NOTE: This way, I've avoided the cgroup configuration[^3] via Kubernetes.

## Install

### cri-dockerd

I found the default container communication in Ubuntu 24.04 is not the cir-docker and didn't find the proper binaries to install. I used the [`cri-dockerd`](https://mirantis.github.io/cri-dockerd/) adapter to integrate Docker Engine with Kubernetes. Therefore, it is installed[^4] from the source. Install the necessary tools on all the machines:

```bash
# install make
sudo apt install make
# install go
sudo snap install go --classic
```

Clone the repository to all the machines

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

activate the cri-docker for communication.

```bash
sudo install packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker.socket
```

### Docker

To install

```bas
curl -sSL get.docker.com | sh
```

In addition to that, I added the user to the docker group: `sudo usermod -aG docker oj`

After installing the docker, enable the routing as follows:

Find the following line in the file `/etc/sysctl.conf` and uncomment

```
net.ipv4.ip_forward=1
```

You can verify the docker installation by running `docker run hello-world`.

> NOTE: You have to install docker for all the cluster nodes.

### Kubeadm

Now you are ready to install the Kubeadm[^1] and, in this case, use the "Debian-based distributions".

After installing Kubectl, add to the bash-completion

```bash
sudo apt-mark hold kubelet kubeadm kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```

## Cluster

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



### Getting started

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

## General commands

### Common

To describe the object

```
kubectl describe <resource-name> <obj-name>
```

For example,

![Descrie Object](/assets/images/kubernetes/describe_object.png)

1. Describe the `hello` service (which is to be deleted in the next) that is broken.
2. Describe the nginx, which is currently running without a problem (http://192.168.1.121:30080) 

> NOTE: From the NodePort value, you can find why `hello` service is not working



To delete the already deployed service

![Delete deployed service](/assets/images/kubernetes/del_deployed_ser.png)

1. List the services
2. Delete the first of the list that is `hello`
3. verify the service `hello` was deleted.

These records can be manipulated with the `edit-last-applied`, `set-last-applied`, and `view-last-applied`:

![manipulated](/assets/images/kubernetes/manipulated.png)

To label 

![labeling](/assets/images/kubernetes/labelling.png)

1. Label the pod `nginx-example`
2. Show the pods, but no label shows
3. Show the pods in wider, but no label shows
4. use the `--show-labels`
5. remove the label
6. confirm the label has been removed.

To see the logs `kubectl logs <pod-name>`

![see the logs](/assets/images/kubernetes/see_the_logs.png)

> NOTE: If you have multiple containers in your Pod, use the `-c` flag.

Login to the pod `kubectl exec -it <pod-name> -- bash` with intractive shell

![loging to the pod](/assets/images/kubernetes/login_to_the_pod.png)

> Note: The `attach` command is similar to `Kubectl logs` but will allow you to send input to the running process.

copy files (reverse also possible)

```
kubectl cp </path/to/local/file> <pod-name>:</path/to/remote/file> 
```

![copy local file to pod](/assets/images/kubernetes/copy_local_pod_file.png)

1. create test.txt in the local machine
2. list the local machine test.txt file
3. copy local machine test.txt to the root of the nginx
4. interactively login to the nginx-example pod via bash
5. List the files

Port forwarding to access via local machine

```
kubectl port-forward <pod-name> <local machine port>:<remote container>
```

Traffic from local machine to remote container.

![port forwarding](./assets/images/kubernetes/port_forwarding.png)

### Cluster Management

References:

[^1]: [Installing Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
[^2]: [Setting up a Raspberry Pi Kubernetes Cluster with Ubuntu 20.04](https://www.learnlinux.tv/setting-up-a-raspberry-pi-kubernetes-cluster-with-ubuntu-20-04/)
[^3]:[Configuring a cgroup driver](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/)
[^4]:[Kubernetes installation blog](https://www.jjworld.fr/kubernetes-installation/#3_Installation_de_cri-dockerd)
