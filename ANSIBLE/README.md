# ENVIRONNEMENT
* EC2 : 
    * Master : t3.medium / omar-ansible.ddns.net
    * Workers : t2.micro
* SG : 22 / 80 

# TP1: Installation
## Master
```bash
# via pip : dernière version
python3 --version
sudo apt-get update
sudo apt-get install python3-pip
sudo pip3 install ansible
ansible --version
# via gestionnaire de packet < latest:
sudo apt-get update
sudo apt-get install ansible
ansible --version

# installation de sshpass
sudo apt-get install sshpass -y
```
* fichier des configurations:
    * /etc/ansible/ansible.cfg
    * ~/.ansible.cfg
    * ./ansible.cfg

## Workers
```bash
# Activation de la connexion SSH par mot de passe
sudo vi /etc/ssh/sshd_config
# PasswordAuthentication yes

# Redemarrer le service ssh
sudo systemctl restart ssh

# Modifier le mot de passe du compte ubuntu
sudo -i
passwd ubuntu 
# (puis modifiez le mot de passe)
```

## Helps
* Désinstallation pauqets sur Linux
    * https://linuxfr.org/wiki/desinstaller-proprement-ses-paquets-sur-sa-distribution

# TP 2 : Commandes ad-hoc
#### ***`hosts au format ini`***
```ini
worker01 ansible_host=172.31.94.223 ansible_user=ubuntu ansible_password=ubuntu ansible_sudo_pass=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
worker02 ansible_host=172.31.91.167 ansible_user=ubuntu ansible_password=ubuntu ansible_sudo_pass=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```
[master]
```bash
# command ping sur tous mes hosts
ansible -i hosts all -m ping
    worker02 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
    worker01 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
# command copy sur le worker01 uniquement
ansible -i hosts worker01 -m copy -a "dest=/home/ubuntu/omar.txt content='Bonjour ACJ\n'"
    worker01 | CHANGED => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": true,
        "checksum": "e5e5e1da0075c4ba5934eb2237b0d6e5f2984c72",
        "dest": "/home/ubuntu/omar.txt",
        "gid": 1000,
        "group": "ubuntu",
        "md5sum": "2cdc3b25b650c989dea96933409c1bde",
        "mode": "0664",
        "owner": "ubuntu",
        "size": 11,
        "src": "/home/ubuntu/.ansible/tmp/ansible-tmp-1640689065.710897-7928-10897906089111/source",
        "state": "file",
        "uid": 1000
    }
# supprimer le fichier
ansible -i hosts worker01 -m file -a "path=/home/ubuntu/omar.txt state=absent"
```

# TP 3 Modules
ansible -i hosts worker01 -b -m apt -a "name=nginx state=absent purge=yes force_apt_get=yes"
```bash
# via apt
ansible -i hosts all -m ping

ansible -i hosts worker01 -m apt -b -a 'name=apache2' -b
ansible -i hosts worker02 -m apt -b -a 'name=nginx' -b

ansible -i hosts worker01 -m apt -a 'name=apache2 state=absent purge=yes' -b
ansible -i hosts worker02 -m apt -a 'name=nginx state=absent purge=yes' -b

# via package
ansible -i hosts worker01 -m package -b -a "name=nginx state=present"
ansible -i hosts worker02 -m package -b -a "name=apache2 state=present"

ansible -i hosts worker01 -m service -a "name=nginx state=started enabled=yes" -b

ansible -i hosts worker01 -m package -b -a "name=nginx state=absent purge=yes autoremove=yes"
ansible -i hosts worker02 -m package -b -a "name=apache2 state=absent purge=yes autoremove=yes"

#sudo apt-get remove --purge --auto-remove nginx
```
# TP4 : Invetaire au format yaml & module setup
#### ***`hosts.yml`***
```yml
all:
  hosts:
    worker01: 
      ansible_host: 172.31.94.223
      ansible_user: ubuntu 
      ansible_password: ubuntu 
      ansible_sudo_pass: ubuntu 
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
      
    worker02: 
      ansible_host: 172.31.91.167
      ansible_user: ubuntu 
      ansible_password: ubuntu 
      ansible_sudo_pass: ubuntu 
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```
```bash
# tester un ping sur le worker01
ansible -i hosts.yml worker01 -m ping
# récupérer les information de nos machines setup
ansible -i hosts.yml all -m setup
ansible -i hosts.yml worker01 -m setup | grep -i hostname

# le module debug ne récupére pas les facts vérifie les inventaires

# ajouter la variable env pour worker01
ansible -i hosts.yml worker01 -m debug -a "msg={{ env }}"

# récupérer l'inventaire par défaut format json
ansible-inventory -i hosts.yml --list
# récupérer l'inventaire au format yaml
ansible-inventory -i hosts.yml --list -y

# récupérer l'inventaire d'un seul host:
ansible-inventory -i hosts.yml --host worker01
ansible-inventory -i hosts.yml --host worker01 -y
```

* gather_facts : False 
    * ne pas télécharger les information de nos machines

# TP5 : Inventaire et Variable
* créer fichier hosts.ini
```ini
[all:vars]
ansible_user=ubuntu

[ansible]
localhost ansible_connection=local

[prod]
worker01 ansible_host=172.31.94.223 ansible_password=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
worker02 ansible_host=172.31.91.167 ansible_password=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[prod:vars]
env=production
```
```bash
# Transformer le fichier ini en fichier json et yml
ansible-inventory -i hosts.ini --list > hosts2.json
ansible-inventory -i hosts.ini --list -y > hosts2.yml

# réalisation de tests
ansible -i hosts.ini all -m ping
ansible -i hosts2.yml all -m ping
ansible -i hosts2.json all -m ping
```
#### ***`correction manuelle du hosts.yml`***
```yml
all:
  children:
    ansible:
      hosts:
        localhost:
          ansible_connection: local
    prod:
      hosts:
        worker01:
          ansible_host: 172.31.94.223
          ansible_ssh_common_args: -o StrictHostKeyChecking=no
        worker02:
          ansible_host: 172.31.91.167
          ansible_ssh_common_args: -o StrictHostKeyChecking=no          
      vars:
        ansible_password: ubuntu
        env: production   
  vars:
    ansible_user: ubuntu
```
#### ***`correction manuelle du hosts.json`***
```yml
{
    "all": {
        "children": {
            "ansible": {
                "hosts":{
                    "localhost": {
                        "ansible_connection": "local"
                    }
                }
            },
            "prod":{
                "hosts":{
                    "worker01": {
                        "ansible_host": "172.31.94.223",
                        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
                    },
                    "worker02": {
                        "ansible_host": "172.31.91.167",   
                        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"                      
                    }
                },
                "vars":{
                    "ansible_password": "ubuntu",
                    "env": "production"
                }
            }       
        },
        "vars":{
            "ansible_user": "ubuntu"
        }
    }
}
```

# TP 6: surcharge de variable
* Création des repertoires et fichiers
    * group_vars/prod.yml
    * host_vars/worker01.yml
    * host_vars/localhost.yml

!["caputre_01"](./assets/Capture_ansible_01.JPG)

```bash
mkdir group_var host_vars
ansible -i hosts.ini all -m debug -a "msg={{ env }}"
ansible -i hosts.ini worker01 -m debug -a "msg={{ env }}" -e env='test'
```