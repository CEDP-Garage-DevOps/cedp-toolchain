FROM ubuntu:18.04
ARG AF_PSW

RUN apt-get update \
 && apt-get install -y software-properties-common unzip wget curl gnupg git apt-utils

RUN apt-get install -y vim curl
# Java SBT Maven Gradle
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
 && apt-get update \
 && apt-get install -y openjdk-8-jdk \
 && apt-get install -y sbt=1.2.7 \
 && apt-get install -y maven=3.6.0-1~18.04.1 \
 && wget https://services.gradle.org/distributions/gradle-5.5-bin.zip -P /tmp \
 && unzip -d /opt/gradle /tmp/gradle-*.zip \
 && rm -rf /tmp/gradle-*.zip

# Python
RUN apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget \
 && apt-get install -y software-properties-common \
 && apt-get update \
 && wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz \
 && tar -xf Python-3.7.3.tar.xz \
 && cd Python-3.7.3  \
 && ./configure --enable-optimizations \
 && make install \
 && apt-get install -y python-pip python3-pip \
 && pip install --upgrade pip==19.1.1 \
 && pip3 install --upgrade pip==19.1.1

#IBM Cloud CLI
RUN curl -sL https://ibm.biz/idt-installer | bash \
 && ibmcloud plugin install doi


# Sonar
RUN curl --insecure -o ./sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip \
 && unzip sonarscanner.zip \
 && rm sonarscanner.zip \
 && mv sonar-scanner-3.2.0.1227-linux /usr/lib/sonar-scanner \
 && ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# pip install bifrost
RUN pip install --extra-index-url https://kranthi.kumar.sara@ibm.com:${AF_PSW}@na.artifactory.swg-devops.com/artifactory/api/pypi/txo-cedp-garage-pypi-local/simple ibm-bifrost==0.3.14

VOLUME /var/run/docker.sock

# Install 1Password
RUN wget https://cache.agilebits.com/dist/1P/op/pkg/v0.6.2/op_linux_amd64_v0.6.2.zip -P /tmp \
 && unzip -d /usr/local/bin /tmp/op_linux_amd64_*.zip \
 && rm -rf /tmp/op_linux_amd64_*.zip \
 && op --version

RUN echo $PATH \
 && java -version \
 && python --version \
 && pip --version \
 && python3 --version \
 && sonar-scanner --version
