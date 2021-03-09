#!/bin/bash

check_operating_system () {
        [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
        [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
        [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

install_node_exporter_centos_7 () {
yum install -y wget

export version_node_exporter='1.1.1'
export arch_node_exporter='linux-amd64'

useradd --no-create-home --shell /bin/false node_exporter

wget "https://github.com/prometheus/node_exporter/releases/download/v$version_node_exporter/node_exporter-$version_node_exporter.$arch_node_exporter.tar.gz" -O /etc/node_exporter.tar.gz

tar -xzvf /etc/node_exporter.tar.gz -C /etc/

mv "/etc/node_exporter-$version_node_exporter.$arch_node_exporter" /etc/node_exporter

chown -R node_exporter:node_exporter /etc/node_exporter

chmod +x /etc/node_exporter/node_exporter

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter Metrics Monitors
Wants=network-online.target
After=network-online.target

[Service]

Type=simple

User=node_exporter
Group=node_exporter

ExecStart=/etc/node_exporter/node_exporter \
    --collector.loadavg \
    --collector.meminfo \
    --collector.filesystem \
    --collector.systemd

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/node_exporter.service

systemctl enable node_exporter.service

systemctl start node_exporter.service

systemctl status node_exporter.service

rm -rf /etc/node_exporter.tar.gz

}

operating_system=`check_operating_system`

if [ -f /etc/os-release ] 
then
     operating_system_version=`awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release`
fi

if [[ $os_name == *"Ubuntu"* ]]; then
    echo "======================================"
    echo $os_name $os_version
    if [[ "$os_version" = "bionic" ]]; then
        url=$u18_url
        update_debian
    elif [[ $os_version = "xenial" ]]; then
        url=$u16_url
        update_debian
    elif [[ $os_version = "focal" ]]; then
        url=$u20_url
        update_debian
    else
        echo "$os_verion khong duoc support"
    fi
elif [[ $os_name == *"CentOS"* ]]; then
    echo "======================================"
    echo $os_name
    if [[ $os_name == *"CentOS 6"* ]]; then
        install_node_exporter_centos_6
    elif [[ $os_name == *"CentOS 7"* ]]; then
        install_node_exporter_centos_7
    elif [[ $os_name == *"CentOS 8"* ]]; then
        install_node_exporter_centos_8
    else
        echo "$os_name $os_version khong duoc support"
    fi
elif [[ $os_name == *"Debian"* ]]; then
    echo "======================================"
    echo $os_name $os_version
    dpkg -l | grep sudo
    echo "======================================"
    if [[ $os_version = "stretch" ]]; then
        url=$deb9_url
        update_debian
    elif [[ $os_version = "buster" ]]; then
        url=$deb10_url
        update_debian
    else
        echo "$os_verion khong duoc support"
    fi
else
   echo "$os_name $os_verion  khong duoc support"
fi

