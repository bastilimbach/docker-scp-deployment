FROM node:carbon

ENV NEO_SDK_VERSION 3.45.9.1
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Update & install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    software-properties-common

# Install Java
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" \
    && apt-get update \
    && apt-get install -y oracle-java8-installer \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/oracle-jdk8-installer

# Install SAP Neo Java Web SDK
RUN curl -o /opt/neo-java-web-sdk.zip http://central.maven.org/maven2/com/sap/cloud/neo-java-web-sdk/${NEO_SDK_VERSION}/neo-java-web-sdk-${NEO_SDK_VERSION}.zip \
    && unzip /opt/neo-java-web-sdk.zip -d /opt/neo-java-web-sdk \
    && rm /opt/neo-java-web-sdk.zip

# Install Grunt
RUN yarn global add grunt-cli

# Install SAP MTA Builder
COPY mta_builder.jar /opt/mta/builder.jar

COPY bin/. /usr/local/bin
RUN chmod +x /usr/local/bin/neo \
    && chmod +x /usr/local/bin/mta-builder

WORKDIR /usr/src/app

CMD ["node"]
