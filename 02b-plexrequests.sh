#!/bin/bash
source vars

## INFO
# This script installs plexrequests
##

#######################
# Install
#######################
exec sudo -i -u $username /bin/bash - << eof
curl "https://install.meteor.com/?release=1.2.1" | sh
sudo git clone https://github.com/lokenx/plexrequests-meteor.git /opt/plexrequests/
sudo chown -R $username:$username /opt/plexrequests
cd /opt/plexrequests
meteor &
PID=$!
sleep 10m
kill $PID
eof

#######################
# Systemd Service File
#######################
tee "/etc/systemd/system/plexrequest.service" > /dev/null <<EOF
[Unit]
Description=PlexRequest
After=plexmediaserver.service

[Service]
User=$username
Type=simple
WorkingDirectory=/opt/plexrequests
ExecStart=/usr/local/bin/meteor
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#######################
# Autostart
#######################
systemctl daemon-reload
systemctl start plexrequest
systemctl enable plexrequest

#######################
# Remote Access
#######################
echo ''
echo "Do you want to allow remote access to PlexRequests?"
echo "If so, you need to tell UFW to open the port."
echo "Otherwise, you can use SSH port forwarding."
echo ''
echo "Would you like us to open the port in UFW?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) ufw allow 3000; echo ''; echo "Port 3000 open, PlexRequests is now available over the internet."; echo ''; break;;
        No ) echo "Port 3000 left closed. You can still access it on your local machine by issuing the following command: ssh $username@$ipaddr -L 3000:localhost:3000"; echo "and then open localhost:3000 on your browser."; exit;;
    esac
done
