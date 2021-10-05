# Hadolint image
FROM hadolint/hadolint:v1.17.6-9-g550ee0d-debian as hadolint-image

FROM ubuntu:18.04

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y software-properties-common unzip wget curl gnupg git apt-utils jq locales \
 gcc libsasl2-dev python-dev libldap2-dev libssl-dev libcap2-bin libcap2

# Java SBT Maven Gradle
ENV PATH="/opt/gradle/gradle-5.5/bin:${PATH}"
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list \
 && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list \
 && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add \
 && apt-get update \
 && apt-get install -y openjdk-8-jdk \
 && apt-get install -y openjdk-11-jdk \
 && apt-get install -y sbt=1.2.8 \
 && apt-get install -y maven=3.6.0-1~18.04.1 \
 && wget https://services.gradle.org/distributions/gradle-5.5-bin.zip -P /tmp \
 && unzip -d /opt/gradle /tmp/gradle-*.zip \
 && rm -rf /tmp/gradle-*.zip

# Python
RUN apt-get install -y python \
 && apt-get install -y python3.6 \
 && apt-get install -y python3-distutils \
 && apt-get install -y python-pip python3-pip \
 && pip install --upgrade pip==19.0.1 \
 && pip3 install --upgrade pip==19.0.1


ENV DEBIAN_FRONTEND=noninteractive
RUN pip3 install coverage pytest pylint virtualenv

RUN pip3 install ansible kubernetes-validate openshift \
 && ansible-galaxy collection install community.kubernetes

# Install PyEnv and default python versions
RUN curl https://pyenv.run | bash \
 && ln -s /root/.pyenv/bin/pyenv /usr/bin/pyenv

RUN apt-get install -y make build-essential libssl1.0-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl

RUN pyenv install 2.7.16
RUN pyenv install 3.5.7
RUN pyenv install 3.6.9
RUN pyenv install 3.7.4

# Install Node
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && . ${NVM_DIR}/nvm.sh \
 && nvm install --lts=dubnium \
 && nvm install --lts=erbium \
 && nvm install --lts=fermium \
 && nvm alias default 'stable' \
 && nvm alias '10' 'lts/dubnium' \
 && nvm alias '12' 'lts/erbium' \
 && nvm alias '14' 'lts/fermium' \
 && nvm ls \
 && nvm use '14' \
 && node -v \
 && npm -v

# ESLint
RUN . ${NVM_DIR}/nvm.sh \
 && npm config set user 0 \
 && npm config set unsafe-perm true \
 && npm i -g eslint prettier@latest eslint-plugin-react@latest babel-eslint@latest eslint-plugin-prettier@latest \
                    eslint-plugin-react-hooks eslint-config-airbnb eslint-plugin-import eslint-plugin-jsx-a11y \
                    npm-cli-login \
 && eslint --version \
 && npm config set unsafe-perm false

# Install Go
ENV GOOS=linux
ENV GOARCH=amd64
ENV GOROOT="/usr/local/go"
ENV PATH="${GOROOT}/bin:${PATH}"
RUN cd /opt \
&& wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz \
&& tar -xvf go1.15.2.linux-amd64.tar.gz  \
&& mv go /usr/local \
&& go get -u golang.org/x/lint/golint \
&& mv /root/go/bin/golint /usr/local/go/bin \
&& golint

# Install 1Password
RUN wget https://cache.agilebits.com/dist/1P/op/pkg/v0.9.4/op_linux_amd64_v0.9.4.zip -P /tmp \
 && unzip -d /usr/local/bin /tmp/op_linux_amd64_*.zip \
 && rm -rf /tmp/op_linux_amd64_*.zip \
 && op --version

# Install SonarQube Scanner
ENV PATH="/opt/sonar-scanner-cli/sonar-scanner-4.2.0.1873-linux/bin:${PATH}"
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip -P /tmp \
 && unzip -d /opt/sonar-scanner-cli /tmp/sonar-scanner-cli*.zip \
 && rm -rf /tmp/sonar-scanner-cli*.zip \
 && sonar-scanner --version

# Helm 3
ENV DESIRED_VERSION=v3.1.2
# IBM Cloud CLI
RUN curl -sL https://ibm.biz/idt-installer | bash \
 && ibmcloud plugin install doi

# Helm 3
RUN wget https://get.helm.sh/helm-v3.1.2-linux-amd64.tar.gz -P /tmp \
 && tar -zxvf /tmp/helm-v3.1.2-linux-amd64.tar.gz \
 && mv linux-amd64/helm /usr/local/bin/helm

COPY cloudctl /usr/local/bin/cloudctl

# JFrog cli
COPY jfrog /usr/local/bin/jfrog

# Hadolint
COPY --from=hadolint-image /bin/hadolint /usr/local/bin/hadolint

#Openshift CLI
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.4/linux/oc.tar.gz \
 && tar -zxvf oc.tar.gz \
 && mv oc /usr/bin

#Buildah
RUN echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
 && wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_18.04/Release.key -O Release.key \
 && apt-key add - < Release.key \
 && apt-get update -qq \
 && apt-get -qq -y install buildah

# Chromium and Firefox
RUN apt-get install -y chromium-browser \
 && apt-get install -y firefox \
 && apt-get install -y shellcheck

# Dependency check
RUN cd /opt \
 && mkdir /opt/dependency-check \
 && wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.2.2/dependency-check-6.2.2-release.zip \
 && unzip dependency-check-6.2.2-release.zip -d . \
 && ln -s /opt/dependency-check/bin/dependency-check.sh /usr/bin/dependency-check

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Validate
RUN echo $PATH \
 && java -version \
 && mvn -version \
 && gradle -version \
# && sbt sbtVersion \
 && python --version \
 && pip --version \
 && python3 --version \
 && pip3 --version \
 && virtualenv --version \
 && pyenv --version \
 && ibmcloud --version \
 && ibmcloud plugin list \
 && ibmcloud config --check-version=false \
 && jq --version \
 && kubectl version --client=true \
 && helm version -c \
 && cloudctl version \
 && jfrog --version \
 && hadolint --version \
 && dependency-check -v \
 && oc version --client=true \
 && go version
