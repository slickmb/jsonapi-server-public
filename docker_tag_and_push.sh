#!/bin/sh -e

if [ $# != 4 ]; then
    echo "usage: $0 <reponame> <hostname> <username> <password>"
    exit 1
fi

REPONAME=$1
REPOHOST=$2
REPOUSER=$3
REPOPW=$4
FULLNAME=$REPOHOST/$REPONAME
TAG_NAME=$(docker run --rm --entrypoint '/bin/bash' $REPONAME -c "rpm -qa --qf '%{VERSION}\n' $REPONAME | tr '+' '_'")

docker tag $REPONAME:latest $FULLNAME:latest
docker tag $REPONAME:latest $FULLNAME:$TAG_NAME
docker login -e dev@expel.io -u $REPOUSER -p $REPOPW $REPOHOST
docker push $FULLNAME
