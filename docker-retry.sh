#!/bin/bash

NAP=5
CMD="docker $*"

while true; do
    echo "Running: $CMD"
    $CMD 2>&1 |tee .docker-retry.tmp
    RET=${PIPESTATUS[0]}
    echo "Finished with $RET"
    if [ $RET -eq 1 ] && grep -q '^toomanyrequests:' .docker-retry.tmp; then
        echo "Docker failed with rate limit error, retrying in $NAP seconds"
    else
        break
    fi      
    sleep $NAP
done
