
# Three Tier EKS with ArgoCd

This is a mini **DevOps Project** where I deployed a three tier web app on **AWS EKS** with **ArgoCD**.

![Project Diagram](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/diagram-export-9-22-2025-4_17_30-PM.png?raw=true)
This project is originally by _**Harish Shetty**_ in which I will first deploy the app manually on **AWS EKS** and then use **ArgoCD** to deploy it automatically.

## Step-by-Step Project Guide

- Deploying the infrastructure
- Installing the DevOps tools
- Creating EKS Cluster
- Deploying the App Manually
- Installing ArgoCD
- Deploying the App Automatically

## 1. Deploying the infrastructure

In the first step, I am going to deploy the **EC2 Instance** server along with its **Security Group**, fully automated by **Terraform**.

- Download these terraform files from [here](https://github.com/UXHERI/DevOps-Projects/tree/main/Three-Tier-AWS-EKS/Terraform).
- Run `ssh-keygen` and name it `three-tier-eks` to make an **EC2 Key-Pair**.
- Execute these commands to deploy the infrastructure:

```powershell
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

_This will take some time to deploy the infrastructure._


## 2. Installing the DevOps Tools

Now when the **EC2 Instance** is deployed, the next step is to install the required **DevOps** tools to deploy the app.

- SSH into the **EC2 Instance**.
- Update the installed packages:

```bash
sudo apt update -y
sudo apt upgrade -y
```

- Now download/copy these [scripts](https://github.com/UXHERI/DevOps-Projects/tree/main/Three-Tier-AWS-EKS/Scripts).
- Make all these scripts executable:

```bash
chmod +x *
```

- Now first run `tools.sh` to install **AWS CLI**, **KubeCTL** and **EKSCTL**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/1.png?raw=true)

- Now run `aws configure` to configure your **Access Keys** and **Secret Access Keys**.
- Now run `helm.sh` to install **helm**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/2.png?raw=true)

## 3. Creating EKS Cluster

Now I will create an **EKS Cluster** to deploy the three tier app on it.

- To create **EKS Cluster** run `eks_cluster.sh`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/3.png?raw=true)

> [!NOTE]
> Update `Cluster Name`, `AWS Region` and `Node Group Key` in `eks_cluster.sh`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/28.png?raw=true)

## 4. Deploying the App Manually

Now I will deploy this app on this **EKS Cluster** manually through **YAML files**.

- Fork & Clone this repository.

```bash
git clone https://github.com/UXHERI/3-Tier-K8s-Project-GitOps.git
```

> [!WARNING]
> First, fork this repository and then clone your forked repository to deploy it.

- Now go to `k8s-http` file.

```bash
cd 3-Tier-K8s-Project-GitOps/k8s-http
```

- First, apply the `namespace.yml` to create the namespace for this app.

```bash
kubectl apply -f namespace.yml
```

- Now apply `mongo.yaml` to create the database.

```bash
kubectl apply -f mongo.yaml
```

- Now apply `mongo-init.yaml` file.

```bash
kubectl apply -f mongo-init.yaml
```

- Now apply `secrets.yaml` to apply the database secrets.

```bash
kubectl apply -f secrets.yaml
```

- Now apply `backend.yaml` to create the backend.

```bash
kubectl apply -f backend.yaml
```

- Now apply `frontend.yaml` to create the frontend of this app.

```bash
kubectl apply -f frontend.yaml
```

- Now apply `ingress.yaml` to create the ingress networking for this app.

```bash
kubectl apply -f ingress.yaml
```

- Now change the default context.

```bash
kubectl config set-context --current --namespace 3-tier-ns
```

- Now go to **EC2** --> **Load Balancers**.
- Copy this **Load Balancer's DNS**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/8.png?raw=true)

- Paste this in your browser.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/9.png?raw=true)

- Now go to **Items Management** and add some items.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/11.png?raw=true)

_Both of the application's frontend and backend are working correctly._

## 5. Installing ArgoCD

Now I am going to install **ArgoCD** to deploy this website automatically on **AWS EKS**.

- In your **Scripts** folder, run `argocd_master.sh`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/12.png?raw=true)

- Go to this URL to access **ArgoCD**.

## 6. Deploying the App Automatically

Now I will be deploying this app automatically on **AWS EKS** with the help of **ArgoCD**.

- First, delete the current deployments.

```bash
cd 3-Tier-K8s-Project-GitOps/k8s-http
kubectl delete -f .
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/14.png?raw=true)

- Now check the pods.

```bash
kubectl get pods
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/15.png?raw=true)

- Now go to **ArgoCD** --> **Create Application**.
- Configure it as:
    - **Application Name** = `three-tier-eks`
    - **Project Name** = `default`
    - **Sync Policy** = `Automatic`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/16.png?raw=true)

- Configure **Source** & **Destination** as:
    - **Source Repo** = `[YOUR FORKED REPO]`
    - **Revision** = `HEAD`
    - **Path** = `k8s-http`
    - **Destination Cluster URL** = `https://kubernetes.default.svc`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/17.png?raw=true)

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/18.png?raw=true)

- Now before creating this application, run:

```bash
watch kubectl get pods
```

- Now create this application.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/20.png?raw=true)

- Check the **deployment** in your terminal.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/21.png?raw=true)

_It will complete the deployment shortly!_

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/22.png?raw=true)

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/23.png?raw=true)

- Now copy this **Load Balancer's DNS**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/24.png?raw=true)

- Paste this in your browser.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/25.png?raw=true)

_Now the deployment is successfully automated with ArgoCD._

- Add some data in **Items Management**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/26.png?raw=true)

_You can see the data inside your database too._

- Go to the terminal and run:

```bash
kubectl exec -it mongo-0 -n 3-tier-ns -- mongo app
db.items.find().pretty()
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Three-Tier-AWS-EKS/Images/27.png?raw=true)

_You have successfully done this project where **ArgoCD** automatically deploy the application **AWS EKS**._
