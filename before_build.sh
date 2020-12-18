#!/bin/bash

#
# die <message>
# Print an error message and exit with error status
#
die () {
    echo "ERROR: $*"
    exit 1
}

#
# require <var>
# Throw an error if the specified VAR isn't set
#
require () {
    [ -z "${!1}" ] && die "Missing: ${1} - Define ${1} as an environment variable for this run in the CodeBuild interface"
}

require APP_NAME
require APP_VER

echo "before_build.sh checks passed"
exit 0
