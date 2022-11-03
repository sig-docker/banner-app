cd /ansible

require () {
    [ -z "${!1}" ] && die "Missing required environment variable: ${1}"
}

if [ "$SAML_ENABLE" == "true" ]; then
    echo "SAML is enabled."

    export SAML_BASE_DIR=/opt/saml
    export SAML_KEYSTORE=$SAML_BASE_DIR/samlKeystore.jks
    export SAML_SIGNING_CERT=$SAML_BASE_DIR/saml-signing.crt

    require SAML_APP_BASE_URL
    require SAML_APP_ID
    require SAML_ENTITY_ID
    require SAML_KEYSTORE_B64
    require SAML_KEYSTORE_PASS
    # require SAML_SP_CERTIFICATE
    require SAML_IDP_METADATA_URL
    require SAML_ACS_URL

    [ -z "$SAML_KEYSTORE_ALIAS" ] && export SAML_KEYSTORE_ALIAS="samlsigning"

    mkdir -p $SAML_BASE_DIR || die "Error creating $SAML_BASE_DIR"

    echo "$SAML_KEYSTORE_B64" |base64 -d >$SAML_KEYSTORE
    keytool -export -alias $SAML_KEYSTORE_ALIAS -keystore $SAML_KEYSTORE \
        -rfc -file $SAML_SIGNING_CERT -storepass "$SAML_KEYSTORE_PASS" || die "keytool error"
    export SAML_SP_CERTIFICATE=$(cat $SAML_SIGNING_CERT | tail -n +2 | head -n -1)

    cat >/ansible/group_vars/all/banner-app.yml <<EOF
saml_base_dir: $SAML_BASE_DIR
saml_app_base_url: $SAML_APP_BASE_URL
saml_app_id: $SAML_APP_ID
saml_entity_id: $SAML_ENTITY_ID
saml_sp_certificate: "$SAML_SP_CERTIFICATE"
saml_idp_metadata_url: $SAML_IDP_METADATA_URL
saml_acs_url: $SAML_ACS_URL
EOF

    ansible-playbook banner-app-playbook.yml -i inventory.ini || die "ansible error"

    SP_META="$SAML_BASE_DIR/SP-Metadata.xml"
    echo "--------------------------------------------------------------------------------"
    echo "$SP_META"
    echo "--------------------------------------------------------------------------------"
    cat $SP_META
    echo "--------------------------------------------------------------------------------"
fi

python3 /parse_banner_env.py |envsubst >/opt/groovy_updates

if [ -n "$DEBUG_GROOVY_CONF" ]; then
    echo "--------------------------------------------------------------------------------"
    echo "Groovy Updates"
    echo "--------------------------------------------------------------------------------"
    cat /opt/groovy_updates
    echo "--------------------------------------------------------------------------------"
fi

if env |grep -q "^GROOVY_CONF_"; then
    for F in /usr/local/tomcat/webapps/*/WEB-INF/classes/[A-Z]*_configuration.groovy; do
        new_groove="${F}_updated"
        echo "--------------------------------------------------------------------------------"
        echo "Updating $F"
        echo "--------------------------------------------------------------------------------"
        cat /opt/groovy_updates |java -jar /opt/groovy-conf-updater.jar $F >$new_groove
        # TODO: Die if the above fails
        echo "--------------------------------------------------------------------------------"
        mv -f $new_groove $F || die "Error replacing $F"
    done
fi
