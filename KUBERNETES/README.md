# TP 1 : déploiement Signle-node avec minikube
* Déployer minikube a l'aide d'un conteneur Docker
* EC2 : t2.large
* 20 Go
* sg-ajc-minkube : 22 / 80 / 8080 / [ 30000 - 32500 ]
* 52.91.141.146 
* Script de démarrage : Install Minikube
```bash
#!/bin/bash
sudo hostnamectl set-hostname minikube-master
echo "127.0.0.1 minikube-master" >> /etc/hosts
sudo apt-get -y update
sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
sudo apt-get install -y socat
sudo apt-get install -y conntrack
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
systemctl start docker
sudo apt-get -y install wget
sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/bin/minikube
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo systemctl enable docker.service
```

* Sur notre machine ubuntu
```bash
# démarrer minikube et création de notre cluster
minikube start --driver=none
kubectl get node

# minkube a créer une multitude de conteneur:
docker ps
kubectl version
kubectl -v

# afficher les noeuds
kubectl get nodes
    NAME               STATUS   ROLES                  AGE     VERSION
    ip-172-31-24-154   Ready    control-plane,master   8m26s   v1.22.3

# décrire nos noeud
kubectl describe nodes ip-172-31-24-154

# afficher les pod
kubectl get pod

# activation de l'auto-completion
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
# se déconncter et se reconnecter

# information sur les clusters
kubectl  cluster-info
```
# TP 2 : déploiement votre première application
```bash
# création d'un pod
kubectl run nginx-omar --image nginx --port 80
kubectl get po
kubectl get po nginx-omar -o yaml
kubectl describe pod nginx-omar
kubectl logs nginx-omar

# liste de nos pod avec plus d'options
kubectl get po -o wide
```

# TP3 : Consommer notre application via le port forward
```bash
# Replica Set : on fédère les pod autour d'une ressource
kubectl get replicasets.apps
kubectl get rs

# Deployment (gérer le cycle de vie de notre application): fédérer les replicatset
kubectl get deployments.apps

# pour des besoins de test (non durable): bloque le terminal
kubectl port-forward nginx-omar 8080:80 --address 0.0.0.0
# CTRL + C : arrêter

# Supprimer notre pod
kubectl delete pod nginx-omar

# création avec 3 replicats
kubectl create deploy nginx-deployment --image nginx --port 80 --replicas=3
kubectl get deploy
    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    nginx-deployment   3/3     3

kubectl get rs
    NAME                          DESIRED   CURRENT   READY   AGE
    nginx-deployment-7c9cfd4dc7   3         3         3       51s

kubectl create deploy webapp --image nginx --port 80 --replicas=3
    kubectl get rs
    NAME                          DESIRED   CURRENT   READY   AGE
    nginx-deployment-7c9cfd4dc7   3         3         3       2m1s
    webapp-7dfc86cd9d

kubectl get po
    NAME                                READY   STATUS    RESTARTS   AGE
    nginx-deployment-7c9cfd4dc7-4n7mw   1/1     Running   0          2m26s
    nginx-deployment-7c9cfd4dc7-m6lm2   1/1     Running   0          2m26s
    nginx-deployment-7c9cfd4dc7-wmhqt   1/1     Running   0          2m26s
    webapp-7dfc86cd9d-7jb2z             1/1     Running   0          51s
    webapp-7dfc86cd9d-cnvrf             1/1     Running   0          51s
    webapp-7dfc86cd9d-phd8v  

# si on supprimer un pod, le deploy va en créer un nouveau !!!
kubectl delete po webapp-7dfc86cd9d-phd8v
    pod "webapp-7dfc86cd9d-phd8v" deleted

kubectl get po
    NAME                                READY   STATUS    RESTARTS   AGE
    nginx-deployment-7c9cfd4dc7-4n7mw   1/1     Running   0          4m20s
    nginx-deployment-7c9cfd4dc7-m6lm2   1/1     Running   0          4m20s
    nginx-deployment-7c9cfd4dc7-wmhqt   1/1     Running   0          4m20s
    webapp-7dfc86cd9d-7jb2z             1/1     Running   0          2m45s
    webapp-7dfc86cd9d-cnvrf             1/1     Running   0          2m45s
    webapp-7dfc86cd9d-fcxmj

kubectl get po -o wide
kubectl port-forward deploy/nginx-deployment 8080:80 --address 0.0.0.0

# information sur notre deployment
kubectl describe deploy nginx-deployment

# intéragir avec un conteneur
kubectl exec -it nginx-deployment-7c9cfd4dc7-4n7mw -- ls

# entrer dans notre conteneur et modifier index.html
kubectl exec -it nginx-deployment-7c9cfd4dc7-4n7mw -- /bin/bash
> cd /usr/share/nginx/html
> echo 'omar' > index.html

# tests 
kubectl exec -it nginx-deployment-7c9cfd4dc7-4n7mw -- cat /usr/share/nginx/html/index.html
kubectl exec -it nginx-deployment-7c9cfd4dc7-m6lm2 -- cat /usr/share/nginx/html/index.html

# supprimer les deploy
delete deploy nginx-deployment
delete deploy webapp
kubectl get pod
```

# TP4 : Creation d'un Pod à l'aide d'un Manifest

```yml
# nginx-pod.yml
apiVersion: v1
kind: Pod
metadata : 
  name: nginx-pod
  labels:
    app: nginx
    env: prod
    formation: Frazer
spec:
  containers:
    - name: nginx
      image: nginx:1.21
      ports:
        - containerPort: 80
```
```bash
vi nginx-pod.yml
kubectl create -f nginx-pod.yml
kubectl get pod
# modifier le yml
kubectl apply -f nginx-pod.yml
kubectl get pod

# Afficher les information sur l'Image du conteneur
kubectl describe pod nginx-pod1 | grep 'Image:'
kubectl describe pod nginx-pod2 | grep 'Image:'
# mdofier l'image pour nginx-pod1
kubectl set image pod nginx-pod1 nginx=nginx
kubectl describe pod nginx-pod1 | grep 'Image:'
kubectl describe pod nginx-pod2 | grep 'Image:'

# supprimer
kubectl delete -f nginx-pod.yml
```

# TP5 : Variables d'environnement
## Exemple 1 (TP)

```yml
# webappcolor-pod.yml 
apiVersion: v1
kind: Pod
metadata : 
  name: webapp-color
  labels:
    app: webapp-color
    env: prod
    formation: Frazer
spec:
  containers:
    - name: webapp-color
      image: kodekloud/webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          value: blue
```
```bash
vi webappcolor-pod.yml
kubectl create -f webappcolor-pod.yml
kubectl get pod
kubectl port-forward webapp-color 8080:8080 --address 0.0.0.0
# http://52.91.141.146:8080/ : blue
# CTRL + C 

kubectl run webapp-color1 --image=kodekloud/webapp-color --env APP_COLOR=red
kubectl port-forward webapp-color 8080:8080 --address 0.0.0.0
# http://52.91.141.146:8080/ : rouge
# CTRL + C 

#Création de manifest à l'aide de commandes impératives
kubectl run webapp-color --image=kodekloud/webapp-color --env APP_COLOR=red --dry-run=client -o yaml > webapp-pod.yml
```

## Exemple 2
```
1) creer un pod webapp-color (image=kodekloud/webapp-color) avec couleur red
2) creer un manifest pour replicaset qui devra creer 3 replicas de l'image webapp avec couleur bleue

Chacun des pod crées devra avoir les label (env=prod et app=webapp)
le sélecetur à utilisé par le replicaset devar etre app=webapp.
```

```yml
# rs-webapp.yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rswebapp
  labels:
    role: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      name: web
      labels:
        app: webapp
        type: pod
        formateur: Frazer
    spec:
      containers:
        - name: web1
          image: kodekloud/webapp-color
          ports:
            - containerPort: 8080
          env:
            - name: APP_COLOR
              value: green
            - name: TEST
              value: Frazer 
```

```bash
# kubectl delete po webapp-color --force
kubectl run webapp1 --image=kodekloud/webapp-color -l  app=webapp,env=prod  --env APP_COLOR=blue
kubectl apply -f rs-webapp.yml

kubectl get po
    NAME             READY   STATUS    RESTARTS   AGE
    rswebapp-2dhdl   1/1     Running   0          23s
    rswebapp-sdbdc   1/1     Running   0          23s
    webapp1          1/1     Running   0          13m

# Si on rajoute un webapp2
kubectl run webapp2 --image=kodekloud/webapp-color -l  app=webapp,env=prod  --env APP_COLOR=blue

# on voit que k8s le supprimer aussitot
kubectl get po
    NAME             READY   STATUS        RESTARTS   AGE
    rswebapp-2dhdl   1/1     Running       0          2m16s
    rswebapp-sdbdc   1/1     Running       0          2m16s
    webapp1          1/1     Running       0          14m
    webapp2          1/1     Terminating   0          9s

# si on supprimer un pod un nouveau sera crée
kubectl delete pod rswebapp-2dhdl --force

# si on supprimer notre RS : il supprimer toutes les ressource meme webapp1
kubectl delete -f rs-webapp.yml
kubectl get pod
```

## Exemple 3 (lignes de commandes)

```bash
kubectl run nginx --image nginx --port 80 -l env=prod,app=nginx
kubectl run nginx-dev --image nginx --port 80 -l env=dev,app=nginx
kubectl run nginx-test --image nginx --port 80 -l env=test,app=nginx
kubectl run nginx-prod --image nginx --port 80 -l env=prod,app=nginx

kubectl get po --show-labels
    NAME         READY   STATUS    RESTARTS   AGE     LABELS
    nginx        1/1     Running   0          2m29s   app=nginx,env=prod
    nginx-dev    1/1     Running   0          115s    app=nginx,env=dev
    nginx-prod   1/1     Running   0          28s     app=nginx,env=prod
    nginx-test   1/1     Running   0          65s     app=nginx,env=test

kubectl get deploy --show-labels

# afficher tous les pod qui ont un label en=prod
kubectl get po -l env=prod

# récupérer toutes les ressources qui ont un label env
kubectl get pod --show-labels -l env

# suppression des ressources
# J'envoi l'ensemble de mes pod dans un manifest po-default
kubectl get po -o yaml > po-default.yml
# Je supprime les pod qui se trouvent dans le fichier
kubectl delete -f po-default.yml

# On peut reconstuire les ressource depuis le manifest
kubectl apply -f po-default.yml

# créer un deployment
kubectl create deploy dp-test --image nginx --replicas=2 --port 80

# vérifie ce deployment : 2 replicas
kubectl get deploy

# augment le nbr de replicats
kubectl scale deploy dp-test --replicas=4

# on obtient 4 replicas
kubectl get deploy

# on supprimer les deployment
kubectl delete deploy dp-test
```

# TP 6 : DEPLOYMENT
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostname-101-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        type: pod
        formateur: Frazer
    spec:
      containers:
        - name: web
          image: nginx:1.21.3
          ports:
            - containerPort: 80
```
```bash
# En ligne de commande :
kubectl run wepabb-red --image=kodekloud/webapp-color --port 8080 --env APP_COLOR=red
kubectl create deploy nginx-tp6 --image=nginx --port 8080 --replicas=2

# Création du manifest/pod
kubectl apply -f pod.yml
kubectl describe pod webapp-color

# lancement de notre pod
kubectl port-forward webapp-color 8080:8080 --address 0.0.0.0

# Création du manifest/deploy
kubectl apply -f nginx-deployment.yml
kubectl describe deploy hostname-101-deployment

kubectl describe deploy hostname-101-deployment | grep -i "Image"
kubectl get po -l app=nginx

# remplace 1.21.3 par latest
kubectl replace -f nginx-deployment.yml
kubectl get deploy
kubectl describe deploy hostname-101-deployment | grep -i "Image"

kubectl get po
kubectl describe po hostname-101-deployment-5767894b7d-j8ktv | grep -i "Image"
kubectl delete -f 

kubectl edit deploy dp-nginx
kubectl replace -f nginx-deployment.yml

```
* différentes stratégies
```yml
 RollingUpdate
   strategy:
    type: Recreate
```

```yml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```
```yml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
```

```yml
# nginx-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dp-nginx
  labels:
    role: nginx
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  replicas: 8
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      name: web
      labels:
        app: nginx
        type: pod
        formateur: Frazer
    spec:
      containers:
        - name: web1
          image: nginx
          ports:
            - containerPort: 80
```
```bash
# Cripter les valeur
echo 'Omar' | base64
cat test.txt | base64
# décripter 
base64 -d
```


# TP 7 : ConfigMap
```bash
# methond procédurale
kubectl create configmap my-config --from-literal=color=blue

# via manifest 
kubectl apply -f pod-configmap.yml
kubectl port-forward webapp-color 8080:8080 --address 0.0.0.0

# suppression :
kubectl delete -f pod-configmap.yml
kubectl delete configmaps my-config

# executer tous les manifests du repertoire
kubectl apply -f .

# voir que les variables d'environnement sont dans notre conteneur
kubectl exec -it webapp-color -- /bin/sh
export
exit
```

```yaml
# pod-configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-map
  namespace: production
data:
  color: "red"
---
apiVersion: v1
kind: Pod
metadata : 
  name: webapp-color
spec:
  containers:
    - name: webapp-color
      image: kodekloud/webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          valueFrom:
            configMapKeyRef:
              name: webapp-map
              key: color
```

# TP 8: Gestion du réseau / services / namespace

```bash
kubectl get ns
kubectl get namespaces
kubectl get pod -n kube-system
sudo systemctl status kubelet
kubectl get po --all-namespaces

kubectl create ns production
kubectl run nginx --image nginx --port 80 -n production
kubectl get po
# nginx n'apparait pas
# il faut spécifier le namespace
kubectl get po -n production
kubectl delete -n production po nginx

# jouter le nampspace dans les manifests
kubectl apply -f . -n production
# afficher configMap
kubectl -n production get cm
```

```yml
# namespace.yml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

```yml
# service-nodeport-web.yml
apiVersion: v1
kind: Service
metadata:
  name: srv-web
  namespace: production
  labels:
    app: web

spec:
  type: NodePort
  ports:
    - targetPort: 8080
      port: 8080
      nodePort: 30008
  selector:
    app: web
```

```yml
# pod-red.yml
apiVersion: v1
kind: Pod
metadata : 
  name: webapp-red
  labels:
    app: web
  namespace: production
spec:
  containers:
    - name: webapp-red
      image: kodekloud/webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          value: red
```
```yml
# pod-blue.yml
apiVersion: v1
kind: Pod
metadata : 
  name: webapp-blue
  labels:
    app: web
  namespace: production
spec:
  containers:
    - name: webapp-blue
      image: kodekloud/webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          value: blue
```

```bash
kubectl apply -f namespace.yml
kubectl apply -f pod-blue.yml pod-red.yml
kubectl apply -f service-nodeport-web.yml
# ou
kubectl apply -f .

# il faut spécifier le namespace ! ! !
kubectl describe svc -n production  srv-web
kubectl describe service -n production  srv-web
kubectl get po -n production
kubectl get po -n production -o wide

kubectl delete -f .

# exemple avec nginx
kubectl create deploy nginx --image nginx --port 80 --replicas=3
kubectl expose deploy/nginx --name nginx-svc --type NodePort --port 80
kubectl expose deploy/nginx --name nginx-svc --type NodePort --port 80 --dry-run=client -o yaml
# récupérer le node port
kubectl describe nginx-svc
```


# TP9 gestion de stockage

* On fourni au POD le PVC et non le PV
* k8 lie le PVC au PV
    * access mode
    * capacité de stockage
    * storageClassName

## Stokage Simple 
```bash
kubectl get pv
ls /
kubectl apply -f .
kubectl describe pod
kubectl exec -it mysql-pod -- ls /opt
kubectl delete -f mysql-volume.yml
# si on modifier (delete puis apply)
sudo sh -c 'echo Omar > /data-opt-volume/omar.txt'
sudo rm -Rf /data-volume
sudo rm -Rf /data-opt-volume
```
```yml
apiVersion: v1
kind: Pod
metadata : 
  name: mysql-volume
  labels:
    app: bdd
spec:
  containers:
    - name: mysql-volume
      image: mysql
      env:
        - name: MYSQL_DATABASE
          value: eazytraining
        - name: MYSQL_USER
          value: eazy
        - name: MYSQL_PASSWORD
          value: eazy
        - name: MYSQL_ROOT_PASSWORD
          value: password
      volumeMounts:
        - mountPath: /var/lib/mysql
          name: mysql-volume
  volumes:
    - name : mysql-volume
      hostPath:
        path: /data-volume
        type: DirectoryOrCreate
```
## Stokage PV / PVC
```bash
kubectl apply -f pv.yml
kubectl apply -f pvc.yml

kubectl get pv
kubectl get pvc
kubectl pvc mypvc

# si je supprimer un pvc
kubectl delete pvc mypvc

# le pv ne peut plus être attaché attaché a un autre pvc
# si on recrée le pvc il reste en mode pending
kubectl apply -f pvc.yml
# donc il faut obligatoirement supprimer le pv et en recréer un autre)

kubectl apply -f mysql-pvc.yml

# suppression / 1 pod / 2 pvc / 3 pv

```
```yml
# pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  storageClassName: mysql
  resources:
    requests:
      storage: 100Mi
  accessModes:
    - ReadWriteOnce
---
# pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  storageClassName: mysql
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data-pv
---
# mysql-pvc.yml
apiVersion: v1
kind: Pod
metadata : 
  name: mysql-pod
  labels:
    app: bdd
spec:
  containers:
    - name: mysql-volume
      image: mysql
      env:
        - name: MYSQL_DATABASE
          value: eazytraining
        - name: MYSQL_USER
          value: eazy
        - name: MYSQL_PASSWORD
          value: eazy
        - name: MYSQL_ROOT_PASSWORD
          value: password
      volumeMounts:
        - mountPath: /var/lib/mysql
          name: mysql-volume
        - mountPath: /opt
          name : data-opt
  volumes:
    - name : mysql-volume
      persistentVolumeClaim:
        claimName: mypvc
    - name : data-opt
      hostPath:
        path: /data-opt
        type: DirectoryOrCreate
```

# TP10 : INGRESS 

* ingress : exposer nos application proprement ==> attaquer des cluster kubernetes
* Installer Ingress controleur soit installé
    * www.ip-public.com/web :
        * URL = Host : www.ip-public.con
        * Path = chemin : /web
        * Service : 
            * Name : nom du service kubernetes
            * Port du sevice :  Cluster Ip ou NodePort

## Exemple avec nginx
```yml
# ingress-nginx.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-rule
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: www.frazer.com
    http:
      paths:
      - path: /nginx
        backend:
          service:
            name: nginx-svc
            port:
              number: 80
        pathType: Prefix
      - path: /web
        backend:
          service:
            name: web-svc
            port:
              number: 8080
        pathType: Prefix
```
```bash
# ajouter un host dans notre host
sudo sh -c 'echo "127.0.0.1 www.omar.com" >> /etc/hosts'

#Activer l'ingress
minikube addons enable ingress
kubectl create deploy nginx --image nginx --port 80 --replicas 2
kubectl get deploy
kubectl get po

# service qui expose nginx
kubectl expose deploy nginx --name nginx-svc --port 80
kubectl describe svc nginx-svc

# service qui explose webapp
kubectl run webapp --image kodeklou/webapp-color --port 8080
kubectl expose po webapp --name web-svc --port 8080

# règle ingress
kubectl apply -f nginx-ingress.yml
kubectl get ingress
kubectl describe ingress nginx-rule

# test avec curl
curl http://www.omar.com/nginx
curl http://www.omar.com/web
```

## TP : webapp color et ingress
* ajouter www.omar-webapp.com dans hosts
* utiliser dyndns avec adresse ip publique : omar-ajc.ddns.net

```yml
# webapp-blue.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-webapp-blue
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp-blue
  template:
    metadata:
      name: webapp-blue
      labels:
        app: webapp-blue
        formateur: Frazer
    spec:
      containers:
        - name: webapp-blue
          image: kodekloud/webapp-color
          ports:
            - containerPort: 8080
          env:
          - name: "APP_COLOR"
            value: "blue"
---
# webapp-red.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-webapp-red
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp-red
  template:
    metadata:
      name: webapp-red
      labels:
        app: webapp-red
        formateur: Frazer
    spec:
      containers:
        - name: webapp-blue
          image: kodekloud/webapp-color
          ports:
            - containerPort: 8080
          env:
          - name: "APP_COLOR"
            value: "red"
---
# ingress-webapp.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-rule
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: omar-ajc.ddns.net # www.omar-webapp.com # 
    http:
      paths:
      - path: /rouge
        backend:
          service:
            name: red-svc
            port:
              number: 8080
        pathType: Prefix
      - path: /bleu
        backend:
          service:
            name: blue-svc
            port:
              number: 8080
        pathType: Prefix
```

```bash
kubectl apply -f .
kubectl get deploy

# service
kubectl expose deploy deploy-webapp-red --name red-svc --port 8080
kubectl expose deploy deploy-webapp-blue --name blue-svc --port 8080

# ingress
kubectl apply -f ingress-webapp.yml

curl omar-ajc.ddns.net/rouge
curl omar-ajc.ddns.net/bleue

# http://omar-ajc.ddns.net/rouge
# http://omar-ajc.ddns.net/bleue

```




---

# HELP

```bash
# kubeconfig
kubectl config view
cat ~/.kube/config
# via les paramètres par défaut
kubectl config use-context minikube
# propre fichier de config
kubectl config use-context minikube --kubeconfig=monFichierDeConfig.yml

# Installation sur machine cliente
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
# créer le fichier de config dans ~/.kube
```
## INSTALLATION

### Install Minikube CentOS
```bash
#!/bin/bash
sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install libvirt qemu-kvm virt-install virt-top libguestfs-tools bridge-utils
yum install socat -y
sudo yum install -y conntrack
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker centos
systemctl start docker
sudo yum -y install wget
sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/bin/minikube
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo systemctl enable docker.service
```

### Install Minikube Ubuntu
```bash
#!/bin/bash
sudo apt-get -y update
sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
sudo apt-get install -y socat
sudo apt-get install -y conntrack
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
systemctl start docker
sudo apt-get -y install wget
sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/bin/minikube
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo systemctl enable docker.service
```

## COMMANDES
```
# Activer l'autocomplétion kubernetes
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc && source ${HOME}/.bashrc

# commandes kubernetes :
kubectl <action> <type_ressource> <Nom_ressource>
kubectl describe po <pod_name>
kubectl delete pod <pod_name>Création d'un pod

# Dans le cas ou le pod n'a qu'un seul container_port
kubectl logs <Pod_name> 
# Dans le cas ou le pod n'a plusieurs conteneurs
kubectl logs <pod_name> <Container_name>

# Création d'un pod
kubectl run <pod_name> --image=<image_name> --port <container_port>

# Deployment 
kubectl create deploy <nom_deploy> --image <image_name> --port <containerPort> --replicas=3

#Port forward
kubectl port-forward po/<pod_name <Host_port>:<containerPort> --address 0.0.0.0
kubectl port-forward <pod_name <Host_port>:<containerPort> --address 0.0.0.0
kubectl port-forward deploy/<deploy_name <Host_port>:<containerPort> --address 0.0.0.0

#Gestion de manifest
kubectl create -f <fichier.yml>
kubectl apply -f <fichier.yaml>
kubectl delete -f <fichier.yml>
kubectl replace -f <fichier.yml>

##Mise à jour d'une image dans un conatiner appartenant à un pod
kubectl set image <type_ressource(po/deploy)> <Ressource_name> <container_name>=<new_image>

kubectl create deploy dp-test --image nginx --replicas=2 --port 80
kubectl get deploy
kubectl scale deploy dp-test --replicas=4
kubectl get deploy

#Creer un service afin d'exposer un pod ou un deploy
kubectl expose deploy/nginx --name nginx-svc --type NodePort --port 80

#Referencer un service
1) Dans le meme namespace : <service_name>
2) Dans un namespace différent: <service.name>.<namespace>.svc.cluster.local

#Réferencer un pod
1) Dans le meme namespace : 192.168.0.1 (nom_pod)
2) Dans un namespace différent: 192-169-0-1.<namespace>.pod.cluster.local

###Démarrer minikube
# si la machine a été eteinte
sudo minikube delete
# lancer minikube
minikube start --driver=none



#Activer l'ingress
minikube addons enable ingress
```
