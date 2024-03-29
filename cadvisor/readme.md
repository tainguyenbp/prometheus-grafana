```
docker run -d --restart always --name cadvisor \
-p 9999:8080 -v "/:/rootfs:ro" -v "/var/run:/var/run:rw" -v "/sys:/sys:ro" \
-v "/var/lib/docker/:/var/lib/docker:ro" gcr.io/cadvisor/cadvisor:v0.49.1
```
