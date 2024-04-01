# Backup and Restore Prometheus without Admin API

```
http://your-prometheus-url/api/v1/snapshot?start=<start_time>&end=<end_time>
curl -XPOST  http://127.0.0.1:9090/api/v1/snapshot?start=1744219200&end=1744251000

curl -XPOST  http://127.0.0.1:9090/api/v1/admin/tsdb/snapshot?start=1744219200&end=1744251000


curl -XPOST  http://127.0.0.1:9090/api/v2/admin/tsdb/snapshot?start=1744219200&end=1744251000

curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot?skip_head=true

rsync -avrP prometheus-rsync.NAMESPACE.svc.cluster.local::data/snapshots/ /opt/bitnami/prometheus/data/



```
