#!/usr/bin/env bash

set -e

function runCommand {
    echo
    echo "$1"
    echo
    sleep 2
    eval $1
    echo
}

sleep 2
echo "+++ Create Expectation"
curl -v -s -X PUT http://$MOCKSERVER_HOST/expectation -d '[
    {
        "httpRequest": {
            "path": "/not_simple"
        },
        "httpResponse": {
            "statusCode": 200,
            "body": "some not simple response"
        },
        "times": {
            "unlimited": true
        }
    },
    {
        "httpRequest": {
            "method": "POST",
            "path": "/simple"
        },
        "httpResponse": {
            "statusCode": 200,
            "body": "some simple POST response"
        },
        "times": {
            "unlimited": true
        }
    },
    {
        "httpRequest": {
            "path": "/simple"
        },
        "httpResponse": {
            "statusCode": 200,
            "body": "some simple response"
        },
        "times": {
            "unlimited": true
        }
    }
]'

echo "+++ JVM warm up"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=10c_noTLS -c 10 -r 10 -n 100 --host=http://$MOCKSERVER_HOST"

echo "+++ HTTP"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=1c_noTLS -c 1 -r 1 -n 10 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=10c_noTLS -c 10 -r 10 -n 100 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=100c_noTLS -c 100 -r 100 -n 1000 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=200c_noTLS -c 200 -r 200 -n 20000 --host=http://$MOCKSERVER_HOST"

echo "+++ HTTPS"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=1c_TLS -c 1 -r 1 -n 10 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=10c_TLS -c 10 -r 10 -n 100 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=100c_TLS -c 100 -r 100 -n 1000 --host=http://$MOCKSERVER_HOST"
runCommand "locust --loglevel=INFO --no-web --only-summary --csv=200c_TLS -c 200 -r 200 -n 20000 --host=http://$MOCKSERVER_HOST"


