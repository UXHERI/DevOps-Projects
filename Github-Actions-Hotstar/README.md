
# Amazon Hotstar with Github Actions

This is a mini project about deploying **Amazon Hotstar** on **Docker** using **GitHub Actions**.

This project is done by _**Harish Shetty**_ in his **DevOps Projects** series where he deployed a **CI Pipeline** on **GitHub Actions** to deploy an application on **AWS EC2**.

## Step-by-Step Project Guide:

- Deploying the Infrastructure
- Installing the DevSecOps Tools
- Configuring the DevSecOps Tools
- Configuring GitHub Actions

## 1. Deploying the Infrastructure

In the first step, I am going to deploy the **EC2 Instance** server along with its **Security Group**, fully automated by **Terraform**.

- Download these terraform files from [here](https://github.com/UXHERI/DevOps-Projects/tree/main/Github-Actions-Hotstar/Terraform).
- Run `ssh-keygen` and name it `hotstar` to make an **EC2 Key-Pair**.
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

- Now download/copy these [scripts](https://github.com/UXHERI/DevOps-Projects/tree/main/Github-Actions-Hotstar/Scripts).
- Make all these scripts executable:

```bash
chmod +x *
```

- Now first run `tools.sh` to install **AWS CLI**, **KubeCTL** and **EKSCTL**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/2.png?raw=true)

- Now run `aws configure` to configure your **Access Keys** and **Secret Access Keys**.
- Run `docker.sh` to install & configure **Docker** automatically.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/3.png?raw=true)

- Run `sonarqube.sh` to run **SonarQube** container.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/4.png?raw=true)

## 3. Configuring the DevSecOps Tools

Now when the **DevSecOps** tools are installed, now is the time to configure them.

- Now we will integrate our **Gmail** with **Github Actions**, so it can send an email everytime a build get successfull or it fails.
- Go to **Manage your Google Account**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/12.png)

- Go to **Security**, and enable **2-Step Verification**.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/13.png)

- Now search for **App passwords** and click on it.

![](https://raw.githubusercontent.com/UXHERI/DevOps-Projects/refs/heads/main/DevSecOps-Travel-App/Images/14.png)

- Now create an **App password** for **Github Actions**, and copy the password somewhere.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/5.png?raw=true)

- Now go to **DockerHub**.
- Go to **Personal access tokens**.
- Click **Generate new token**.
- Configure it as:
    - **Access token description** = `github-actions-token`
    - **Access permissions** = `Read, Write, Delete`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/6.png?raw=true)

- Click **Generate**.
- Now go to **SonarQube**.
- Create a project **Manually**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/7.png?raw=true)

- Name it `hotstar`.
- Click **Set Up**.
- Continue with **GitHub Actions**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/8.png?raw=true)

- Copy the **Name** in the **Second Step**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/10.png?raw=true)

- Click **Generate a token** in the **Third Step**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/11.png?raw=true)

- Click **Continue**.
- **Fork** and **Clone** this repository on your local machine.

```powershell
git clone https://github.com/UXHERI/GitHub-Action-Hotstar.git
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/12.png?raw=true)

- In this step, choose **Other**.
- Copy the **FileName** and create it in your cloned repository.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/13.png?raw=true)

- Do this in **VS Code**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/29.png?raw=true)

- Push it to **GitHub**.

```powershell
git add sonar-project.properties
git commit -m "Added sonar-project.properties"
git push origin main
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/14.png?raw=true)

## 4. Configuring GitHub Actions

In the last, we will be configuring **GitHub Actions** to build a **CI Pipeline** for this project.

- In your repository, go to **Actions**.
- Click on the first **Docker Image**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/16.png?raw=true)

- Copy this `managed.yml` file.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/30.png?raw=true)

- Paste it in this **workflow**.
- Name it `main.yml`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/17.png?raw=true)

- Click **Commit changes**.
- In the **Commit message** write `Created CI`.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/18.png?raw=true)

- First it'll **FAIL**, because we haven't given the **Credentials** yet.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/19.png?raw=true)

- Now go to **Settings** --> **Secrets and variables** --> **Actions**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/20.png?raw=true)

- Click **New repository secret**.
- Configure them one-by-one:
    - **Name** = `SONAR_TOKEN`
    - **Secret** = `[YOUR GENERATED SONAR TOKEN]`
    - **Name** = `SONAR_HOST_URL`
    - **Secret** = `http://[PUBLIC-IP]:9000`
    - **Name** = `EMAIL_USER`
    - **Secret** = `[YOUR EMAIL ADDRESS]`
    - **Name** = `EMAIL_PASS`
    - **Secret** = `[YOUR GENERATED GMAIL PASSWORD]`
    - **Name** = `DOCKER_USERNAME`
    - **Secret** = `[YOUR DOCKER USERNAME]`
    - **Name** = `DOCKER_PASSWORD`
    - **Secret** = `[YOUR GENERATED DOCKER TOKEN]`

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/22.png?raw=true)

- Now go to **Build**.
- Click **Re-run all jobs**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/23.png?raw=true)

- In **SonarQube**, you should see a _SUCCESSFUL QUALITY CHECK_.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/24.png?raw=true)

- You should also recieve an **E-mail** like this.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/email.jpg?raw=true)

- In **DockerHub**, there will be a **hotstar** image.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/25.png?raw=true)

- Pull this image.

```bash
docker pull [YOUR DOCKERHUB NAME]/hotstar
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/26.png?raw=true)

- Run this **Docker Image**.

```bash
docker run -d -p 80:80 --name hotstar [YOUR DOCKERHUB NAME]/hotstar:latest
```

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/27.png?raw=true)

- Go to your **EC2 Public IP**.

![](https://github.com/UXHERI/DevOps-Projects/blob/main/Github-Actions-Hotstar/Images/28.png?raw=true)

_You have SUCCESSFULLY built a CI Pipeline with GitHub Actions to automatically build a **Docker Image** and push it to **DockerHub**._
