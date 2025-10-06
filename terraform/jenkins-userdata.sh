#!/bin/bash

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Java 11
yum install -y java-11-amazon-corretto

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins
systemctl start jenkins
systemctl enable jenkins

# Add jenkins user to docker group
usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install -y unzip
unzip awscliv2.zip
./aws/install

# Install Maven
cd /opt
wget https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz
tar xzf apache-maven-3.8.1-bin.tar.gz
ln -s apache-maven-3.8.1 maven
echo 'export PATH=/opt/maven/bin:$PATH' > /etc/profile.d/maven.sh
chmod +x /etc/profile.d/maven.sh

# Install Git
yum install -y git

# Install Ansible
amazon-linux-extras install -y ansible2

# Configure AWS CLI for Jenkins user
mkdir -p /var/lib/jenkins/.aws
cat > /var/lib/jenkins/.aws/config << EOF
[default]
region = ${region}
output = json
EOF

# Set ownership
chown -R jenkins:jenkins /var/lib/jenkins/.aws

# Restart Jenkins to pick up new environment
systemctl restart jenkins

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create Jenkins initial setup directory
mkdir -p /var/lib/jenkins/init.groovy.d

# Disable Jenkins setup wizard (for automation)
echo 'jenkins.install.runSetupWizard=false' >> /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion

# Restart services
systemctl restart docker
systemctl restart jenkins

# Output Jenkins initial admin password location
echo "Jenkins initial admin password can be found at: /var/lib/jenkins/secrets/initialAdminPassword"