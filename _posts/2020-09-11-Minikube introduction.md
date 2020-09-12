---
layout: post
title: "Minikube Introduction"
date: 2020-09-11
categories: [blog]
excerpt_separator: <!--more-->
---
[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is a high available cluster for education and prototyping purpose only but not for the production use because of security, performance and stability issues. Lean the basics here.

[toc]



<!--more-->
If you want to run Minikube locally, follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-minikube/).
## Install Minikube

Check the version of Minikube available with you

```shell
minikube version
```

check the latest

```shell
minikube update-check
```

To display current configuration settings

```shell
minikube update-check
```

You can metrics-server and dashboard is available.

to start the cluster

```shell
minikube start
```

Verify Minikube is running

```shell
minikube status
```

It should verify:

![Verify Minikube is running](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20200912110034208.png)

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

![image-20200912111013726](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20200912111013726.png)



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

![image-20200912114706279](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20200912114706279.png)

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

![image-20200912120431348](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20200912120431348.png)

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
kubectl get svc my-deployment -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}'
```

You can view your deployment in the dashboard as well.