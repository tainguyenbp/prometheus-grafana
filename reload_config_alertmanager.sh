#!/bin/bash

curl -X POST http://localhost:9093/-/reload

curl -X POST http://127.0.0.1:9093/-/reload

docker logs alertmanager --tail=15

echo "The service reload config alertmanager is sucessfully"
