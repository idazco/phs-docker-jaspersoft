FROM tomcat:7

ENV JASPER_REPORTS_SERVER_VERSION=6.3.0

# Install JDK and set JAVA_HOME to prepare for js-ant build
RUN apt-get update && apt-get install -y -q --no-install-recommends \
     openjdk-7-jdk \
     && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
ENV JASPER_SRC=/usr/src/jasperreports-server-cp-${JASPER_REPORTS_SERVER_VERSION}-bin

# TODO: Allow using different db backends for open source
COPY root/ /

# Install JDK7 postgresql jdbc driver
RUN mkdir -p ${JASPER_SRC}/buildomatic/conf_source/db/postgresql/jdbc/ && \
    curl -SL https://jdbc.postgresql.org/download/postgresql-9.4.1212.jre7.jar -o ${JASPER_SRC}/buildomatic/conf_source/db/postgresql/jdbc/postgresql-9.4.1212.jre7.jar

# Download zip file and decompress into /usr/src
# TODO: Allow changing version, but keep in mind the .properties file is related to the version
# Only build the webapp part, the DB should be done separately before running container using db-initialization.sh
# (see README)
RUN \
    curl -SL http://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20Edition%20${JASPER_REPORTS_SERVER_VERSION}/jasperreports-server-cp-${JASPER_REPORTS_SERVER_VERSION}-bin.zip -o /tmp/jasperserver.zip && \
    unzip -n /tmp/jasperserver.zip -d /usr/src/ && \
    rm -rf /tmp/* && \
    cd ${JASPER_SRC}/buildomatic && \
    ./js-ant deploy-webapp-ce

# Cleanup tomcat stuff to only have jasperreports server at root
RUN rm -rf ${CATALINA_HOME}/webapps/ROOT && \
  rm -rf ${CATALINA_HOME}/webapps/docs && \
  rm -rf ${CATALINA_HOME}/webapps/examples && \
  rm -rf ${CATALINA_HOME}/webapps/host-manager && \
  rm -rf ${CATALINA_HOME}/webapps/manager && \
  mv ${CATALINA_HOME}/webapps/jasperserver ${CATALINA_HOME}/webapps/ROOT && \
  sed -i "s/jasperserver\.root/ROOT.root/g" ${CATALINA_HOME}/webapps/ROOT/WEB-INF/web.xml && \
  sed -i "s/jasperserver\.root/ROOT.root/g" ${CATALINA_HOME}/webapps/ROOT/WEB-INF/log4j.properties

# Use an entrypoint to do env var to DB setting translation
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["catalina.sh", "run"]
