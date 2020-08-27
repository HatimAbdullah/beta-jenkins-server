#!/bin/bash
curl -Ls get.docker.com | sh
sudo usermod -aG docker ubuntu
cd /home/ubuntu
mkdir jenkins_home
chmod a+rwx jenkins_home
sudo touch /etc/systemd/system/jenkins.service
sudo chmod a+rw /etc/systemd/system/jenkins.service
sudo docker pull jenkinsci/blueocean
cat <<EOF > /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins BlueOcean
After=docker.service

[Service]
Type=simple
ExecStart=sudo docker container run -d --name jenkins -p 80:8080 --restart=always -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /run/docker.sock:/run/docker.sock jenkinsci/blueocean

[Install]
WantedBy=multi-user.target
EOF
sudo chmod a-w /etc/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo chmod a+rw /run/docker.sock
