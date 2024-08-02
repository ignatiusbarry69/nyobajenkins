<!-- install docker desktop wsl2 (windows) / docker (linux) -->

<!-- create the network for jenkins -->

docker network create jenkins

<!-- pull and up jenkin container -->

docker run --name jenkins-docker `
  --detach `
  --privileged `
  --network jenkins `
  --network-alias docker `
  --env DOCKER_TLS_CERTDIR=/certs `
  --volume jenkins-docker-certs:/certs/client `
  --volume jenkins-data:/var/jenkins_home `
  --publish 2376:2376 `
  --publish 3000:3000 `
  --publish 5000:5000 `
  --restart always `
  docker:latest `
  --storage-driver overlay2

docker run --name jenkins-docker \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  --publish 3000:3000 \
  --publish 5000:5000 \
  --restart always \
  docker:latest \
  --storage-driver overlay2


<!-- create dockerfile for blueocean (must use UTF-8)-->

FROM jenkins/jenkins:2.426.2-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
 https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
 signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
 https://download.docker.com/linux/debian \
 $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.27.9 docker-workflow:572.v950f58993843"

<!-- build the image -->

docker build -t myjenkins-blueocean:2.426.2-1 .

<!-- run container from blueocean image -->

docker run --name jenkins-blueocean `
  --detach `
  --network jenkins `
  --env DOCKER_HOST=tcp://docker:2376 `
  --env DOCKER_CERT_PATH=/certs/client `
  --env DOCKER_TLS_VERIFY=1 `
  --publish 49000:8080 `
  --publish 50000:50000 `
  --volume jenkins-data:/var/jenkins_home `
  --volume jenkins-docker-certs:/certs/client:ro `
  --volume "${Env:USERPROFILE}:/home" `
  --restart=on-failure `
  --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" `
  myjenkins-blueocean:2.426.2-1

docker run --name jenkins-blueocean \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 49000:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  --volume "${HOME}:/home" \
  --restart=on-failure \
  --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" \
  myjenkins-blueocean:2.426.2-1


<!-- open designated port/location set for blueocean container -->

http://localhost:8080

<!-- create nginx.conf -->

events {}

http {
server {
listen 80; # This listens on the container's port 80, which is mapped to localhost:9000

        location / {
            proxy_pass http://jenkins-blueocean:8080;  # Use 8080 here as it's the port inside the Jenkins container
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

}

<!-- run nginx -->

docker run --name nginx `
  --detach `
  --network jenkins `
  --restart=always `
  --publish 9000:80 `
  --volume ${PWD}\nginx.conf:/etc/nginx/nginx.conf:ro `
  nginx:latest

<!-- pasang prometus -->
docker run -d --name prometheus -p 9091:9090 prom/prometheus

docker run -d \
  --name prometheus \
  --restart always \
  -p 9091:9090 \
  -v ${PWD}/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus


<!-- pasang grafana -->
docker run -d --name grafana -p 3031:3030 -e "GF_SERVER_HTTP_PORT=3030" grafana/grafana

docker run -d \
  --name grafana \
  --restart always \
  -p 3031:3030 \
  -e GF_SERVER_HTTP_PORT=3030 \
  grafana/grafana
  
docker exec -it prometheus sh

vi /etc/prometheus/prometheus.yml


 - job_name: "jenkins"                                                        
    metrics_path: /prometheus/                                                
    static_configs:                                                            
       - targets: ["host.docker.internal:8080"]