# TP 1 : Script de démarrage + serveur Web

* virginie du nord
* 2 étiquettes
    * Name 
    * formateur

- créer la machine ubuntu
- lancer l'instance avec OS ubuntu et les bons caractérisques

```
Name : omar-ec2-webserver
formateur : Frazer
omar-sg-web
open web ports
```

```bash
#!/bin/bash
apt-get update -y
apt-get install nginx git -y
systemctl start nginx
systemctl enable nginx
git clone https://github.com/daviddias/static-webpage-example.git
rm -rf /var/www/html/*
mv static-webpage-example/src/* /var/www/html/
```


# TP 2 : Script de démarrage + Docker

```bash
#!/bin/bash
apt-get update -y
apt-get install curl -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl start docker
systemctl enable docker
docker run -d -p 80:8080 pengbai/docker-supermario
```

# TP 3 : Script de démarrage + Docker + intranet

```bash
#!/bin/bash
apt-get update -y
apt-get install curl -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl start docker
systemctl enable docker
docker run -d --name intranet  -p 80:8080 sadofrazer/ic-webapp:1.0
```

Se connecter sur la vm puis :
```bash
docker exec -it intranet cat /opt/releases.txt
docker exec intranet cat /opt/releases.txt
>AJC
>App Version 1.0
```

ACTION → PARAMETRE DE L'INSTANCE → MODIFIER LES DONNEE UTILISATEUR


# TP 4 : EBS + Snapshot

* Création d'un volume
    * Volume → Créer volume → (attention a la Zone de disponibilité ! ! !)
* Attacher ce volume à notre instance
    * Volumes → Attacher un volume → choisir l'instance

```bash
# rajouter le disque dans notre VM
ls /dev
# formatage du disque
sudo mkfs.ext3 /dev/xvdf
# on créer le dossier qui sera notre point de montage
sudo mkdir /mnt/data-store
df -h
# on monte le nouveau disque sur le dossier mnt/data-store
sudo mount /dev/xvdf /mnt/data-store
# copie du fichier dans ce disque
docker exec -t intranet cat /opt/releases.txt
sudo docker exec -t intranet cat /opt/releases.txt > releases-backup.txt
sudo cp releases-backup.txt  /mnt/data-store/releases-backup.txt
# copie d'un autre fichier
sudo sh -c "echo Omar toto test O_o > /mnt/data-store/toto.txt"
```
* Création d'un instantané
    *  Volume → selectionner volume → Créer un instantané de notre volume
* Simulation de la perte du Volume 
    * Volume → Forcer le détachement → (attendre) Supprimer le volume
* Création d'un volume a partir d'un instantané
    * Instantanés → selectionner l'instantané → Créer un volume a partir d'un instantané (attention a la Zone de disponibilité ! ! !)
* Attacher ce volume à notre instance
    * Volumes → Attacher un volume → choisir l'instance

```bash
# rajouter le disque dans notre VM
ls /dev
sudo mount /dev/xvdf /mnt/data-store
```



