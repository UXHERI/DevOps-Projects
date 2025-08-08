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

add_jenkins_to_docker() {
    echo "Adding Jenkins user to Docker group..."
    sudo usermod -aG docker jenkins

    echo "Restarting Jenkins service..."
    sudo systemctl restart jenkins

    echo "✔ Jenkins user added to Docker group and Jenkins service restarted."
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

# Add Jenkins user to Docker group
add_jenkins_to_docker

echo "********** INSTALLATION DONE **********"
