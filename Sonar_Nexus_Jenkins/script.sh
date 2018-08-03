	#Jenkins and nginx
yum install nginx git unzip java -y
sed -i '38, 57d' /etc/nginx/nginx.conf

cat > /etc/systemd/system/jenkins.service <<EOF
[Unit]
Description=Jenkins Daemon
[Service]
ExecStart=/usr/bin/java -DJENKINS_HOME=/opt/jenkins/conf/bin -jar /opt/jenkins/bin/jenkins.war 
ExecStop=kill ps -ef | grep [j]enkins.war | awk '{ print $2 }'
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/sonar.service <<EOF
[Unit]
Description=Sonar 4
After=network.target network-online.target
Wants=network-online.target
[Service]
ExecStart=/opt/sonar/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonar/bin/linux-x86-64/sonar.sh stop
ExecReload=/opt/sonar/bin/linux-x86-64/sonar.sh restart
PIDFile=/opt/sonar/bin/linux-x86-64/./SonarQube.pid
Type=forking
User=vagrant
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
ExecStart=/opt/nexus-3.13.0-01/bin/nexus start
ExecStop=/opt/nexus-3.13.0-01/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/nginx/conf.d/jenk_son.conf <<EOF
server {
listen       80 default_server;
location / {
proxy_pass http://127.0.0.1:8080;
        }
    }
server {
listen       80;
server_name  sonar;
location / {
proxy_pass http://192.168.1.2:9000;
       }
    }
server {
listen       80;
server_name  nexus;
location / {
      proxy_pass http://localhost:8081/;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
       }
    }
EOF

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
systemctl enable nginx
systemctl start nginx

#Install Postgresql
sudo yum install postgresql-server postgresql-contrib -y
systemctl enable postgresql
systemctl start postgresql
postgresql-setup initdb
echo "postgres:postgres" | chpasswd
systemctl restart postgresql
sudo -u postgres psql -c "create user sonar;"
sudo -u postgres psql -c "alter role sonar with createdb;"
sudo -u postgres psql -c "alter user sonar with encrypted password 'sonar';"
sudo -u postgres psql -c "create database sonar owner sonar;"
sudo -u postgres psql -c "grant all privileges on database sonar to sonar;"
sed -i -e 's/\(^host.*all.*\)\(ident\)\(.*\)/\1md5\3/' /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql

#Install Sonarqube
if [ ! -f /opt/sonarqube-5.6.6.zip ]
then
	cd /opt
	wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.7.4.zip
	unzip sonarqube-6.7.4.zip
	mv sonarqube-6.7.4 sonar
	chown -R vagrant sonar
	rm -rf sonarqube-6.7.4.zip
fi

sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonar/conf/sonar.properties
sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonar/conf/sonar.properties
sed -i 's/#sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonar/sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonar/' /opt/sonar/conf/sonar.properties
systemctl start sonar


#Install Nexus
if [ ! -f /opt/latest-unix.tar.gz ]
then
	wget http://download.sonatype.com/nexus/3/latest-unix.tar.gz
	tar xvf latest-unix.tar.gz -C /opt
	sudo useradd nexus
	sudo chown -R nexus:nexus /opt/nexus-3.13.0-01/
	sudo chown -R nexus:nexus /opt/sonatype-work/
	sed -i 's/#run_as_user=""/run_as_user="nexus"/' /opt/nexus-3.13.0-01/bin/nexus.rc

fi
	
systemctl start nexus



