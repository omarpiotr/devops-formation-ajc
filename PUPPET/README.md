# INSTALLATION / CONFIGURATIONS PUPPET

## PRE-REQUIS (AWS)
* EC2
    * t2.medium (4Go RAM / 2 CPU / 20 Go)
* SG
    * Ports SSH (22) / ICMP (ping) / 8140 (puppet)

## Initialisation des 2 machines
```bash
# initialisation
sudo su -
yum update -y
yum install vim -y

# renomer nos hostname : puppetmaster / client
vim /etc/hostname

# ajouter des hosts
vim /etc/hosts 
# ou
echo '172.31.95.61 puppetmaster.omar.edu puppetmaster' >> /etc/hosts
echo '172.31.86.36 client.omar.edu client' >> /etc/hosts
# ou 
echo -e '172.31.95.61 puppetmaster.omar.edu puppetmaster\n172.31.86.36 client.omar.edu client' >> /etc/hosts

# vérifier nameserver 172.31.0.2
cat /etc/resolv.conf

# SELENUX=disabled
vi /etc/sysconfig/selinux
# ou
vi /etc/selinux/config
# redémarrer le system

# Test de ping depuis chacunes des machines
ping puppetmaster.omar.edu
ping client.omar.edu

```
## Configuration de la machine SERVEUR
```bash
# ajouter le dépot
rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
yum update

# installer le serveur (+agent)
yum install puppetserver -y
systemctl start puppetserver
systemctl enable puppetserver

# déconnecter et se reconnecter avec sudo
exit
sudo su -

# vérifications
where is puppet
yum info puppetserver
yum info puppet-agent
puppetserver -v

# configuration
vi /etc/puppetlabs/puppet/puppet.conf
```

```
[master]
dns_alt_names = puppetmaster.omar.edu,puppetmaster

[main]
certname = puppetmaster.omar.edu
server = puppetmaster.omar.edu
environment = production
runinterval = 1h 
```

```bash
# redémmarrer le serveur
systemctl restart puppetserver

# afficher les certificat signés par le serveur
puppetserver ca list --all
# ca_crt.pem = certificat qui va signer
```

* puppet : commande pour l'agent
* puppetserver : pour le serveur


## Configuration de la machine CLIENT / SLAVE
```bash
# installation de l'agent
rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
yum update
yum install puppet-agent -y

# déconnecter et se reconnecter avec sudo
exit
sudo su -

# vérifications
where is puppet
yum info puppet-agent

# configuration
vi /etc/puppetlabs/puppet/puppet.conf
```
```
[main]
certname = client.omar.edu
server = puppetmaster.omar.edu
environment = production
runinterval = 1h 
```

## Démarrage de l'agent et signature du certificat
* coté agent : envoyer la demande de certifcat au serveur/master
    ```bash
    # activer l'agent qui va envoyer la demande de certificats 
    puppet resource service puppet ensure=running enable=true
    # verifier 
    systemctl status puppet
    ```
* coté serveur : singer le certificat venant de l'agent
    ```bash
    # afficher les certificats en attente de validation (celui de l'agent)
    puppetserver ca list
    # générer puis singer le certificat
    puppetserver ca sign --certname client.omar.edu
    ```

# Premier manifeest : création d'un repertoire
## serveur puppet
```bash
cd /etc/puppetlabs/code/environments/production/manifests/manifests/
# le premier manifest qui est lu est site.pp
vim site.pp
```
```ruby
node 'client.omar.edu' 
{
    file { '/tmp/omar':
        ensure => 'directory',
        owner => 'root',
        group => 'root',
        mode => '0755',
    }

    group {'omar':
        ensure => present,
        name => 'omar',
        gid => '2000',
    }

    user {'omar':
        ensure => present,
        uid => '2000',
        gid => '2000',
        shell => '/bin/bash',
        home => '/home/omar'
    }

    file { '/home/omar':
        ensure => 'directory',
        owner => 'omar',
        group => 'omar',
        mode => '0755',
    }
}
```

## client / agent 
```bash
# On force l'agent à tester le serveur sans attendre l'interval
puppet agent -t
# ou
puppet agent --test
```