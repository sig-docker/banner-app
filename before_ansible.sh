# Add default values for TOMCAT_EXTRA_ARGS
echo "$TOMCAT_EXTRA_ARGS" | grep -q '\-Dbanner.logging.dir=' || export TOMCAT_EXTRA_ARGS="$TOMCAT_EXTRA_ARGS -Dbanner.logging.dir=/app_logs"
echo "$TOMCAT_EXTRA_ARGS" | grep -q '\-Doracle.jdbc.autoCommitSpecCompliant=' || export TOMCAT_EXTRA_ARGS="$TOMCAT_EXTRA_ARGS -Doracle.jdbc.autoCommitSpecCompliant=false"
