#!/bin/bash

curl -X POST http://localhost:9090/-/reload

sudo docker logs prometheus --tail=15

echo "the service reload is sucessfully"
