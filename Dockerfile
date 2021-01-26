FROM sigcorp/tomcat:8.5.61-5

COPY webapps/*.war /usr/local/tomcat/webapps/

ENV ojdbc_ver=19.3.0.0 \
    ojdbc_url=https://repo1.maven.org/maven2/com/oracle/database \
    tomcat_lib=/usr/local/tomcat/lib

ADD ${ojdbc_url}/jdbc/ojdbc8/${ojdbc_ver}/ojdbc8-${ojdbc_ver}.jar ${tomcat_lib}/ojdbc8.jar
ADD ${ojdbc_url}/xml/xdb/${ojdbc_ver}/xdb-${ojdbc_ver}.jar ${tomcat_lib}/xdb.jar
ADD ${ojdbc_url}/jdbc/ucp/${ojdbc_ver}/ucp-${ojdbc_ver}.jar ${tomcat_lib}/ucp.jar

SHELL ["/bin/bash", "-c"]
RUN cd /usr/local/tomcat/webapps && \
    for F in *.war; do N=$(basename $F .war); echo "Expanding $N ..."; mkdir $N; pushd $N; unzip ../$F; popd; rm -f $F; done

COPY overlay/ /

EXPOSE 8080
CMD /run.sh
