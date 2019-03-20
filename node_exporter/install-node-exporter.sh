useradd -M node_exporter

usermod -L node_exporter


chown -R node_exporter:node_exporter /etc/node_exporter

chown -R node_exporter:node_exporter /etc/node_exporter/node_exporter
