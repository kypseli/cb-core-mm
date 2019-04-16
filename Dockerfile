FROM cloudbees/cloudbees-core-mm:2.164.2.1

LABEL maintainer "kmadel@cloudbees.com"

USER root

#skip setup wizard and disable CLI
ENV JVM_OPTS -Djenkins.CLI.disabled=true -server
ENV TZ="/usr/share/zoneinfo/America/New_York"

#Jenkins system configuration via init groovy scripts - see https://wiki.jenkins-ci.org/display/JENKINS/Configuring+Jenkins+upon+start+up 
COPY ./init.groovy.d/* /usr/share/jenkins/ref/init.groovy.d/
COPY ./license-activated/* /usr/share/jenkins/ref/license-activated-or-renewed-after-expiration.groovy.d/
COPY ./quickstart/* /usr/share/jenkins/ref/quickstart.groovy.d/

#install suggested and additional plugins
ENV JENKINS_UC http://jenkins-updates.cloudbees.com

#config-as-code plugin configuration
COPY config-as-code.yml /usr/share/jenkins/config-as-code.yml
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/config-as-code.yml

COPY ./jenkins_ref /usr/share/jenkins/ref
COPY ./plugins/* /usr/share/jenkins/ref/plugins/

#install suggested and additional plugins
ENV JENKINS_UC http://jenkins-updates.cloudbees.com
COPY plugins.txt plugins.txt
COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

RUN /usr/local/bin/install-plugins.sh $(cat plugins.txt)

user jenkins