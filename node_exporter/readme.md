```
docker run -d --restart always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  --name node_exporter \
  quay.io/prometheus/node-exporter:v1.8.2 \
  --path.rootfs=/host
```
