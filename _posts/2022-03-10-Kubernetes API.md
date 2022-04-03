---
layout: post
title:  Kubernetes API
date:   2022-03-10
categories: [Kubernetes]

---

Let's see how to play K8s in MacOs using MniKube. Some of the topics are very basic such as How to create a namespace and pod in it. Shelling to the pod and after delete pod and the namespace. However, this is written to address the concepts such as configMap, secrets, resource sharing and Helm charts.

<!--more-->

------

* TOC
{:toc}


------



## Minikube

Find the latest support Minikube supported Kubernetes version from [here](https://github.com/kubernetes/minikube/blob/master/pkg/minikube/constants/constants.go), and you can start the Minikube as follows

```bash
minikube start --cpus=2 --memory=4000 --kubernetes-version=v1.23.3
```

you can find component status:

```bash
kubectl get componentstatus
```

![image-20220312135947819](/assets/images/image-20220312135947819.png)

Display the nodes

```bash
kubectl get nodes
```

![image-20220312140048264](/assets/images/image-20220312140048264.png)

Find the cluster information:

```bash
kubectl cluster-info
```

The above command will create a `default` namespace.

```bash
kubectl get namespaces
```

![image-20220312125415866](/assets/images/image-20220312125415866.png)

Login to the docker instance of Minikube

```bash
minikube ssh
```



![image-20220312125812675](/assets/images/image-20220312125812675.png)

You can get the IP address of the docker instance using `minikube ip`.



## Create namespace and pod

To create a new namespace:

```bash
kubectl create namespace <namespace>
```

To list the namespaces available.

```bash
kubectl get namespaces
```

Create POD

```bash
kubectl run <pod-name> --image=nginx:2.3.5 --restart=Never --port=80 --namespace=<namespace>
```

Or simply `kubectl run ghost --image=ghost:0.9 -n testns`.

List all the pods in the namespace.

```bash
kubectl get pod -n <namespace>
```

for example `kubectl get pods -n testns`:

![image-20220312130914128](/assets/images/image-20220312130914128.png)

To update the pod image.

```bash
kubectl set image pod <pod-name> mypod=nginx --namespace=<namespace>
```

The above command will use the latest version of the `nginx`.

Check the latest status of the pod:

```bash
kubectl get pod -n <namespace>
```

## Interacting with pod

Shelling to the pod

```bash
kubectl exec <pod-name> -it --namespace=<namespace>  -- /bin/sh
```

Accessing pod logs:

```bash
kubectl logs <pod-name> -n <namespace>
```

You can create the pod from a yaml file.

Before going further delete the existing pod in  the `testns` namespace:

```bash
kubectl delete pod ghost -n testns
```

Create `pod.yaml` using the following command:

```bash
kubectl run ghost --image=ghost:0.9 -n testns -o yaml --dry-run=client > pod.yaml
```

The above command will create the pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ghost
  name: ghost
  namespace: testns
spec:
  containers:
  - image: ghost:0.9
    name: ghost
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Now deploy from the above pod.yaml

```bash
kubectl apply -f pod.yaml
```

If you list using `kubectl get pods -n testns`, you will find the ghost pod.

## Delete resources

Delete the pod

```bash
kubectl delete pod <pod-name> --namespace=<namespace>
```

delete the namespace

```bash
kubectl delete namespace <namespace>
```

For example, `kubectl delete ns testns`.

Verify resources are delete

```bash
kubectl get pod, namespace
```

To delete Minikube

```bash
minikube stop
minikube delete --all
```

![image-20220312133432707](/assets/images/image-20220312133432707.png)

## ConfigMaps

[ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) decouple the configuration values needed at runtime from the definition of a Pod.

1. Create a `config.txt` file with the key-value pairs for each line to have one key-value pair.

2. create configmap, for example, `db-config` map:

    ```bash
    kubectl create configmap db-config --from-env-file=config.txt
    ```

3. verify the config files are created

    ```bash
    kubectl get configmaps
    ```

    Or YAML

    ```bash
    kubectl get configmap db-config -o yaml
    ```

4. Now generate the YAML file for your pod with dry run

    ```bash
    kubectl run backend --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
    ```

    

5. Add the configMap to that

    ```yaml
    spec:
      containers:
      - image: nginx
        name: backend
        envFrom:
          - configMapRef:
              name: db-config
    ```

    

6. now create the pod

    ```bash
    kubectl create -f pod.yaml
    ```

    

7. Shell into the pod and verify

    ```bash
    kubectl exec backend -it -- /bin/sh
    ```

    Check within the pod bash

    ```bash
    env | grep <key pattern>
    ```

## Secrets

The way to maintain secret information, data should be base64 encoded. Secrets are only in memory and not written to the disk.

1. generate the `db-credentials`

```bash
kubectl create secret generic db-credentials --from-literal=db-password=<password>
```

2. verify

```bash
kubectl get secrets
```

3. check the YAML representation

```bash
kubectl get secret db-credentials -o yaml
```

4. Dry run to pod.xml

    ```bash
    kubectl run backend --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
    ```

    

5. update the pod.xml with `db-credentials`:

    ```yaml
    spec:
      containers:
      - image: nginx
        name: backend
        env:
          - name: DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: db-credentials
                key: db-password
    ```

    

6. Now, you can create a pod from the pod.xml file

    ```bash
    kubectl create -f pod.yaml
    ```

7. Verify by shelling to the pod

    ```bash
    kubectl exec backend -it -- /bin/sh
    ```

    and

     ```bash
    env | grep DB_PASSWORD
     ```

## Security Context

Define access control to a pod or container. Default there is no pod or container security context available. 

1. create a pod with a volume

    ```bash
    kubectl run secured --image=nginx --restart=Never -o yaml --dry-run > sec.yaml
    ```

    

2. Edit the sec.yaml to have 

    ```yaml
    spec:
      securityContext:
        fsGroup: 3000
      containers:
      - image: nginx
        name: secured
        volumeMounts:
        - name: data-vol
          mountPath: /data/app
        resources: {}
      volumes:
      - name: data-vol
        emptyDir: {}
    ```

    

3. create a pod from the above sec.yaml

    ```bash
    kubectl create -f sec.yaml
    ```

    

4. verify by login to the pod bash

    ```bash
    kubectl exec -it secured -- /bin/sh
    ```

    change the directory and create a file, then list the files and see the security group

    ```bash
    cd /data/app
    touch test.txt
    ls -l
    ```

## Resource Sharing

Resource quotation is bound to the namespace.

1. First, create a namespace

2. Create a YAML file with the resource definition

    ```yaml
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: app
    spec:
      hard:
        pods: "2"
        requests.cpu: "2"
        requests.memory: 500m
    ```

    

3. create a quota for the namespace

    ```bash
    kubectl create -f <resource-quota>.yaml --namespace=<namespace>
    ```

    

4. Describe the quota for the namespace

    ```bash
    kubectl describe quota --namespace=<namespace>
    ```

    

5. Create pod.xml in the above namespace with dry run

    ```bash
    kubectl run <pod-name> --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
    ```

    

6. under the resource section in the pod.xml

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: testpod
      name: testpod
    spec:
      containers:
      - image: nginx
        name: testpod
        resources:
          requests:
            memory: "200m"
            cpu: "400m"
      dnsPolicy: ClusterFirst
      restartPolicy: Never
    status: {}
    ```

    If you change the `memory: "1G"`, you will get an error something similar to:

    ```
    error from server (Forbidden): error when creating "pod.yaml": pods "testpod" is forbidden: exceeded quota: app, requested: requests.memory=1G,...
    ```

    And pod creation will be failed.

7. create a pod in the namespace

    ```bash
    kubectl create -f pod.yaml --namespace=<namespace>
    ```

## Service Account

Pod use a service account to communicate with the cluster API. There is a default service account always.

1. create a service account

    ```ba
    kubectl create sa <sa-name>
    ```

    This will create a secret for the service account automatically.

2. inspect the service account

    ```bash
    kubectl get serviceaccount <sa-name> -o yaml
    ```

    

3. You can find the secret created

    ```bash
    kubectl get secrets
    ```

    You will get something similar to `<sa-name>-token-rg4b8`

4. Assigning to the pod

    ```bash
    kubectl run <pod-name> --image=nginx --restart=Never --serviceaccount=<sa-name>
    ```

    

5. To verify, get into the pod

    ```bash
    kubectl exec -it backend -- /bin/sh
    ```

    The same token is available at 

    ```bash
    cat /var/run/secrets/kubernetes.io/serviceaccount/token
    ```

## Helm

This is the cluster administration tool for Kubernetes. Charts are source codes for infrastructure as code with the great help of dependency management, which can be packaged, named and under the version management. Charts define a composition of related Kubernetes resources and values that make up a deployment solution.

Install Helm on Mac:

```bash
brew install helm
```

you can verify the installation by running the following command:

```bash
helm env
```

You can find Helm [artifact hub](https://artifacthub.io) for chart repostiories.

search for `postgresql` in the hub:

```bash
helm search hub postgresql
```

For example, narrow the charts and install

```bash
helm search hub redis | grep --color bitnami
```

the result will be 

```
https://artifacthub.io/packages/helm/bitnami/redis	16.5.2       	6.2.6           	Redis(TM) is an open source, advanced key-value...
https://artifacthub.io/packages/helm/bitnami-ak...	16.5.2       	6.2.6           	Redis(TM) is an open source, advanced key-value...
https://artifacthub.io/packages/helm/bitnami-ak...	7.3.2        	6.2.6           	Redis(TM) is an open source, scalable, distribu...
https://artifacthub.io/packages/helm/bitnami/re...	7.3.2        	6.2.6           	Redis(TM) is an open source, scalable, distribu...

```

you can add Binami as respository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

List the repos to verify

```bash
helm repo list
```

![image-20220312142817918](/assets/images/image-20220312142817918.png)

The advantage is that you can directly search the repository.

```bash
helm search repo bitnami/redis
```

You will get the following.

![image-20220312143032026](/assets/images/image-20220312143032026.png)

For additional information:

```bash
helm show chart bitnami/redis
```

read readme:

```bash
helm show readme bitnami/redis
```

context values:

```bash
helm show values bitnami/redis
```

Create a namespace 

```bash
kubectl create namespace redis
```

before installing, create a Redis values YAML file:

```bash
replica:
   replicaCount: 2

volumePermissions:
  enabled: true

securityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001
```

Install the chart

```bash
helm install test-redis bitnami/redis --version 16.5.2 --namespace redis --values redis-values.yaml
```

list the installation:

```bash
helm ls -n redis
```

![image-20220312145853123](/assets/images/image-20220312145853123.png)

To find the secrets are deployed to the namespace where the chart is deployed. 

```bash
kubectl get secrets --all-namespaces | grep sh.helm
```

![image-20220312150253461](/assets/images/image-20220312150253461.png)

to read the secret:

```bash
kubectl --namespace redis describe secret sh.helm.release.v1.test-redis.v1
```

![image-20220312150848240](/assets/images/image-20220312150848240.png)

You can use `watch` command (install on macOS using `brew install watch`) to find out what was deployed:

```bash
watch kubectl get statefulsets,pods,services -n redis
```

![image-20220312151432797](/assets/images/image-20220312151432797.png)

Create persistent volume as specified in the pv.yaml:

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume1
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "./data1"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume2
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "./data2"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume3
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "./data3"
```

Run the following command to create the above-specified volumes:

```bash
kubectl apply -f pv.yaml
```

![image-20220312152031302](/assets/images/image-20220312152031302.png)

ensure Redis has permission to write to these volumes

```bash
mkdir ./data1 ./data2 ./data3 --mode=777
```

To get your password run:

```bash
export REDIS_PASSWORD=$(kubectl get secret --namespace redis test-redis -o jsonpath="{.data.redis-password}" | base64 --decode)
```

```bash
kubectl port-forward --namespace redis svc/test-redis-master 6379:6379 > /dev/null &
```

Create a Redis client to access the above-created Redis server

```bash
kubectl run --namespace redis redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:6.2.6-debian-10-r146 --command -- sleep infinity
```

if you check, you can verify Redis client has been created

![image-20220312153947826](/assets/images/image-20220312153947826.png)

​    use the following command to connect to the Redis client:

```bash
kubectl exec --tty -i redis-client    --namespace redis -- bash
```

Inside the client, connect to the 

```bash
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h test-redis-master
```

And type the PING. The output should be `PONG`.

![image-20220312161646248](/assets/images/image-20220312161646248.png)

Uninstall Redis

```bash
helm delete test-redis -n redis
```

delete redis client

```bash
kubectl delete pod redis-client -n redis
```

delete redis namespace

```bash
kubectl delete namespace redis
```

## Chart

Helm use Go templating API. 

Create your chart. 

```bash
helm create my-chart
```

to list the skeleton:

```bash
tree my-chart
```

![image-20220312163209513](/assets/images/image-20220312163209513.png)

Resource definition is in the template directory:

```bash
cat my-chart/templates/deployment.yaml | grep -color 'kind:' -n -B1 -A5
```

![image-20220312163526600](/assets/images/image-20220312163526600.png)

Injected container image for deployment

```bash
cat my-chart/templates/deployment.yaml | grep --color 'image:' -n -C3
```

![image-20220312163827861](/assets/images/image-20220312163827861.png)

for the above container image is injected to the `{ { .Values.image.repository } }` from the `values.yaml` as shown in the below:

```bash
cat my-chart/values.yaml | grep --color 'repository' -n -C3
```

![image-20220312164242556](/assets/images/image-20220312164242556.png)

Let's try dry run:

```bash
helm install my-app ./my-chart --dry-run --debug | grep --color 'image: "' -n -C3
```

![image-20220312164740489](/assets/images/image-20220312164740489.png)

You can override the default.

```bash
helm install my-app ./my-chart --dry-run --debug --set image.pullPolicy=Always | grep --color 'image: "' -n -C3
```

![image-20220312165433749](/assets/images/image-20220312165433749.png)

after the dry run investigate, as shown in the above screenshot, install the version change

```bash
helm install my-app ./my-chart --set image.pullPolicy=Always
```

![image-20220312165751507](/assets/images/image-20220312165751507.png)

```bash
helm list
```

![image-20220312165904039](/assets/images/image-20220312165904039.png)

```bash
kubectl get deployments,service
```

![image-20220312170113089](/assets/images/image-20220312170113089.png)

