#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

VALIDATE(){
   if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"
        exit 1
   else
        echo -e "$2...$G SUCCESS $N"
   fi
}

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi

# Docker Installation
yum install -y yum-utils >>$LOGFILE 2>&1
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >>$LOGFILE 2>&1
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >>$LOGFILE 2>&1
systemctl enable --now docker >>$LOGFILE 2>&1
usermod -aG docker ec2-user
VALIDATE $? "Docker installation"

# # eksctl Installation
# curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# VALIDATE $? "Downloaded eksctl"
# tar -xzf eksctl_$PLATFORM.tar.gz
# mv eksctl /usr/local/bin/
# rm -f eksctl_$PLATFORM.tar.gz
# eksctl version >>$LOGFILE 2>&1
# VALIDATE $? "eksctl installation"

# eksctl Installation
# {
#   curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz" &&
#   tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp &&
#   rm -f eksctl_${PLATFORM}.tar.gz &&
#   chmod +x /tmp/eksctl &&
#   mv /tmp/eksctl /usr/local/bin/
# } &>> $LOGFILE

# # Force reload shell cache to recognize eksctl
# hash -r
# which eksctl &>> $LOGFILE
# eksctl version &>> $LOGFILE
# VALIDATE $? "eksctl installation"


# kubectl Installation
curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client >>$LOGFILE 2>&1


# kubens Installation
git clone https://github.com/ahmetb/kubectx /opt/kubectx >>$LOGFILE 2>&1
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installation"

# Optional: Helm installation (uncomment if needed)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh >>$LOGFILE 2>&1
VALIDATE $? "Helm installation"
