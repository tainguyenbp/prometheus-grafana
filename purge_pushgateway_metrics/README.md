#prometheus-and-grafana
how to deloy monitor calls asterisk with prometheus and grafana use exporter


# purge metrics old pushgateway
### setup server pushgateway
```
git clone https://github.com/tainguyenbp/prometheus-grafana

cd prometheus-grafana/purge_pushgateway_metrics

docker build -t tainguyenbp/delete_pushgateway_metrics:v1.1.1 .

docker-compose up -d

```
### test push metrics pushgateway
```
cd prometheus-grafana/purge_pushgateway_metrics

bash pushgateway_test_metrics.sh
```
