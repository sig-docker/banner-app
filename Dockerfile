FROM sigcorp/tomcat:latest-8-jdk8

ENV ojdbc_ver=19.10.0.0 \
    ojdbc_url=https://repo1.maven.org/maven2/com/oracle/database \
    tomcat_lib=/usr/local/tomcat/lib

RUN apt-get update -y \
 && apt-get install -y gettext-base unzip \
 && apt-get clean autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

ADD ${ojdbc_url}/jdbc/ojdbc8/${ojdbc_ver}/ojdbc8-${ojdbc_ver}.jar ${tomcat_lib}/ojdbc8.jar
ADD ${ojdbc_url}/xml/xdb/${ojdbc_ver}/xdb-${ojdbc_ver}.jar ${tomcat_lib}/xdb.jar
ADD ${ojdbc_url}/jdbc/ucp/${ojdbc_ver}/ucp-${ojdbc_ver}.jar ${tomcat_lib}/ucp.jar
ADD https://github.com/sigdba/groovy-conf-updater/releases/download/r5/groovy-conf-updater-r5.jar /opt/groovy-conf-updater.jar

COPY webapps/*.war /usr/local/tomcat/webapps/
COPY ansible/ /ansible/
COPY before_ansible.sh /run.d/banner.sh
COPY after_ansible.sh /run.after_ansible/banner.sh
COPY parse_banner_env.py /

SHELL ["/bin/bash", "-c"]
RUN cd /usr/local/tomcat/webapps && \
    for F in *.war; do N=$(basename $F .war); echo "Expanding $N ..."; mkdir $N; pushd $N; unzip ../$F; popd; rm -f $F; done

COPY overlay/ /

EXPOSE 8080
CMD /run.sh
