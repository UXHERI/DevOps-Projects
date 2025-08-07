
# Wanderlust App Deployment with DevSecOps

Wanderlust is a simple MERN stack web app where people can share their travel experiences. In this project, I am going to show you how to deploy this Wanderlust app on **AWS EKS** with **DevSecOps** technologies.

![Project Diagram](https://raw.githubusercontent.com/DevMadhup/Wanderlust-Mega-Project/refs/heads/main/Assets/DevSecOps%2BGitOps.gif)

This project is by **TrainWithShubham** in his **Jenkins In One Shot** tutorial and it shows the real-world deployment of such web apps through **DevSecOps** methodoligies. 

You can find this public Github Repo here: [GitHub Repo](https://github.com/LondheShubham153/Wanderlust-Mega-Project.git)

## Step-by-Step Project Guide:

- Deploying the Infrastructure
- Install the required Tools
- Configuring the DevSecOps tools
- Configuring Prometheus & Grafana
- Configuring Jenkins CI and CD Pipelines 

## 1. Deploying the Infrastructure

In this first step, we will deploy the infrastructure needed for this project with Terraform (which is an IaC tool).

- In your VSCode Terminal, execute this command: ```ssh-keygen```
- Give this key a name of `Wanderlust`.
- Download all the Terraform files from [here](https://github.com/UXHERI/DevOps-Projects/tree/main/DevSecOps-Travel-App/Terraform).
- Now run the following commands to deploy the infrastructure:

```hcl
terraform init
terraform validate
terraform plan
terraform apply
```

- This will deploy the **EC2 instance**, along with the **Security Group** and **Key-Pair**.
- Now copy the `ec2_public_dns` value, and add this as a **Remote Host** in VSCode.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/76.png)

- Open the host in a **New Window**.

> [!IMPORTANT]
> Change the `IdentityFile` with the location of your **Private SSH Key**.

## 2. Install the required Tools

Now when we have successfully connected to the **EC2 instance**, let's install the tools we will be using in this project.

- Make a directory named `scripts`:

```bash
mkdir scripts
cd scripts
```

- Make a `tools.sh` file and paste this code to install **AWS CLI**, **eksctl** & **kubectl**:

```bash
#!/bin/bash

<< task
installing the required CLIs and tools
for Wanderlust Mega project
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

- Now make a `jenkins.sh` file and paste the following code to install **Jenkins**:

```bash
#!/bin/bash

<< task
Installing Jenkins on Master machine
task

install_java() {
    echo "Installing Java..."
    sudo apt install fontconfig openjdk-21-jre
    java -version
}

install_jenkins() {
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins
}

echo "********** INSTALLATION STARTED **********"
if ! install_java; then
    echo "INSTALLING JAVA FAILED!!!"
    exit 1
fi

if ! install_jenkins; then
    echo "INSTALLING JENKINS FAILED!!!"
    exit 1
fi

echo "********** INSTALLATION DONE **********"
```

- Now configure your **AWS Credentials** as:

```bash
aws configure
```

- Paste the following:
    - Your IAM User **Access Key**
    - Your IAM User **Secret Access Key**
    - The **region** you want to deploy your EKS Cluster in (e.g `us-east-1`).

- Run this command to install **docker**:

```bash
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu && newgrp docker
```

- Now make an **EC2 Key-Pair** named `eks-nodegroup-key`.
- Now to make an **EKS Cluster**, run this script in a `eks_cluster.sh` file:

```bash
#!/bin/bash

<< task
Creating EKS Cluster, associating IAM OIDC provider, 
and adding Node Group for Wanderlust Mega Project.
task

create_cluster() {
  echo "Creating EKS cluster..."
  eksctl create cluster --name="wanderlust" \
                        --region="us-east-1" \
                        --version="1.30" \
                        --without-nodegroup
}

associate_oidc() {
  echo "Associating IAM OIDC provider..."
  eksctl utils associate-iam-oidc-provider \
    --region "us-east-1" \
    --cluster "wanderlust" \
    --approve
}

create_nodegroup() {
  echo "Creating node group..."
  eksctl create nodegroup --cluster="wanderlust" \
                          --region="us-east-1" \
                          --name="wanderlust" \
                          --node-type="t2.large" \
                          --nodes=2 \
                          --nodes-min=2 \
                          --nodes-max=2 \
                          --node-volume-size=29 \
                          --ssh-access \
                          --ssh-public-key="eks-nodegroup-key"
}

echo "********** EKS CLUSTER SETUP STARTED **********"
if ! create_cluster; then
  echo "EKS CLUSTER CREATION FAILED!!!"
  exit 1
fi

if ! associate_oidc; then
  echo "IAM OIDC ASSOCIATION FAILED!!!"
  exit 1
fi

if ! create_nodegroup; then
  echo "NODE GROUP CREATION FAILED!!!"
  exit 1
fi

echo "********** EKS CLUSTER SETUP COMPLETED **********"
```

_This will take upto 25 minutes to make this whole **EKS Cluster**. After which you can see your cluster in **Elastic Kubernetes Service** and in **CloudFormation**._

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/8.png)

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/7.png)

- Create a `sonarqube.sh` file and paste the following code in it:

```bash
#!/bin/bash

<< task
Run SonarQube Server in a Docker container
Used in Wanderlust Mega Project for code quality analysis
task

run_sonarqube() {
  echo "Starting SonarQube container..."
  docker run -itd \
    --name SonarQube-Server \
    -p 9000:9000 \
    sonarqube:lts-community
}

check_container() {
  echo "Checking if SonarQube container is running..."
  docker ps --filter "name=SonarQube-Server"
}

echo "********** SONARQUBE SETUP STARTED **********"

if ! run_sonarqube; then
  echo "FAILED: Could not start SonarQube container"
  exit 1
fi

sleep 5

if ! check_container; then
  echo "FAILED: SonarQube container is not running"
  exit 1
fi

echo "********** SONARQUBE IS RUNNING ON PORT 9000 **********"
echo "Access it in your browser: http://localhost:9000 or http://<public-ip>:9000"
```

- Create a `trivy.sh` file and paste the following code in it:

```bash
#!/bin/bash

<< task
Install Trivy - Vulnerability Scanner for Containers & Other Artifacts
Used in Wanderlust Mega Project for security scanning
task

install_dependencies() {
  echo "Installing required dependencies..."
  sudo apt-get install wget apt-transport-https gnupg lsb-release -y
}

add_trivy_key() {
  echo "Adding Trivy GPG key..."
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
}

add_trivy_repo() {
  echo "Adding Trivy repository to sources list..."
  echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
}

update_packages() {
  echo "Updating package lists..."
  sudo apt-get update -y
}

install_trivy() {
  echo "Installing Trivy..."
  sudo apt-get install trivy -y
}

echo "********** TRIVY INSTALLATION STARTED **********"

if ! install_dependencies; then
  echo "FAILED: Installing dependencies"
  exit 1
fi

if ! add_trivy_key; then
  echo "FAILED: Adding GPG key"
  exit 1
fi

if ! add_trivy_repo; then
  echo "FAILED: Adding Trivy repository"
  exit 1
fi

if ! update_packages; then
  echo "FAILED: Updating packages"
  exit 1
fi

if ! install_trivy; then
  echo "FAILED: Installing Trivy"
  exit 1
fi

echo "********** TRIVY INSTALLATION COMPLETED SUCCESSFULLY **********"
```

- Now create a `argocd.sh` script and paste the following code in it:

```bash
#!/bin/bash

<< task
Install and Configure ArgoCD (Master Machine) for Wanderlust Mega Project

Steps:
1. Create argocd namespace
2. Apply ArgoCD manifest
3. Watch for pod status
4. Install ArgoCD CLI
5. Make CLI executable
6. Patch service to NodePort
7. Fetch initial ArgoCD admin password
task

create_namespace() {
  echo "Creating ArgoCD namespace..."
  kubectl create namespace argocd
}

apply_manifest() {
  echo "Applying ArgoCD manifest..."
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
}

install_argocd_cli() {
  echo "Installing ArgoCD CLI..."
  sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
}

patch_service() {
  echo "Patching ArgoCD service to NodePort..."
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
}

get_initial_password() {
  echo "Fetching initial ArgoCD admin password..."
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "Username: admin"
  echo "Password: $PASSWORD"
}

check_services() {
  echo "Checking ArgoCD services..."
  kubectl get svc -n argocd
}

watch_pods() {
  echo "Waiting for ArgoCD pods to be in Running state..."
  watch kubectl get pods -n argocd
}

echo "********** ARGOCD INSTALLATION STARTED **********"

if ! create_namespace; then
  echo "FAILED: Creating namespace"
  exit 1
fi

if ! apply_manifest; then
  echo "FAILED: Applying manifest"
  exit 1
fi

if ! install_argocd_cli; then
  echo "FAILED: Installing ArgoCD CLI"
  exit 1
fi

if ! patch_service; then
  echo "FAILED: Patching service"
  exit 1
fi

if ! check_services; then
  echo "FAILED: Checking services"
  exit 1
fi

if ! get_initial_password; then
  echo "FAILED: Fetching initial password"
  exit 1
fi

echo "********** ARGOCD INSTALLATION DONE **********"
echo "You can now run 'watch_pods' to monitor pod readiness or access ArgoCD via:"
echo "<public-ip-of-node>:<NodePort>"
```

## 3. Configuring the DevSecOps tools

In this step, we will be configuring all of the DevSecOps tools used in this project, so we can deploy our app using those tools.

- First we will login to **Jenkins** to install some basic plugins:
- Go to your **EC2 Public IP**, and append port `8080`.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/1.png)

- Run this command to get the **Jenkins** Password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/2.png)

- Paste this into Jenkins **Administrator Password** section.
- Click on **Install suggested plugins**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/3.png)

- This will install all the suggested plugins for Jenkins.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/4.png)

- Now create your **Jenkins User**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/5.png)

- Click **Save and Continue**.
- Now we will integrate our **Gmail** with **Jenkins**, so it can send an email everytime a build get successfull or it fails.
- Go to **Manage your Google Account**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/12.png)

- Go to **Security**, and enable **2-Step Verification**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/13.png)

- Now search for **App passwords** and click on it.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/14.png)

- Now create an **App password** for **Jenkins**, and copy the password somewhere.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/15.png)

- Now go to **Jenkins** --> **Manage Jenkins**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/16.png)

- Click on **Credentials**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/17.png)

- Click on **Global**.
- Click on **Add Credentials**.
- Add the following credentials:
    - **Kind**: Username with password
    - **Username**: [YOUR EMAIL ADDRESS]
    - **Password**: [JENKINS APP PASWORD]
    - **ID**: Gmail
    - **Description**: Gmail App Password

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/19.png)

- Now go to **Manage Jenkins** --> **System**.
- Go to **Extended E-mail Notification**, and configure it as:
    - **SMTP server**: smtp.gmail.com
    - **SMTP Port**: 465
    - **Credentials**: [GMAIL APP CREDENTIALS]
    - Check-mark **Use SSL**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/21.png)

- Now go to **Manage Jenkins** --> **Plugins** --> **Available plugins**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/22.png)

- Add the following **Available Plugins**:
    - OWASP Dependency-Check
    - SonarQube Scanner
    - Docker
    - Pipeline: Stage View

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/23.png)

- Now go to **Manage Jenkins** --> **Tools**.
- Scroll down to **Dependency-Check installations**.
- Configure the **Add Dependency-Check** as:
    - **Name**: OWASP
    - Install from **github.com**

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/26.png)

- Now go to SonarQube by going to your **EC2 Public IP** and append **Port**: `9000`
- Enter the default credentials as:
    - **Username**: admin
    - **Password**: admin

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/11.png)

- Go to **Administration** --> **Security** --> **Users**.
- Click on **Update Tokens**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/28.png)

- Enter **Name** as `Jenkins`, and click **Generate**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/29.png)

- Copy and paste it somewhere.
- Go to **Jenkins** --> **Manage Jenkins** --> **Credentials** --> **Global Credentials**.
- Add the following credentials:
    - **Kind**: Secret text
    - **Secret**: [SONARQUBE TOKEN FOR JENKINS]
    - **ID**: Sonar
    - **Description**: SonarQube Token Key

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/30.png)

- Go to **Manage Jenkins** --> **Tools**.
- Add **SonarQube Scanner** as:
    - **Name**: Sonar
    - Install from **Maven Central**

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/31.png)

- Go to your **Github Profile**.
- Go to **Settings** --> **Developer settings**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/33.png)

- Go to **Tokens (classic)** --> **Generate new token (classic)**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/34.png)

- Name it `Jenkins`.
- Only select **repo**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/35.png)

- Now go back to **Jenkins** --> **Manage Jenkins** --> **Credentials** --> **System** --> **Global credentials**.
- Add the following credentials as:
    - **Kind**: Username with password
    - **Username**: [YOUR GITHUB USERNAME]
    - **Password**: [YOUR GITHUB TOKEN]
    - **ID**: Github-cred

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/36.png)

- Now go to **Manage Jenkins** --> **System**.
- Scroll down to **SonarQube Installations**.
- Configure it as:
    - **Name**: Sonar
    - **Server URL**: [EC2 PUBLIC IP:9000]
    - **Server Authentication Token**: SonarQube Token Key

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/37.png)

- Now go to **SonarQube** --> **Administration** --> **Configuration** --> **Webhooks**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/38.png)

- Create and configure the **Webhook** as:
    - **Name**: Jenkins Webhook
    - **URL**: [EC2 PUBLIC IP:8080/sonarqube-webhook/]

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/39.png)


- Now go to **ArgoCD** by accessing: [CLUSTER NODE IP:ARGOCD SERVER PORT]

> [!IMPORTANT]
> Head to your executed `argocd.sh` script to get the URL for ArgoCD or run `kubectl get svc -n argocd` to get it.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/77.png)

- You can also see the default password by running:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

- Login to ArgoCD with:
    - **Username**: admin
    - **Password**: [EXTRACTED PASSWORD]

> [!TIP]
> Update your ArgoCD password by going to **User Info** --> **Update password**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/43.png)

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/44.png)

- Go to **Settings** --> **Repositories**.
- Click **Connect Repo**.
- Configure it as:
  - **Connection Method**: HTTPS
  - **Type**: git
  - **Project**: default
  - **Repository URL**: [WANDERLUST REPO LINK]

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/46.png)

> [!IMPORTANT]
> Change the **Repository Link** to your **Forked Link**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/47.png)

- Now login to **ArgoCD CLI**:

```bash
 argocd login 13.220.109.37:30791 --username admin
 ```

 > [!IMPORTANT]
> Change `13.220.109.37:30791` to your `ArgoCD URL`.

- Check how many **clusters** are available in argocd:

```bash
argocd cluster list
```

- Get your **Cluster Name**:

```bash
kubectl config get-contexts
```

- Add your **cluster** to argocd:

```bash
argocd cluster add Wanderlust@wanderlust.us-east-1.eksctl.io --name wanderlust-eks-cluster
```

> [!IMPORTANT]
> Change `Wanderlust@wanderlust.us-east-1.eksctl.io` to your **Cluster name**.

- Now go to **Application** --> **Create Application**.
- Configure it as:
  - **Application Name**: wanderlust
  - **Project Name**: default
  - Check-mark **PRUNE RESOURCES**, **SELF HEAL** & **AUTO-CREATE NAMESPACE**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/54.png)

- Configure its **Source** as:
  - **Repository URL**: [YOUR REPO LINK]
  - **Revision**: main
  - **Path**: kubernetes

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/55.png)

- Configure **Destination** as:
  - **Cluster URL**: [YOUR CLUSTER URL]
  - **Namespace**: wanderlust

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/56.png)

- Now your repo is added successfully.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/59.png)

## 4. Configuring Prometheus & Grafana

Now we have to add **Prometheus** and **Grafana** to **EKS Cluster Nodes** to enable **Monitoring** & **Logging** on them.

- Go to the **Security Group** of any **Cluster Node**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/57.png)

- Add these two rules.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/58.png)

- Now make a script named `monitoring.sh`, and run the following commands in it:

```bash
#!/bin/bash

<< task
Install and Configure Prometheus & Grafana via Helm for Kubernetes Monitoring
Used in Wanderlust Mega Project
Steps:
1. Install Helm
2. Add Helm Repositories
3. Create Prometheus Namespace
4. Install kube-prometheus-stack via Helm
5. Expose Prometheus & Grafana using NodePort
6. Retrieve Grafana admin password
task

install_helm() {
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
}

add_helm_repos() {
  echo "Adding Helm repositories..."
  helm repo add stable https://charts.helm.sh/stable
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
}

create_prometheus_namespace() {
  echo "Creating prometheus namespace..."
  kubectl create namespace prometheus
}

install_kube_prometheus_stack() {
  echo "Installing Prometheus stack using Helm..."
  helm install stable prometheus-community/kube-prometheus-stack -n prometheus
}

verify_pods() {
  echo "Verifying pods in prometheus namespace..."
  kubectl get pods -n prometheus
}

get_services() {
  echo "Getting services in prometheus namespace..."
  kubectl get svc -n prometheus
}

expose_prometheus_nodeport() {
  echo "Patching Prometheus service to NodePort..."
  kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus \
    -p '{"spec": {"type": "NodePort"}}'
}

expose_grafana_nodeport() {
  echo "Patching Grafana service to NodePort..."
  kubectl patch svc stable-grafana -n prometheus \
    -p '{"spec": {"type": "NodePort"}}'
}

get_grafana_password() {
  echo "Fetching Grafana admin password..."
  GRAFANA_PASSWORD=$(kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
  echo "Username: admin"
  echo "Password: $GRAFANA_PASSWORD"
}

echo "********** PROMETHEUS & GRAFANA INSTALLATION STARTED **********"

if ! install_helm; then
  echo "FAILED: Installing Helm"
  exit 1
fi

if ! add_helm_repos; then
  echo "FAILED: Adding Helm Repositories"
  exit 1
fi

if ! create_prometheus_namespace; then
  echo "FAILED: Creating Namespace"
  exit 1
fi

if ! install_kube_prometheus_stack; then
  echo "FAILED: Installing Prometheus Stack"
  exit 1
fi

if ! verify_pods; then
  echo "WARNING: Pod verification failed — please check manually"
fi

if ! get_services; then
  echo "WARNING: Could not retrieve services"
fi

if ! expose_prometheus_nodeport; then
  echo "FAILED: Exposing Prometheus"
  exit 1
fi

if ! expose_grafana_nodeport; then
  echo "FAILED: Exposing Grafana"
  exit 1
fi

if ! get_grafana_password; then
  echo "FAILED: Fetching Grafana password"
  exit 1
fi

echo "********** MONITORING SETUP COMPLETED SUCCESSFULLY **********"
echo "✅ Prometheus and Grafana are now exposed via NodePort"
echo "🔗 Access Prometheus: http://<your-node-ip>:PROMETHEUS_PORT"
echo "🔗 Access Grafana: http://<your-node-ip>:GRAFANA_PORT"
echo "🔐 Grafana Login Credentials:"
echo "Username: admin"
echo "Password: $GRAFANA_PASSWORD"
```

- Now open the ports of **Prometheus** and **Grafana** in **Cluster Node's Security Group**.
- Access **Prometheus & Grafana** via:
  - http://[NODE IP:PROMETHEUS PORT]

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/62.png)

  - http://[NODE IP:GRAFANA PORT]

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/63.png)

> [!TIP]
> Run the following script to get **Prometheus** & **Grafana** ports easily.

- Create a `get_ports.sh` and paste the following code in it:

```bash
#!/bin/bash

get_services_and_ports() {
  echo "Fetching external NodePorts for Prometheus and Grafana..."

  PROMETHEUS_PORT=$(kubectl get svc stable-kube-prometheus-sta-prometheus -n prometheus -o jsonpath="{.spec.ports[0].nodePort}")
  GRAFANA_PORT=$(kubectl get svc stable-grafana -n prometheus -o jsonpath="{.spec.ports[0].nodePort}")

  echo "Access URLs:"
  echo "  Prometheus: http://<your-public-ip>:$PROMETHEUS_PORT"
  echo "  Grafana:    http://<your-public-ip>:$GRAFANA_PORT"
```

- Run it by `./get_ports.sh` and you'll get the **Ports** for **Prometheus & Grafana**.

## 5. Configuring Jenkins CI and CD Pipelines

Now we will build the actual pipelines for CI and CD in **Jenkins** and will execute them to build our project.

- Go to **Jenkins** --> **New Item**.
- Name it `Wanderlust-CI`.
- Select **Pipeline** as **Type**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/52.png)

- Check-mark **Discard old builds**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/53.png)

- Add your **Repo Link** in **Github Project**.
- Paste the following in **Pipeline Script**:

```
@Library('Shared') _
pipeline {
    agent any
    
    environment{
        SONAR_HOME = tool "Sonar"
    }
    
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')
    }
    
    stages {
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("FRONTEND_DOCKER_TAG and BACKEND_DOCKER_TAG must be provided.")
                    }
                }
            }
        }
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs()
                }
            }
        }
        
        stage('Git: Code Checkout') {
            steps {
                script{
                    code_checkout("https://github.com/UXHERI/Wanderlust-Mega-Project.git","main")
                }
            }
        }
        
        stage("Trivy: Filesystem scan"){
            steps{
                script{
                    trivy_scan()
                }
            }
        }

        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp_dependency()
                }
            }
        }
        
        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqube_analysis("Sonar","wanderlust","wanderlust")
                }
            }
        }
        
        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqube_code_quality()
                }
            }
        }
        
        stage('Exporting environment variables') {
            parallel{
                stage("Backend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatebackendnew.sh"
                            }
                        }
                    }
                }
                
                stage("Frontend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatefrontendnew.sh"
                            }
                        }
                    }
                }
            }
        }
        
        stage("Docker: Build Images"){
            steps{
                script{
                        dir('backend'){
                            docker_build("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","uxheri")
                        }
                    
                        dir('frontend'){
                            docker_build("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","uxheri")
                        }
                }
            }
        }
        
        stage("Docker: Push to DockerHub"){
            steps{
                script{
                    docker_push("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","uxheri") 
                    docker_push("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","uxheri")
                }
            }
        }
    }
    post{
        success{
            archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Wanderlust-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}
```

> [!IMPORTANT]
> Change `Github Repo` and `DockerHub Username` according to yours.

- Click **Save**.
- Now make another pipeline:
  - **Name**: `Wanderlust-CD`
  - Select **Pipeline**.
  - Check-mark **Discard old builds** as the same.
  - Paste this code in **Pipeline Script**:

```
@Library('Shared') _
pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Frontend Docker tag of the image built by the CI job')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Backend Docker tag of the image built by the CI job')
    }

    stages {
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs()
                }
            }
        }
        
        stage('Git: Code Checkout') {
            steps {
                script{
                    code_checkout("https://github.com/UXHERI/Wanderlust-Mega-Project.git","main")
                }
            }
        }
        
        stage('Verify: Docker Image Tags') {
            steps {
                script{
                    echo "FRONTEND_DOCKER_TAG: ${params.FRONTEND_DOCKER_TAG}"
                    echo "BACKEND_DOCKER_TAG: ${params.BACKEND_DOCKER_TAG}"
                }
            }
        }
        
        
        stage("Update: Kubernetes manifests"){
            steps{
                script{
                    dir('kubernetes'){
                        sh """
                            sed -i -e s/wanderlust-backend-beta.*/wanderlust-backend-beta:${params.BACKEND_DOCKER_TAG}/g backend.yaml
                        """
                    }
                    
                    dir('kubernetes'){
                        sh """
                            sed -i -e s/wanderlust-frontend-beta.*/wanderlust-frontend-beta:${params.FRONTEND_DOCKER_TAG}/g frontend.yaml
                        """
                    }
                    
                }
            }
        }
        
        stage("Git: Code update and push to GitHub"){
            steps{
                script{
                    withCredentials([gitUsernamePassword(credentialsId: 'Github-cred', gitToolName: 'Default')]) {
                        sh '''
                        echo "Checking repository status: "
                        git status
                    
                        echo "Adding changes to git: "
                        git add .
                        
                        echo "Commiting changes: "
                        git commit -m "Updated environment variables"
                        
                        echo "Pushing changes to github: "
                        git push https://github.com/UXHERI/Wanderlust-Mega-Project.git main
                    '''
                    }
                }
            }
        }
    }
  post {
        success {
            script {
                emailext attachLog: true,
                from: 'uzairikhan2k2@gmail.com',
                subject: "Wanderlust Application has been updated and deployed - '${currentBuild.result}'",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">URL: ${env.BUILD_URL}</p>
                        </div>
                    </body>
                    </html>
            """,
            to: 'uzairikhan2k2@gmail.com',
            mimeType: 'text/html'
            }
        }
      failure {
            script {
                emailext attachLog: true,
                from: 'uzairikhan2k2@gmail.com',
                subject: "Wanderlust Application build failed - '${currentBuild.result}'",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                        </div>
                    </body>
                    </html>
            """,
            to: 'uzairikhan2k2@gmail.com',
            mimeType: 'text/html'
            }
        }
    }
}
```

- Now run the **CI Pipeline**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/64.png)

- The **CD Pipeline** will build automatically.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/65.png)

- You will also recieve an **Email** like this:

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/66.png)

- Access the web app via: `http://[NODE IP:31000]

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/74.png)

_Here is your **Wanderlust** Web Application all ready and deployed successfully!!!_
