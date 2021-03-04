#!/bin/bash
yum install -y wget

export version_prometheus='2.25.0'
export arch_prometheus='linux-amd64'

#mkdir -p /etc/prometheus/
useradd --no-create-home --shell /bin/false prometheus

wget "https://github.com/prometheus/prometheus/releases/download/v$version_prometheus/prometheus-$version_prometheus.$arch_prometheus.tar.gz" -O /etc/prometheus.tar.gz
tar -xzvf /etc/prometheus.tar.gz -C /etc/
#tar -xzvf /etc/prometheus/prometheus.tar.gz -C /etc/prometheus/

mv "/etc/prometheus-$version_prometheus.$arch_prometheus" /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus

chmod +x /etc/prometheus/prometheus

cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Wants=network-online.target
After=network-online.target

[Service]

Type=simple

User=prometheus
Group=prometheus

ExecStart=/etc/prometheus/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/etc/prometheus/data/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.external-url=http://192.168.10.10:9090 \
    --web.enable-admin-api \
    --web.enable-lifecycle \
    --storage.tsdb.retention.time=120d \
    --log.level=debug

[Install]
WantedBy=multi-user.target

EOF

chmod +x /etc/systemd/system/prometheus.service

systemctl enable prometheus.service

systemctl start prometheus.service

systemctl status prometheus.service

rm -rf /etc/prometheus.tar.gz
