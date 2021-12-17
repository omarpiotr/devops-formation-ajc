# TP 1 : déploiement Signle-node avec minikube
* Déployer minikube a l'aide d'un conteneur Docker
* EC2 : t2.large
* 20 Go
* sg-ajc-minkube : 22 / 80 / 8080 / [ 30000 - 32500 ]
* 52.91.141.146 
* Script de démarrage : Install Minikube Ubuntu
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

* Sur notre machine ubuntu
```bash
# démarrer minikube et création de notre cluster
minikube start --driver=none

# minkube a créer une multitude de conteneur:
docker ps
kubectl version
kubectl -v

# afficher les noeuds
kubectl get nodes
> NAME               STATUS   ROLES                  AGE     VERSION
> ip-172-31-24-154   Ready    control-plane,master   8m26s   v1.22.3

# décrire nos noeud
kubectl describe nodes ip-172-31-24-154

# afficher les pod
kubectl get pod

# activation de l'auto-completion
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
# se déconncter et se reconnecter

# information sur les clusters
kubectl  cluster-info

# création d'un pod
kubectl run nginx-omar --image nginx --port 80
kubectl get po
kubectl get po nginx-omar -o yaml
kubectl describe pod nginx-omar
kubectl logs nginx-omar

# liste de nos pod avec plus d'options
kubectl get po -o wide

# Replica Set : on fédère les pod autour d'une ressource
kubectl get replicasets.apps
kubectl get rs

# Deployment (gérer le cycle de vie de notre application): fédérer les replicatset
kubectl get deployments.apps
```

# TP3 : Consommer notre application via le port forward
```bash
kubectl get rs
# pour des besoins de test (non durable): bloque le terminal
kubectl port-forward nginx-omar 8080:80 --address 0.0.0.0
# CTRL + C : arrêter

# Supprimer notre pod
kubectl delete pod nginx-omar

# création avec 3 replicats
kubectl create deploy nginx-deployment --image nginx --port 80 --replicas=3
kubectl get deploy
> NAME               READY   UP-TO-DATE   AVAILABLE   AGE
> nginx-deployment   3/3     3

kubectl get rs
> NAME                          DESIRED   CURRENT   READY   AGE
> nginx-deployment-7c9cfd4dc7   3         3         3       51s

kubectl create deploy webapp --image nginx --port 80 --replicas=3
kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-7c9cfd4dc7   3         3         3       2m1s
webapp-7dfc86cd9d

kubectl get po
> NAME                                READY   STATUS    RESTARTS   AGE
> nginx-deployment-7c9cfd4dc7-4n7mw   1/1     Running   0          2m26s
> nginx-deployment-7c9cfd4dc7-m6lm2   1/1     Running   0          2m26s
> nginx-deployment-7c9cfd4dc7-wmhqt   1/1     Running   0          2m26s
> webapp-7dfc86cd9d-7jb2z             1/1     Running   0          51s
> webapp-7dfc86cd9d-cnvrf             1/1     Running   0          51s
> webapp-7dfc86cd9d-phd8v  

# si on supprimer un pod, le deploy va en créer un nouveau !!!
kubectl delete po webapp-7dfc86cd9d-phd8v
> pod "webapp-7dfc86cd9d-phd8v" deleted

kubectl get po
> NAME                                READY   STATUS    RESTARTS   AGE
> nginx-deployment-7c9cfd4dc7-4n7mw   1/1     Running   0          4m20s
> nginx-deployment-7c9cfd4dc7-m6lm2   1/1     Running   0          4m20s
> nginx-deployment-7c9cfd4dc7-wmhqt   1/1     Running   0          4m20s
> webapp-7dfc86cd9d-7jb2z             1/1     Running   0          2m45s
> webapp-7dfc86cd9d-cnvrf             1/1     Running   0          2m45s
> webapp-7dfc86cd9d-fcxmj

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
nginx-pod.yml :
```yml
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
webappcolor-pod.yml :
```yml
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

# TP 5 bis
```
1) creer un pod webapp-color (image=kodekloud/webapp-color) avec couleur red
2) creer un manifest pour replicaset qui devra creer 3 replicas de l'image webapp avec couleur bleue

Chacun des pod crées devra avoir les label (env=prod et app=webapp)
le sélecetur à utilisé par le replicaset devar etre app=webapp.
```
rs-webapp.yml
```yml
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
> NAME             READY   STATUS    RESTARTS   AGE
> rswebapp-2dhdl   1/1     Running   0          23s
> rswebapp-sdbdc   1/1     Running   0          23s
> webapp1          1/1     Running   0          13m

# Si on rajoute un webapp2
kubectl run webapp2 --image=kodekloud/webapp-color -l  app=webapp,env=prod  --env APP_COLOR=blue

# on voit que k8s le supprimer aussitot
kubectl get po
> NAME             READY   STATUS        RESTARTS   AGE
> rswebapp-2dhdl   1/1     Running       0          2m16s
> rswebapp-sdbdc   1/1     Running       0          2m16s
> webapp1          1/1     Running       0          14m
> webapp2          1/1     Terminating   0          9s

# si on supprimer un pod un nouveau sera crée
kubectl delete pod rswebapp-2dhdl --force

# si on supprimer notre RS : il supprimer toutes les ressource meme webapp1
kubectl delete -f rs-webapp.yml
kubectl get pod
```

---

# HELP
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

## COMMANDE
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
```
