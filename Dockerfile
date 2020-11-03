FROM jenkins/jenkins:lts
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG /var/jenkins_conf

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 19.03.12
# ugh
USER root 


#RUN groupadd -g ${DOCKER_GID} docker\
#&& usermod -a -G docker jenkins
RUN curl -fsSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xzC /usr/local/bin --strip=1 docker/docker


COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /var/jenkins_conf/jenkins.yaml
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt