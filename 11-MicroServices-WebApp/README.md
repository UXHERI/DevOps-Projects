
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
-  Configuring CD (Continuous Integration)

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

- In the **Available plugins**, add these 4 plugins:

    1. Docker
    2. Docker Pipeline
    3. Kubernetes
    4. Kubernetes CLI

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/23.png?raw=true)



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

- In a new tab, go to **Jenkins Dashboard**, then **Plugins** and install a plugin named `Multibranch Scan Webhook Trigger`.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/44.png?raw=true)

- Now return to the previous tab.
- In **Scan Multibranch Pipeline Triggers**, select **Scan by webhook**.
- Name your **Trigger token**.
- Click on **[?]** next to the Trigger token.
- Copy this part [JENKINS_URL/multibranch-webhook-trigger/invoke?token=[Trigger token] and save it somewhere.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/42.png?raw=true)


- In the **JENKINS_URL** write your **EC2 Public IP** and in the **[TRIGGER TOKEN]** write the name of the **Trigger Token** you specified:

```URL
http://3.82.11.125:8080/multibranch-webhook-trigger/invoke?token=uxheri
```
- Now before applying it, go to your **Github Repo**.
- Click on **Settings**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/45.png?raw=true)

- Click on **Webhooks**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/46.png?raw=true)

- Click **Add webhook**.
- In the **Payload URL** post your URL and select **Content type** as `application/json`.


![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/47.png?raw=true)

- Keep these settings as are:

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/48.png?raw=true)

- Click **Add Webhook**.
- On **Jenkins Pipeline Configuration** page, click **Apply** and **Save**.

_Now you will see that your Pipeline is running and is building all the 11 MicroServices._ 

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/43.png?raw=true)

**_Once all of these get build completely, this means that the CI (Continuous Integration) part is DONE SUCCESSFULLY!_**

## 6. Configuring CD (Continuous Integration)

In this step, we are going to configure the CD (Continuous Integration) part of this project.

- First, we will create **Service Account**.

```bash
vim svc.yml
```

- Copy/paste this into `svc.yml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: webapps
```

- Now **Create Role**:

```bash
vim role.yml
```

- Copy/paste this into `role.yml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: webapps
rules:
  - apiGroups:
        - ""
        - apps
        - autoscaling
        - batch
        - extensions
        - policy
        - rbac.authorization.k8s.io
    resources:
      - pods
      - componentstatuses
      - configmaps
      - daemonsets
      - deployments
      - events
      - endpoints
      - horizontalpodautoscalers
      - ingress
      - jobs
      - limitranges
      - namespaces
      - nodes
      - pods
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
      - replicasets
      - replicationcontrollers
      - serviceaccounts
      - services
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

- Now **Bind** the role to service account:

```bash
vim bind.yml
```

- Copy/paste this into `bind.yml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: webapps 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role 
subjects:
- namespace: webapps 
  kind: ServiceAccount
  name: jenkins 
```

- Create a **secret**:

```bash
vim sec.yml
```
- Copy/paste this into `sec.yml`:

```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  namespace: webapps
  annotations:
    kubernetes.io/service-account.name: jenkins
```
- Now apply these YAML files:

```bash
kubectl apply -f svc.yml
kubectl apply -f role.yml
kubectl apply -f bind.yml
kubectl apply -f sec.yml
```
- Run this command and copy the output:

```bash
kubectl describe secret mysecretname -n webapps
```
![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/49.png?raw=true)

- Now go back to **Jenkins Credentials** page and add a credential:
    - **Kind**: Secret text
    - **Secret**: [THE-RESULTED-OUTPUT]
    - **ID**: k8-token
    - **Description**: k8-token

-  Now head to the **main** branch in your **Github Repo**.
- Update the `Jenkinsfile`:

```bash
pipeline {
    agent any
    
    stages {
        stage('Deploy to Kubernetes') {
            steps {
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: ' EKS-1', contextName: '', credentialsId: 'k8s-token', namespace: 'webapps', serverUrl: 'https://099321E17EE35EA8B6A8A602FEA9D19B.gr7.us-east-1.eks.amazonaws.com']]) {
                    sh "kubectl apply -f deployment-service.yml"
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: ' EKS-1', contextName: '', credentialsId: 'k8s-token', namespace: 'webapps', serverUrl: 'https://099321E17EE35EA8B6A8A602FEA9D19B.gr7.us-east-1.eks.amazonaws.com']]) {
                    sh "kubectl get svc -n webapps"
                }
            }
        }
    }
}
```

> [!NOTE]
> Change the **serverUrl** and **clusterName** according to you.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/58.png?raw=true)

- **Save** this file.
- Now your **Jenkins Pipeline** will start building the **main** branch pipeline again.
- Now click on **main**, and go to your latest build.
- Now click **Console Output**.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/55.png?raw=true)

- From the output logs, copy the **frontend-external** URL.


![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/56.png?raw=true)

- Paste this into your web browser.

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/33.png?raw=true)

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/34.png?raw=true)

![Image](https://github.com/UXHERI/DevOps-Projects/blob/main/11-MicroServices-WebApp/Images/35.png?raw=true)


_**Congrats!!! You have successfully build and deployed this WebApp using Kubernetes and Jenkins.**_
