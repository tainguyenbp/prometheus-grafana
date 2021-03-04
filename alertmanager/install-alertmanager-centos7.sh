#!/bin/bash
yum install -y wget

export version_alertmanager='0.21.0'
export arch_alertmanager='linux-amd64'


useradd --no-create-home --shell /bin/false alertmanager

wget "https://github.com/prometheus/alertmanager/releases/download/v$version_alertmanager/alertmanager-$version_alertmanager.$arch_alertmanager.tar.gz" -O /etc/alertmanager.tar.gz

tar -xzvf /etc/alertmanager.tar.gz -C /etc/

mv "/etc/alertmanager-$version_alertmanager.$arch_alertmanager" /etc/alertmanager

chown -R alertmanager:alertmanager /etc/alertmanager

chmod +x /etc/alertmanager/alertmanager

cat << EOF > /etc/systemd/system/alertmanager.service
[Unit]
Description=alertmanager Server
Wants=network-online.target
After=network-online.target

[Service]

Type=simple

User=alertmanager
Group=alertmanager

ExecStart=/etc/alertmanager/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/etc/alertmanager/data/ --data.retention=120h --web.listen-address=0.0.0.0:9093 --log.level=debug

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/alertmanager.service

systemctl enable alertmanager.service

systemctl start alertmanager.service

systemctl status alertmanager.service

rm -rf /etc/alertmanager.tar.gz
