# SonarQube
## 1-Prerequisites
* Use community edition
* SonarQube installation need minimum JDK 11
* Need database like Postgres or Mysql
* Need SonarScaner for code analysis

## 2-SonarQube Container
* Image : sonarqube:lts-community
* Environment varialbes
    * SONAR_JDBC_UR
    * SONAR_JDBC_USERNAME
    * SONAR_JDBC_PASSWORD
* Volumes :
    * /opt/sonarqube/dat
    * /opt/sonarqube/extensions
    * /opt/sonarqube/log

```yml
services:
  sonarqube:
    image: sonarqube:lts-community
    hostname: sonarqube
    container_name: sonarqube
    read_only: true
    depends_on:
      db:
        condition: service_healthy
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_temp:/opt/sonarqube/temp
    ports:
      - "9000:9000"
  db:
    image: postgres:17
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
    hostname: postgresql
    container_name: postgresql
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
  sonarqube_temp:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:
  postgresql_data:
```
Default login and password are admin / admin and must be changed


## 3-code analysis : SonarScaner

### 3.1 Generate a Token
In SonarQube web Interface generate a `Project | Global analysis token` :
* As an admin :
    * **Administration** > **Security** > **Users** > **update Token**
* As a user :
    * **User** > **My Account** > **Security** 

### 3.2 Configuring the project
* Create a configuration file called `sonar-project.properties`
```properties
# must be unique in a given SonarQube instance
sonar.projectKey=my:project

# sonarQube URL
sonar.host.url=http://localhost:9000

# --- optional properties ---
 
# Path is relative to the sonar-project.properties file. Defaults to .
sonar.sources=.
sonar.exclusions=venv/**/*

# defaults to project key
#sonar.projectName=My project
# defaults to 'not provided'
#sonar.projectVersion=1.0
 
# Encoding of the source code. Default is default system encoding
#sonar.sourceEncoding=UTF-8
``` 
### 3.3 Running SonarScanner CLI from zip file
[( link )](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/#running-from-zip-file)
* Install SonarScanner CLI 
* Check `sonar-scanner.properties` is configured for your project
* Commands
```bash
# Check sonar-scanner (for windows: sonar-scanner.bat)
sonar-scanner -h

# Fron your project folder run
sonar-scanner -Dsonar.token=myAuthenticationToken
sonar-scanner -Dsonar.login=myAuthenticationToken
# On windows
sonar-scanner "-Dsonar.token=myAuthenticationToken"
sonar-scanner "-Dsonar.login=myAuthenticationToken"
```

### Running SonnarScanner CLI for docker container


