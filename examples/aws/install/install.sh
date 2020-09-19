# Installs the boundary as a service for systemd on linux
TYPE=$1
NAME=boundary

sudo cat << EOF > /etc/systemd/system/${NAME}-${TYPE}.service
[Unit]
Description=${NAME} ${TYPE}

[Service]
ExecStart=/usr/local/bin/${NAME} ${TYPE} -config /etc/${NAME}-${TYPE}.hcl

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 664 /etc/systemd/system/$NAME-$TYPE.service
sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
sudo systemctl start ${NAME}-${TYPE}
