---
layout: post
title: "Minikube Introduction"
date: 2020-09-11
category: Kubernetes
toc: true
---
[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is a highly available cluster for educational and prototyping purposes only, not for production use, due to security, performance, and stability issues.

<img src="https://github.com/kubernetes/minikube/raw/master/images/logo/logo.png" alt="Minikube" width="20%;" />

Learn the basics here.

<!--more-->

* TOC
{:toc}

If you want to run Minikube locally, follow the instructions for [Mac](https://ojitha.blogspot.com/2018/07/hands-dirty-with-kubernetes.html) or [here](https://kubernetes.io/docs/tasks/tools/install-minikube/).

## Install Minikube

Check the version of Minikube available to you

```shell
minikube version
```

Check the latest

```shell
minikube update-check
```

To display current configuration settings

```shell
minikube update-check
```

You can use metrics-server, and the dashboard is available.

to start the cluster

```shell
minikube start
```

Verify Minikube is running

```shell
minikube status
```



To get the IP of the Minikube

```shell
minikube ip
```

Get logs

```shell
minikube logs
```

To stop the cluster

```shell
minikube stop
```

To delete the cluster

```shell
minikube delete
```

To ssh

```shell
minikube ssh
```

## Cluster

`Kubectl` is the tool to adminstating the Minikube cluster

find the version of current `Kubectl` tool:

```shell
kubectl version
```

To find the nodes in the cluster

```shell
kubectl get nodes
```

To get indepth information about node (because this is single cluster)

```shell
kubectl describe node minikube
```

or for other related services such as health check of the cluster

```shell
kubectl get componentstatus
```



for the cluster information

```shell
kubectl cluster-info
```

For the configuration

```shell
kubectl config view
```

to get the context

```shell
kubectl config get-contexts
```

You can get the cluster name and the namespace.

List all the events:

```shell
kubectl get events
```

## Addons

To list all the add-ons and check which are enabled and disabled

```shell
minikube addons list
```

To enable the add-on, for example `metrics-server`:

```shell
minikube addons enable metrics-server
```

Now you can run the `top` command

```shell
kubectl top node
```

To inspect pods of all the namespaces

```shell
kubectl top pods --all-namespaces
```

## Services

Some services exposed via ports to access externally,

```shell
minikube service list
```



The URLs for these services can be listed:

```shell
minikube service --namespace kube-system kubernetes-dashboard-katacoda --url
```

The port information can be listed as

```shell
kubectl get service kubernetes-dashboard-katacoda -n kube-system
```

You can enable dashboard as follows

```shell
minikube addons enable dashboard
# to run
minikube dashboard
```

## Configure Minikube

Creating namespace

```bash
kubectl create namespace myspace
```

To get all the namespaces

```shell
ubectl get namespaces
```

Label the namespace

```shell
kubectl label namespace myspace customer=ojitha
```

verify the label

```shell
kubectl describe namespace myspace
```

Use the label to view only the namespace associated with that:

Labels you can find in the dashboard as well.

## Deployment

You can deploy images

```bash
kubectl create deployment my-deployment --image=<image>
```

to verify the my deployment

```shell
kubectl get pods
```

If you deployed web server, you can expose the prot to access via external browser:

```shell
kubectl expose deployment my-deployment --port=80 --type=NodePort
```

to get the port

```bash
{% raw %}
kubectl get svc my-deployment -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}'
{% endraw %}
```
You can view your deployment in the dashboard as well.

This is example yml to deploy your web application

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ojwebapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ojwebapp
  template:
    metadata:
      labels:
        app: ojwebapp
    spec:
      containers:
      - name: ojwebapp
        image:<image>:latest
        ports:
        - containerPort: 80
```

to deploy above deployment.yaml

```bash
kubectl create -f deployment.yaml
```

now you can verify `kubectl get deployment`

Get the deployment information:

```bash
kubectl describe deployment ojwebapp
```

You can control network configuration via yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ojwebapp-svc
  labels:
    app: ojwebapp
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30000
  selector:
    app: ojwebapp
```

To create ojwebapp-svc, deploy the service.yaml as follows:

```bash
kubectl create -f service.yaml
```

To get the all services:

```bash
kubectl get svc
```



To get only about `ojwebapp-svc`:

```bash
kubectl describe svc ojwebapp-svc
```

Now you can run curl command `curl <host>:30000` to get the page.

You can change the number of `replicas` into 4 and apply the changes. If you run the `kubectl get deployment`.

To get the details about small cluster:

```bash
{ clear && \
  echo -e "\n=== Kubernetes Status ===\n" && \
  kubectl get --raw '/healthz?verbose' && \
  kubectl version --short && \
  kubectl get nodes && \
  kubectl cluster-info; 
} | grep -z 'Ready\| ok\|passed\|running'
```

To view the configuration:
```bash
kubectl config view
kubectl config get-contexts
```

More details can be revealed about any object. Let's inspect details about the single node. Get the name of the single minikube node:

```bash
node_name=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
kubectl describe node $node_name
```

Kubernetes currently has about 56 standard resources

```bash
kubectl api-resources
```

Events is just one type of resources that can be listed:

```bash
kubectl get events
```

minikube has a helpful command to list and inspect the Kubernetes services. List the minikube services:

```bash
minikube service list
kubectl get services --all-namespaces
```

 create two namespaces



