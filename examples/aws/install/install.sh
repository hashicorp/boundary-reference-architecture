# Installs the boundary as a service for systemd on linux
TYPE=$1
NAME=boundary

sudo cat << EOF > /etc/systemd/system/${NAME}-${TYPE}.service
[Unit]
Description=${NAME} ${TYPE}

[Service]
ExecStart=/usr/local/bin/${NAME} ${TYPE} -config /etc/${NAME}-${TYPE}.hcl
User=boundary
Group=boundary

[Install]
WantedBy=multi-user.target
EOF

sudo groupadd boundary
sudo adduser -S -G boundary boundary
sudo chown boundary:boundary /etc/${NAME-${TYPE}.hcl
sudo chown boundary:boundary /usr/local/bin/boundary

# Make sure to initialize the DB before starting the service. This will result in
# a database already initizalized warning if another controller or worker has done this 
# already, making it a lazy, best effort initialization
if [ $TYPE = "controller" ]; then
  sudo /usr/local/bin/boundary database init -config /etc/${NAME}-${TYPE}.hcl || true
fi

sudo chmod 664 /etc/systemd/system/$NAME-$TYPE.service
sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
sudo systemctl start ${NAME}-${TYPE}
