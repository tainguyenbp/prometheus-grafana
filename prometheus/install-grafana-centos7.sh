
#!/bin/bash
yum install -y wget

cat << EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

sudo yum install grafana

yum install fontconfig
yum install freetype*
yum install urw-fonts

grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins install camptocamp-prometheus-alertmanager-datasource

firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload

systemctl start grafana-server
systemctl enable grafana-server.service


