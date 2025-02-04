---
layout: post
title:  Kubernetes on Raspberry Pi - Developing Applications
date:   2024-07-12
categories: [Kubernetes]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Applications

<!--more-->

------

* TOC
{:toc}
------

# Introduction

To test the cluster

```bash
kubectl run testpod --image=nginx
```

1. Create using run
2. Verify that the pod has been created

![Create nginx application interactively](/assets/images/2024-07-12-PI5-Kubernetes_app_development/Create nginx application interactively.png)

To delete this pod

```bash
kubectl delete pod testpod
```

**Deployment** of nginx 4 containers cluster

1. Run the command

    ```bas
     kubectl create deployment my-nginx --image=nginx --replicas=4
    ```

    This will create the nginx in 4 containers

2. To verify

```bash
kubectl get all
```



![CleanShot 2024-07-13 at 11.48.19@2x](/assets/images/2024-07-12-PI5-Kubernetes_app_development/CleanShot 2024-07-13 at 11.48.19@2x.png)

You can find the replica set in the last line in the above screenshot.

Describe the deployment

```bash
kubectl describe deployment my-nginx
```

![Describe the deployment](/assets/images/2024-07-12-PI5-Kubernetes_app_development/Describe the deployment.png)

Find where the nginx is running.

```bash
kubectl get pods -o wide
```

output:

![Find the running nodes](./assets/images/2024-07-12-PI5-Kubernetes_app_development/Find the running nodes.png)

> NOTE: As shown above, `rp1` is excluded because that is control pain.

To delete

1. get the deployments and decide on the deployment by the name
2. delete the deployment
3. verify

![Delete the deployment](./assets/images/2024-07-12-PI5-Kubernetes_app_development/Delete the deployment.png)

> NOTE: You must specify the namespace if it differs from the `default`.



# DaemonSets

DaemonSet starts one application instance on each cluster node. It is usually used to run agents such as kube-proxy, which needs to be run on all the nodes.

To find the running DaemonSets:

```bash
kubectl get ds -A
```



![available DaemondSets](/assets/images/2024-07-12-PI5-Kubernetes_app_development/available DaemondSets.png)

Get the configuration

```bash
kubectl get ds -n kube-flannel kube-flannel-ds -o json | jq .
```

You can create delarative sample daemonSet from the following command for the nginx to run on all the nodes:

```bash
kubectl create deploy nginx-daemon --image=nginx --dry-run=client -o yaml > nginx-daemon.yaml
```

Nginx-daemon.yam file changes the `kind:Deployment` to `kind: DaemonSet`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  creationTimestamp: null
  labels:
    app: nginx-daemon
  name: nginx-daemon
spec:
  selector:
    matchLabels:
      app: nginx-daemon
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-daemon
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

As well as delete the `replicas: 1` and the `strategy: {}`.

1. Now apply:

    ```bash
    kubectl apply -f nginx-daemon.yaml
    ```

    

2. List all the available daemonSets

3. List the pods

![Create DaemonSet for nginx](./assets/images/2024-07-12-PI5-Kubernetes_app_development/Create DaemonSet for nginx.png)

> NOTE: The node where control exists is excluded.

