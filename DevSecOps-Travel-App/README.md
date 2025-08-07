
# Wanderlust App Deployment with DevSecOps

Wanderlust is a simple MERN stack web app where people can share their travel experiences. In this project, I am going to show you how to deploy this Wanderlust app on **AWS EKS** with **DevSecOps** technologies.

![Project Diagram](https://raw.githubusercontent.com/DevMadhup/Wanderlust-Mega-Project/refs/heads/main/Assets/DevSecOps%2BGitOps.gif)

This project is by **TrainWithShubham** in his **Jenkins In One Shot** tutorial and it shows the real-world deployment of such web apps through **DevSecOps** methodoligies. 

You can find this public Github Repo here: [GitHub Repo](https://github.com/LondheShubham153/Wanderlust-Mega-Project.git)

## Step-by-Step Project Guide:

- Deploying the Infrastructure

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


