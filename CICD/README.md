
# Configuration de l'environnement de Travail

## a) GitHub : configuration et Fork du projet
* Se connecter sur son compte git
* Générer un Personal access token :
    * User → settings → Developer Settings → Personal Access Token 
    * Générer le token, le copier et le GARDER JALOUSEMENT!!! (token_example_key123456)
* Forker le projet : https://github.com/Zerofiltre-Courses/cicd-testing-java-cours-aws.git
* récupérer le lien de notre répétoire forké git

## b) VM centos : configurations
```bash
# installation de git
sudo yum install git
git --version

# installation de java
sudo yum install java-11-openjdk-devel
java -version

# installation de maven
sudo yum install maven
mvn --version

# forcer maven a utiliser java
sudo alternatives --config java
# taper 1
# séléctionner la version javac
sudo alternatives --config javac
# taper 1

# cloner le projet depuis notre github
git clone https://github.com/omarpiotr/cicd-testing-java-cours-aws.git
cd cicd-testing-java-cours

# changer l'origine en utilisant le token
#git remote set-url origin https://<username>:<token>@github.com/{owner}/{repo}
git remote set-url origin https://omarpiotr:token_example_key123456@github.com/omarpiotr/cicd-testing-java-cours-aws.git
```

## c) Machine personelle : configurations
* Installer VS Code
    * Plugin : remote SSH
        * CTRL + Shift + P ou F1 : remote ssh : connect to host
            * remote-ssh → entrer 	
            * username@host → entrer 	
            * Choisissez 'linux' si le choix est demandé
            * coller le mot de passe → entrer 
            * Open folder (ouvrir un dossier): Entrer les memes infos de connexion si de nouveau demandé
    * Plugin : git graph (permet de voir le graph)

* Installer Filezilla
    * se connecter sur la machine
        * ip: 18.204.13.237
        * logit: centos
        * mdp: ****
        * port : 22


# TP01 : Lancer les tests (java et maven)
* test unitaire : Test
* test intégration : IT
```bash
# ouvrir/se placer sur la branche
git checkout m1ch1_OK

# lancer les test avec maven
mvn  test

# empaqueté le projet
mvn clean package

# démarrer l'application java
java -jar target/calculator.jar

# se rendre sur la machine: http://18.204.13.237:8080
```

# TP02 : Installation de SONAR 
* scaner le code / tester la qualité du code
```bash
git checkout m1ch2_OK

docker pull sonarqube
docker run --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 8080:9000 sonarqube
# CTRL + C : arrêter 

# relancer le conteneur 
docker start sonarqube
```
* Interface web Sonar :
    * http://18.204.13.237:8080 
    * Login/mdp : admin/admin 
* Envoyer notre application a sonar
    * Dans VScode : rep .m2 : settings.xml → <sonar.host.url> en localhost car sur la mm machine

* Générer le token sonar 
    * Adminitration → Security → Users → Token : update token : Copier et sauvegarder!
    * 484f4bbf336fff867ee747cb1ca33b9f8bebb6e5

```bash
# mvn sonar:sonar -s .m2/settings.xml -Dsonar.login=<token>
mvn sonar:sonar -s .m2/settings.xml -Dsonar.login=484f4bbf336fff867ee747cb1ca33b9f8bebb6e5
```

* Interface web Sonar → Project → calculator
    * Onglet : New Code / Overall Code 
    * Métrique/code qui a été modifié ajouté
    * Quality Gates

* corriger le taux de couverture plugin jacoco (pom.xml)
```bash
mvn test
```
* Machine personelle : télécharger avec filezilla en local
    * ouvrir avec un navitageur : site/jacoco/index.html


```bash
# relancer sonar
mvn sonar:sonar -s .m2/settings.xml -Dsonar.login=484f4bbf336fff867ee747cb1ca33b9f8bebb6e5
# raffraichir la page web
```
![Capture04](./assets/Capture_CICD04.JPG)

* corriger quelques bug en commentant le code:
* commenter sous VS-Code : ctrl + / + shift 
```
//calculatorTestJava (ligne 121)
//doubleCalculatorTest (ligne 27)
``` 
```bash
mvn clean package
mvn sonar:sonar -s .m2/settings.xml -Dsonar.login=484f4bbf336fff867ee747cb1ca33b9f8bebb6e5
```
![Capture01](./assets/Capture_CICD01.JPG)


# TP3 : Automatiser ces Tests avec Jenkins 
* différents environnements dev/uat/prod

* VsCode : différents environnement
    * src → main → resources :
        * application-dev.yaml
        * application-prod.yaml
        * application-uat.yaml

* l'idée est de démarrer l'application sur chacun des environnements

```bash
git checkout m1ch3_OK

mvn clean package

# java -jar -Dspring.profiles.active=dev|uat|prod target/calculator.jar 
java -jar -Dspring.profiles.active=dev target/calculator.jar 
java -jar -Dspring.profiles.active=uat target/calculator.jar 
java -jar -Dspring.profiles.active=prod target/calculator.jar 
```
* Depuis un navigateur :
    * http://18.204.13.237:8090 (dev)
    * http://18.204.13.237:8888 (uat)
    * http://18.204.13.237:9999 (prod)

* utilisation de docker
```bash
# build de l'image
docker build -t calculator-demo:1.0.0 .

# build les conteneurs
docker run --name calculator-demo -e SPRING_ACTIVE_PROFILES=dev -p 8090:8090 calculator-demo:1.0.0
docker run --name calculator-demo -e SPRING_ACTIVE_PROFILES=uat -p 8888:8888 calculator-demo:1.0.0
docker run --name calculator-demo -e SPRING_ACTIVE_PROFILES=prod -p 9999:9999 calculator-demo:1.0.0
```
![Capture02](./assets/Capture_CICD02.JPG)

* utilisation de docker-compose

```yml
version: '3.3'
services:
    
    demo-dev:
        container_name: calculator-demo-dev
        ports:
            - '8090:8090'
        environment:
            - SPRING_ACTIVE_PROFILES=dev
        image: calculator-demo:1.0.0

    demo-uat:
        container_name: calculator-demo-uat
        ports:
            - '8888:8888'
        environment:
            - SPRING_ACTIVE_PROFILES=uat
        image: calculator-demo:1.0.0

    demo-prod:
        container_name: calculator-demo-prod
        ports:
            - '9999:9999'
        environment:
            - SPRING_ACTIVE_PROFILES=prod
        image: calculator-demo:1.0.0       				
```

# TP 4
```bash
git branch
git checkout m2ch4_OK
# installation de Jenkins sur un conteneur
docker pull jenkins/jenkins:lts
# démarrer le conteneur : lancement en root n'est pas recommandé / 8080 front end / 50000 backend
docker run -u root --name jenkins -p 9090:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
```
* Jenkins suivante: http://52.23.177.191:9090

## Création de credentials DockerHub et GitHub et sonar
* Manage Jenkins → Manage credentials → Survoler globals → flèche déroulante → Add Credentials
    * GitHub : 
        * Type : nom utilisateur et mot de passe
        * Ajouter vos identifiants GitHub 
        * ID : GitHubCredentials
	* Type : nom utilisateur et mot de passe
        * Ajouter vos identifiants DockerHub 
        * ID : DockerhubCredentials
    * Type : Secret text
        * secret (token récupéré depuis sonar) : 9d7c23ed6e743dc68a904fde58abf8a8ba3fb37e
        * ID : sonar

![Capture26](./assets/Capture_CICD26.JPG)	

## Installation des plugins :
* docker
* email (Email Extension Template Plugin)
* sonar (SonarQube Scanner for Jenkins)

## Configuration maven et Docker
* Manage Jenkins → Global Configuration tool → Add Maven instllation → install automatically : MavenLatest
* Manage Jenkins → Global Configuration tool → Add Docker instllation  → install automatically (Download from docker.com) : DockerLatest


## Configuration du plugin sonar (Jenkins → Sonar )
* (help depuis Sonar) http://52.23.177.191:8080/documentation/analysis/jenkins/
* Manage jenkins → config système → sonarqube server → ajouter installation 
    * nom dans jenkinsfile Nom : SonarQubeLocalServer
    * URL : http://172.17.0.1:8080
    * Token : sonar

![Capture15](./assets/Capture_CICD15.JPG )

## Configurer sonar pour communiquer avec Jenkins (configurer un web hook)
* IHM de Sonar : http://52.23.177.191:8080
* Administration → Configuration → webhooks
    * Name : Jenkins webhook
    * URL : http://172.17.0.1:9090/sonarqube-webhook/

![Capture19](./assets/Capture_CICD19.JPG)


## Configurer l'envoi de mail avec google
* Installation
    * Admin Jenkins → Config → Gestion de plugins → Disponible → Email Exetension Template
* Configuration
    * Admin Jenkins → configurer le system → Notification par email
        * Serveur SMTP: smtp.gmail.com
        * avancé:
            * Use SMTP authntication
            * Port: 587        
            * Use TLS

![Capture20](./assets/Capture_CICD20.JPG)

```
TIPS GOOGLE:

Use less secure App in gmail

ouvrir Gmail
profil haut droite → gestion du compte google → security → Acces moins sécurisé application : Activé
(security → Less secure app access)
paramètre gmail roue denté: voir tous les paramètres → Transfert et POP/IMAP → Activer IMAP

si authentification à 2 facteurs
sécurité → connexion à google → mots de passe des application 
    → se ré-authentifier
    → générer des mdp destiné à une application :
    → selectionner une application 
        jenkinsacj → affiche un MDP (une seule fois donc récupérer)

https://accounts.google.com/DisplayUnlockCaptcha
```


## Configuration d'un pipline multibranche sous Jenkins 
* Ecouter plusieur branches à la fois → a chaque modification sur l'une des branches → déclancher le pipline
* Jenkins → nouvel item  → Saisir un nom + pipeline mutibranche
    * Nom : calculatrice
    * Branch Source Git 

![Capture21](./assets/Capture_CICD21.JPG)

```bash
git add .
git commit -m "add tag when pull"
git push -u origin m2ch4_OK
```

# TP5
```bash
# fusion sur la branche Ready
git checkout ready
git branch
git merge --no-ff m2ch4_OK
git push -u origin ready
# merge branche n2ch4_OK dans la branche Ready puis je push
# fusion sur la branche Main
git checkout main
git merge --no-ff ready
git push -u origin main
```
![Capture23](./assets/Capture_CICD23.JPG)

* Standard versionning  (https://nvie.com/posts/a-successful-git-branching-model/)
    * x.y.z
        * x : modification majeur (non rétro-active)
        * y : modification compatible rétro-active
        * z : bug/fixe

```bash
git checkout ready
git checkout -b release-0.1.0
git push -u origin release-0.1.0
```

* Correction à faire : remplacer aux lignes 102 et 109 de jenkinsfile
```Groovy
return (branchName == 'ready' || branchName.startsWith("release-") || branchName.startsWith("hotfix-")) ? 'uat' : 'dev'
return (branchName == 'ready' || branchName.startsWith("release-") || branchName.startsWith("hotfix-")) ? '8888' : '8090'
```

```bash
git add .
git commit -m "Deploy release and hotfix on uat"
git push 
```
![Capture25](./assets/Capture_CICD25.JPG)

```bash
# On passe en production
git checkout main
git merge --no-ff release-0.1.0
git push

# capture depuis la branch main
git tag
git tag -a v0.1.0 -m "very first release of calculator"
# push le tag
git push origin --tags

# mettre a jour la branche des dév cad ready
 git checkout ready

# attire les modif de la release sur celle-ci
git merge --no-ff release-0.1.0
git push
```

![Capture27](./assets/Capture_CICD27.JPG)

https://github.com/omarpiotr/cicd-jenkins-sonar-java









