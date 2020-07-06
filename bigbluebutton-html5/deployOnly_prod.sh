BBB_SERVER="bbb.bina.bigbluemeeting.com"

echo "Copy archive to ${BBB_SERVER}"
scp source.tar.gz root@${BBB_SERVER}:/root/source.tar.gz

echo "Stop existing bbb-html5 service, untar archive and start the service again"

ssh root@${BBB_SERVER} << EOF
  systemctl stop bbb-html5
  tar -xvzf /root/source.tar.gz -C /usr/share/meteor
  systemctl start bbb-html5
  systemctl status bbb-html5
EOF
