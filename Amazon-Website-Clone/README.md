
# Amazon Website Clone

This project is originally done by Harish Shetty and in this project he used DevSecOps tools and methods to deploy an Amazon website clone along with GitOps practices.

![Project Diagram](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/Project-Diagram.png?raw=true)

This project has several tech stack used in it and it integrates security best practices to make the deployment and infrastructure secure from vulnerabilities.

## Step-by-Step Project Guide

- Deploying the infrastructure
- Installing the DevSecOps tools
- Configuring the DevSecOps tools
- Creating EKS Cluster
- Monitor Kubernetes with Prometheus
- Installing and Configuring ArgoCD

## 1. Deploying the infrastructure

In the first step, I am going to deploy the **EC2 Master** server along with its **Security Group**, fully automated by **Terraform**.

- Download these terraform files from [here](https://github.com/UXHERI/DevOps-Projects/tree/main/Amazon-Website-Clone/Terraform).
- Run `ssh-keygen` and name it `devsecops` to make an **EC2 Key-Pair**.
- Execute these commands to deploy the infrastructure:

```powershell
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

_This will take some time to deploy the infrastructure._

## 2. Installing the DevSecOps Tools

Now when the **EC2 Instance** is deployed, the next step is to install the required **DevSecOps** tools to deploy the app.

- SSH into the **EC2 Instance**.
- Update the installed packages:

```bash
sudo apt update -y
sudo apt upgrade -y
```

- Now download/copy these [scripts](https://github.com/UXHERI/DevOps-Projects/tree/main/Amazon-Website-Clone/Scripts).
- Make all these scripts executable:

```bash
chmod +x *
```

- Now first run `tools.sh` to install **AWS CLI**, **KubeCTL** and **EKSCTL**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/1.png?raw=true)

- Now run `aws configure` to configure your **Access Keys** and **Secret Access Keys**.
- Run `docker.sh` to install & configure **Docker** automatically.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/2.png?raw=true)

- Run `jenkins.sh` to install & configure **Jenkins** automatically.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/3.png?raw=true)

- Run `trivy.sh` to install **Trivy**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/7.png?raw=true)

- Run `prometheus.sh` to install **Prometheus**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/8.png?raw=true)

- Run `node_exporter.sh` to install **Node Exporter**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/10.png?raw=true)

- Run `grafana.sh` to install and configure **Grafana** automatically**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/13.png?raw=true)

- Run `sonarqube.sh` to run **SonarQube** container.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/28.png?raw=true)

## 3. Configuring the DevSecOps tools

Now when the **DevSecOps** tools are installed, now is the time to configure them.

- Go to **Jenkins** at its URL.
- Give the initial password for **Jenkins**.
- Now select **Install suggested plugins**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/4.png?raw=true)

_It will install the suggested plugins automatically._

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/5.png?raw=true)

- Create your **User**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/6.png?raw=true)

- Click **Save and Continue**.
- Now go to **Grafana** at its URL.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/12.png?raw=true)

- Give the credentials of **Grafana**:
    - **Username** = `admin`
    - **Password** = `admin`
- Now go to **Data sources**.
- Click on **Prometheus**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/15.png?raw=true)

- In **Connection** give **Prometheus** URL.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/16.png?raw=true)

- Click **Save & test**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/17.png?raw=true)

- Now go to **Dashboards**.
- Click **New** --> **Import**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/19.png?raw=true)

- Go to this [Website](https://grafana.com/grafana/dashboards/1860-node-exporter-full/).
- Click **Copy ID to clipboard**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/20.png?raw=true)

- Paste it in the **Dashboard ID**.
- Select **Prometheus**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/21.png?raw=true)

- Click **Import**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/22.png?raw=true)

- - Go to this [Website](https://grafana.com/grafana/dashboards/9964-jenkins-performance-and-health-overview/).
- Click **Copy ID to clipboard**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/23.png?raw=true)

- Paste it in the **Dashboard ID**.
- Select **Prometheus**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/24.png?raw=true)

- Click **Import**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/25.png?raw=true)

- Now go to **Jenkins** --> **Manage Jenkins** --> **Plugins** --> **Available plugins**.
- Install all these plugins:
    - Eclipse Temurin installer
    - NodeJS
    - Email Extension Template
    - OWASP Dependency-Check
    - Pipeline: Stage View
    - SonarQube Scanner
    - Prometheus metrics
    - Docker
    - Docker API
    - Docker Commons
    - Docker Pipeline

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/26.png?raw=true)

_Wait for the plugins to get installed._

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/27.png?raw=true)

- Now we will integrate our **Gmail** with **Jenkins**, so it can send an email everytime a build get successfull or it fails.
- Go to **Manage your Google Account**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/12.png)

- Go to **Security**, and enable **2-Step Verification**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/13.png)

- Now search for **App passwords** and click on it.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/14.png)

- Now create an **App password** for **Jenkins**, and copy the password somewhere.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/30.png?raw=true)

- Now go to **SonarQube** and login to it with:
    - **Username** = `admin`
    - **Password** = `admin`
- Go to **Administration** --> **Security** --> **Users**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/31.png?raw=true)

- Click on **Update Tokens**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/32.png?raw=true)

- Enter **Name** as `jenkins`.
- Click **Generate**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/33.png?raw=true)

- Now go to **Configuration** --> **Webhooks**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/34.png?raw=true)

- Write the **Name** as `jenkins`.
- In **URL**, type `[JENKINS-URL/sonarqube-webhook]`.
- Click **Create**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/35.png?raw=true)

- Now go to **DockerHub**.
- Go to **Personal access tokens**.
- Click **Generate new token**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/36.png?raw=true)

- Configure it as:
    - **Access token description** = `docker-token-jenkins`
    - **Access permissions** = `Read, Write, Delete`

- Click **Generate**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/37.png?raw=true)

- Now go to **Jenkins** --> **Manage Jenkins** --> **Credentials** --> **System** --> **Global credentials (unrestricted)**.
- Click **Add credentials**.
- Add the following credentials:
    - **Kind**: `Username with password`
    - **Username**: `[YOUR EMAIL ADDRESS]`
    - **Password**: `[GENERATED GMAIL APP PASSWORD]`
    - **ID**: `mail-cred`
    - **Description**: `mail-cred`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/38.png?raw=true)

- Add another credentials:
    - **Kind**: `Secret text`
    - **Secret**: `[SONARQUBE GENERATED TOKEN]`
    - **ID**: `sonar-token`
    - **Description**: `sonar-token`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/39.png?raw=true)

- Add another credentials:
    - **Kind**: `Secret text`
    - **Secret**: `[DOCKERHUB GENERATED PAT]`
    - **ID**: `docker-cred`
    - **Description**: `docker-cred`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/40.png?raw=true)

- Now go to **Manage Jenkins** --> **Tools**.
- Scroll down to **Add JDK**.
- Configure it as:
    - **Name** = `jdk17`
    - `Install from adoptium.net`
    - **Version** = `[JDK 17 LATEST]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/42.png?raw=true)

- Scroll down to **Add SonarQube Scanner**.
- Configure it as:
    - **Name** = `sonar-scanner`
    - `Install from Maven Central`
    - **Version** = `[LATEST VERSION]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/43.png?raw=true)

- Scroll down to **Add NodeJS**.
- Configure it as:
    - **Name** = `node16`
    - `Install from nodejs.org`
    - **Version** = `[NODEJS 16 LATEST]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/44.png?raw=true)

- Scroll down to **Add Dependency-Check**.
- Configure it as:
    - **Name** = `dp-check`
    - `Install from github.com`
    - **Version** = `[LATEST]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/45.png?raw=true)

- Scroll down to **Add Docker**.
- Configure it as:
    - **Name** = `docker`
    - `Install from docker.com`
    - **Version** = `[LATEST]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/46.png?raw=true)

- Scroll down to **Add SonarQube**.
- Configure it as:
    - **Name** = `sonar-server`
    - **Server URL** = `SONARQUBE URL`
    - **Authentication Token** = `sonar-token`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/48.png?raw=true)

- Scroll down to **Extended E-mail Notification**.
- Configure it as:
    - **SMTP server** = `smtp.gmail.com`
    - **SMTP Port** = `465`
    - **Credentials** = `mail-cred`
    - **Check-Mark** `Use SSL`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/49.png?raw=true)

- Scroll down to **E-mail Notification**.
- Configure it as:
    - **SMTP server** = `smtp.gmail.com`
    - **Email Suffix** = `@gmail.com`
    - **Check-Mark** `Use SMTP Authentication`
    - **Username** = `[YOUR EMAIL ADDRESS]`
    - **Password** = `[GENERATED GMAIL APP PASSWORD]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/50.png?raw=true)

- Click **Apply**.
- Click **Save**.
- Now go to **Jenkins** and click **Create a job**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/51.png?raw=true)

- Enter the **Name** as `amazon-project`.
- Select the **Item Type** as `Pipeline`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/52.png?raw=true)

- In the **Definition** select `Pipeline script from SCM`.
- In the **Repository URL** give your forked URL of this repository.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/53.png?raw=true)

- Click **Apply**.
- Click **Save**.
- Now in the pipeline click **Build Now** and it will start building the pipeline.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/54.png?raw=true)

_This will take 30 Minutes to build the pipeline._

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/55.png?raw=true)

- Access it via `http://[EC2-PUBLIC-IP]`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/56.png?raw=true)


## 4. Creating EKS Cluster

Now when we have the application built and accessible, let's make an **EKS Cluster** to deploy the application on it.

- Go to your scripts file.
- Install **Helm** by running `helm.sh` script.
- Run `eks_cluster.sh` to make the **EKS Cluster**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/57.png?raw=true)

_It will take 30 Minutes to completely setup the **EKS Cluster**._

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/59.png?raw=true)

- Now clone this repository:

```bash
git clone https://github.com/harishnshetty/amazon-Devsecops.git
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/61.png?raw=true)

- Now go inside this repository:

```bash
cd amazon-Devsecops/k8s-80
```

- Now apply the manifest file:

```bash
kubectl apply -f .
kubectl config set-context --current --namespace=amazon-ns
kubectl get ingress -w
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/62.png?raw=true)

- Copy and paste this **ALB URL** in your browser.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/63.png?raw=true)


## 5. Monitor Kubernetes with Prometheus

Now we will set up **Prometheus** to monitor **Kubernetes** and we will do it via **Helm**.

- First, we will install **Node Exporter** using **Helm**:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus-node-exporter
helm install prometheus-node-exporter prometheus-community/prometheus-node-exporter --namespace prometheus-node-exporter
```

- Now add this section in `/etc/prometheus/prometheus.yml`:

```bash
sudo vim /etc/prometheus/prometheus.yml

  - job_name: 'k8s'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['NODE1IP:9100']
```

- Now go to this [website](https://grafana.com/grafana/dashboards/17119-kubernetes-eks-cluster-prometheus/).

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/67.png?raw=true)

- Copy the **Dashboard ID**.
- Paste it in **Grafana Dashboard**.
- Select **Prometheus**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/68.png?raw=true)

- Click **Import**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/66.png?raw=true)

_Now **Prometheus** is monitoring your **EKS Cluster**._


## 6. Installing and Configuring ArgoCD

Now in this last step, I am going to install and configure **ArgoCD** for the **GitOps** part.

- Go to your scripts folder.
- Run `argocd_master.sh` to install **ArgoCD**.
- Copy the **Username**, **Password** and its **URL**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/69.png?raw=true)

- Now click on **Create Application**.
- Configure it as:
    - **Application Name** = `amazon-project`
    - **Project Name** = `default`
    - **Sync Policy** = `Automatic`
    - **Check-Mark** `Enable Auto-Sync` and `Auto-Create Namespace`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/70.png?raw=true)

- Configure the **Source** and **Destination** as:
    - **Source Repo** = `[YOUR FORKED REPO]`
    - **Revision** = `HEAD`
    - **Path** = `./k8s-80/`
    - **Destination Cluster URL** = `https://kubernetes.default.svc`
    - **Namespace** = `amazon-ns`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/71.png?raw=true)

_Now it will build and deploy your application automatically._

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/72.png?raw=true)

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/73.png?raw=true)

- Now copy this **ALB DNS**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/74.png?raw=true)

- Paste it in your browser.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/75.png?raw=true)

- Now let's make a simple change in the UI.
- Go to `amazon-Devsecops/src/components/NavBar.jsx`.
- Make this change.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/76.png?raw=true)

- Push this change to **Github**:

```bash
git add .
git commit -m "Update delivery location text in NavBar - DevSecOps Demo"
git push origin main
```

- Now build and push this **Docker Image**:

```bash
docker build -t [YOUR-DOCKERHUB-USERNAME]/amazon:latest .
docker push [YOUR-DOCKERHUB-USERNAME]/amazon:latest
```

- Update `amazon-Devsecops/k8s-80/deployment.yml`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/78.png?raw=true)

- Push this change to **Github**:

```bash
git add .
git commit -m "Update deployment to use [YOUR-DOCKERHUB-NAME]/amazon:latest image"
git push origin main
```

- Now if you don't see any update in the web, then just command it to force update **ArgoCD**:

``` bash
# Check ArgoCD status
kubectl get applications -n argocd

# Force sync (if needed)
kubectl patch application amazon-project -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'

# Verify deployment updated
kubectl get deployment amazon-app-deployment -n amazon-ns -o jsonpath='{.spec.template.spec.containers[0].image}'

# Check new pods
kubectl get pods -n amazon-ns
```

- Now go to your application.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Amazon-Website-Clone/Images/77.png?raw=true)

_You have successfully done this project where ArgoCD automatically build any change in the Github with DevSecOps tools and security best practices._
