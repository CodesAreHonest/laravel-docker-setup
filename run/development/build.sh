#!/bin/sh

docker build -t ezysupport:2.0 .
docker run --name ezysupport -d ezysupport:2.0
docker exec -it ezysupport /bin/bash