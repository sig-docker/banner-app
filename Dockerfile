FROM sigcorp/banner-tomcat:8.5.56-1.1
# FROM banner-tomcat:latest

COPY webapps/*.war /usr/local/tomcat/webapps/

SHELL ["/bin/bash", "-c"]
RUN cd /usr/local/tomcat/webapps && \
    for F in *.war; do N=$(basename $F .war); echo "Expanding $N ..."; mkdir $N; pushd $N; unzip ../$F; popd; rm -f $F; done

EXPOSE 8080
CMD /run.sh
