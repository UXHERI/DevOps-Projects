
# Deploying E-Commerce MicroServices CICD Pipeline

This project is about deploying an e-commerce website using MicroServices, Kubernetes, Jenkins.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/33.png?raw=true)

This project is by **DevOps Shack** about a MicroServices E-Commerce Website which has 11 different MicroServices Branches and I deployed it on Kubernetes and integrated an efficient CICD Pipeline with Jenkins.

You can find this public Github Repo here: [Github Repo](https://github.com/jaiswaladi246/Microservice.git)

## Step-by-Step Project Guide:

- Launching an Ubuntu EC2 Server
- Install AWSCLI, KubeCTL and EKSCTL
- Create an IAM User
- Create an EKS Cluster
- Install and Configure Jenkins

## 1. Launching an Ubuntu EC2 Server

In the first step, we have to launch an Ubuntu EC2 instance to manage our Kubernetes cluster from it.

- In the **AWS Management Console**, head to the `EC2` section.
- Name your EC2 instance.
- Select `Ubuntu` as **Amazon Machine Image**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/6.png?raw=true)

- Select **Instance type** as `t2.large`.
- Create a **Key-pair** to SSH into the instance.
- In **Security group** add these rules:

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/2.png?raw=true)

- In **Configure storage** change size to `25 GiB`.
- Click **Launch instance**.

## 2. Install AWSCLI, KubeCTL and EKSCTL

In this second step, we will be installing the required **AWSCLI, KubeCTL** and **EKSCTL** to make and manage **EKS cluster**.

- SSH into your instance:

```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

- Make a directory called `scripts` to save and execute bash scripts:

```bash
mkdir scripts
```

- Go inside this directory:
```bash
cd scripts/
```

- Make a file called `install.sh`:

```bash
vim install.sh
```

-  Paste the following bash script in `install.sh`:

```bash
#!/bin/bash

<< task
installing the required CLIs and tools
for 11 Microservices E-commerce project
task

install_awscli() {
        echo "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        sudo apt install unzip
        unzip awscliv2.zip
        sudo ./aws/install
}

install_kubectl() {
        echo "Installing KubeCTL..."
        curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin
}

install_eksctl() {
        echo "Installing EKSCTL..."
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
}

echo "********** INSTALLATION STARTED **********"
if ! install_awscli; then
        echo "INSTALLING AWSCLI FAILED!!!"
        exit 1
fi
if ! install_kubectl; then
        echo "INSTALLING KUBECTL FAILED!!!"
        exit 1
fi
if ! install_eksctl; then
        echo "INSTALLING EKSCTL FAILED!!!"
        exit 1
fi
echo "********** INSTALLATION DONE **********"
```

- Make this file executable:
```bash
chmod +x install.sh
```

- Execute this script:

```bash
./install.sh
```
_Wait for it to install AWSCLI, KubeCTL and EKSCTL_ 

- Now install Docker:

```bash
sudo apt install docker.io
```
- Also append your Ubuntu user to **Docker group**:
``` bash
sudo usermod -aG docker $USER && newgrp docker
```


## 3. Create an IAM User

In this step, we will create an **IAM User** to have EKSCTL and Docker access.

- In the **AWS Management Console**, head to the `IAM` section.
- Select **Users**.
- Click **Create user**.
- Set a **User name**.
- In the **Set permissions**, select `Attach policies directly` and add these policies:

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/36.png?raw=true)


- Now add an inline policy and name it `eks-user-policy`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "*"
        }
    ]
}
```

- Add another inline policy and name it `eks-describe`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        }
    ]
}
```

- **Create** this user.
- Now click **Create access key** for this user.
- In **Use case** select **Command Line Interface (CLI)**.
- Give this **Access key** a **Tag**.
- Now run `aws configure` in your EC2 instance and setup your **Access key** that you've just created.


## 4. Create an EKS Cluster

Now that you've configured **AWSCLI**, let's create the **EKS Cluster**.

- Run this command to create an **EKS cluster**:

```bash
eksctl create cluster --name=EKS-1 \
                      --region=us-east-1 \
                      --zones=us-east-1a,us-east-1b \
                      --without-nodegroup
```
> [!NOTE]
> Change **region** to your **AWS Region** and add **Zones** accordingly to that.

- Now run:

```bash
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster EKS-1 \
    --approve
```

- Create a **Node-Group**:

```bash
eksctl create nodegroup --cluster=EKS-1 \
                       --region=us-east-1 \
                       --name=node2 \
                       --node-type=t3.medium \
                       --nodes=3 \
                       --nodes-min=2 \
                       --nodes-max=4 \
                       --node-volume-size=20 \
                       --ssh-access \
                       --ssh-public-key=DevOps \
                       --managed \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access
```

> [!NOTE]
> Change **ssh-public-key** to your **EC2 Public Key** accordingly.

- Run this command to install **Java**:

```bash
sudo apt install openjdk-17-jre-headless -y
```

## 5. Install and Configure Jenkins

In this step, we will be installing and configuring **Jenkins** for our **CICD Pipeline**.

- In the **scripts** folder, create `install_jenkins.sh` file:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```

Then run:

```bash
chmod +x install_jenkins.sh
./install_jenkins.sh
```

_To access **Jenkins** copy your **EC2 Public IP** and append **port:8080**_

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/37.png?raw=true)

- Now run this command to get **Jenkins admin Password**:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
- Paste it into **Administrator password**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/18.png?raw=true)

- Click **Install suggested plugins**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/19.png?raw=true)

_Jenkins will install the **suggested plugins** by itself._

- Next, click on **Skip and continue as admin**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/20.png?raw=true)

- You have entered the **Jenkins Dashboard!**

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/21.png?raw=true)

- Now in **System configuration**, click on **Plugins**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/22.png?raw=true)

- In the **Available plugins*, add these 4 plugins:

    1. Docker
    2. Docker Pipeline

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/23.png?raw=true)

    3. Kubernetes
    4. Kubernetes CLI

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/24.png?raw=true)

- Now in the **Manage Jenkins**, go to **Tools**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/22.png?raw=true)

-  Click on **Add Docker** and configure it as following:
    - **Name**: docker
    - Click **Install automatically**
    - In **Add installer**, click **Download from docker.com**

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/26.png?raw=true)

- In **Manage Jenkins**, scroll down to **Security** and click **Credentials**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/27.png?raw=true)

- In **Stores scoped to Jenkins**, under **Domains** click **(global)**.
- Click **Add Credentials**.
- Configure it as:
    - **Kind**: Username with password
    - **Username**: [YOUR GITHUB USERNAME]
    - **Password**: [GITHUB ACCESS TOKEN]
    - **ID** & **Description**: `git-cred`

- Add another credentials as:
    - **Kind**: Username with password
    - **Username**: [YOUR DOCKERHUB USERNAME]
    - **Password**: [YOUR DOCKERHUB PASSWORD]
    - **ID** & **Description**: `docker-cred`


> [!IMPORTANT]
> Change **Image Name** to your **DockerHub** accordingly in the **Jenkinsfile** in all branches.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/38.png?raw=true)


- Now head back to **Jenkins Dashboard**, and click **New item**.
- Enter the **name** as `Microservice-E-Commerce`.
- Select **Multibranch Pipeline**.
- Click **Next**.
- In **Branch Sources**, select **Git** and paste your **Github Repo URL** in the **Project Repository**.
- In **Credentials**, add the **Github Credentials** that you have added to Jenkins.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/40.png?raw=true)

- In **Build Configuration** keep it as:

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/41.png?raw=true)

- In **Scan Multibranch Pipeline Triggers**, select **Scan by webhook**.
- Name your **Trigger token**.
- Click on **[?]** next to the Trigger token.
- Copy this part [JENKINS_URL/multibranch-webhook-trigger/invoke?token=[Trigger token] and save it somewhere.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/42.png?raw=true)


